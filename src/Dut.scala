package xsofs
import  xsofs.util._

import  chisel3._
import  chisel3.util._
import  chisel3.experimental._

import  xiangshan._
import  system._
import  top._

import  junctions._
import  midas.models._
import  midas.widgets._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.diplomacy._


trait HasAutoIO {
  def autoIO[T <: Data](d: T, name: String = ""): T = {
    val dat = chiselTypeOf(d)
    val dir = DataMirror.directionOf(d)

    val io  = dir match {
      case ActualDirection.Bidirectional(_) =>
        IO(       dat ).suggestName(name)
      case ActualDirection.Input =>
        IO(Input (dat)).suggestName(name)
      case _ =>
        IO(Output(dat)).suggestName(name)
    }

    dir match {
      case ActualDirection.Input =>
        d  <> io
      case _ =>
        io <> d
    }

    io
  }
}


// see: SimTop
class Dut(implicit p: Parameters) extends RawModule with HasAutoIO {
  val clk = dontTouch(Wire(Clock()))
  val rst = dontTouch(Wire(Reset()))

  if (Env.fpga != 2) {
    val clock = IO(Input(Clock()))
    val reset = IO(Input(Bool ()))

    clk := clock
    rst := reset

  } else {
    val i_rst = dontTouch(Wire(Input(Bool())))
    val u_clk = Module(new RationalClockBridge(Seq(RationalClock("clock", 1, 1))))
    val u_rst = Module(new ResetPulseBridge(ResetPulseBridgeParameters()))
    val u_ppb = Module(new PeekPokeBridge(Seq(("reset", i_rst))))

    clk := u_clk.io.clocks.head
    rst := u_rst.io.reset

    u_rst.io.clock := clk
    u_ppb.io.clock := clk

    // this reset is not usable. it is just a normal signal wrapped by a decoupled
    // interface to be poked to the target. it may turn "invalid" if the target
    // cycles are used up, which simply makes no sense.
    i_rst := u_ppb.io.elements("reset")
  }

  withClockAndReset(clk, rst) {
    val u_top  = LazyModule(new XSTop())
    val m_top  =     Module(u_top.module)

    val p_mem  = u_top.misc.memAXI4SlaveNode.in.head
    val p_dev  = u_top.misc.peripheralNode  .in.head._2.master

    val i_dma  = m_top.dma
    val i_mem  = m_top.memory
    val i_dev  = m_top.peripheral
    val i_misc = m_top.io
    val i_jtag = m_top.io.systemjtag

    // rtc clock: 100x slower
    val div_cnt_q = dontTouch(Wire(UInt(6.W)))
    val div_tog_q = dontTouch(Wire(Bool()))
    val div_mat   = div_cnt_q === 49.U

    div_cnt_q := RegEnable(NeQ(div_mat, div_cnt_q + 1.U), 0.U,     true.B)
    div_tog_q := RegEnable(Non(div_tog_q),                false.B, div_mat)

    val ext_intrs = dontTouch(Wire(UInt(p(SoCParamsKey).extIntrs.W)))

    // fixed wirings
    i_dma                  <> DontCare
    i_misc.rtc_clock       := div_tog_q
    i_misc.clock           := clk.asBool
    i_misc.reset           := rst.asBool

    i_misc.sram_config     := 0.U
    i_misc.pll0_lock       := false.B
    i_misc.cacheable_check := DontCare
    i_misc.extIntrs        := ext_intrs
    i_misc.riscv_rst_vec.foreach {
      _ := 0x10000000.U
    }

    i_jtag.reset           := rst.asBool
    i_jtag.mfr_id          := 0.U
    i_jtag.version         := 0.U
    i_jtag.part_number     := 0.U

    // peripherals
    Env.fpga match {
      case 0 =>
        val u_dev = LazyModule(new SysDev(p_dev))
        val m_dev =     Module(u_dev.module)

        m_dev.dev <> i_dev
        ext_intrs := 0.U

        autoIO(i_mem,       "mem")
        autoIO(m_dev .uart, "uart")
        autoIO(i_jtag.jtag, "jtag")

      case 1 =>
        autoIO(i_mem,       "mem")
        autoIO(i_dev,       "dev")
        autoIO(i_jtag.jtag, "jtag")

        // uart: #1
        // qspi: #2
        val uart_int = IO(Input(Bool()))
        val qspi_int = IO(Input(Bool()))

        ext_intrs := qspi_int ## uart_int

      case 2 =>
        val u_dev = LazyModule(new firesim.FireSimDev(p_dev))
        val m_dev =     Module(u_dev.module)

        m_dev.dev <> i_dev

        // uart: #1
        ext_intrs := m_dev.int

        // firesim creates a counter for each id, but the original id has many
        // msbs just wired to 0
        val id = 6

        val u_fased = FASEDBridge(clk, i_mem(0), rst.asBool, CompleteConfig(
          userProvided     = LatencyPipeConfig(BaseParams(
            // overprovision to avoid deadlocks: non-ready awQueue simply forbids
            // new wReqs to enter wQueue to make awQueue ready again. the ingress
            // then stalls everything
            maxReads       = 8,
            maxWrites      = 8,
            beatCounters   = false,
            llcKey         = None
          )),
          axi4Widths       = NastiParameters(p_mem._1.params).copy(idBits = id),
          axi4Edge         = Some(AXI4EdgeSummary(p_mem._2)),
          memoryRegionName = Some("MainMemory")
        ))

        val u_jtag = Module(new firesim.FireSimJTAG())

        i_jtag.jtag <> u_jtag.io
    }
  }
}
