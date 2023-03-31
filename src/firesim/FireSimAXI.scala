package xsofs.firesim
import  xsofs.util._

import  chisel3._
import  chisel3.util._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.amba.axi4._
import  freechips.rocketchip.diplomacy._


class FireSimAXI(
  addr:      Seq[AddressSet],
  exec:      Boolean,
  read:      TransferSizes,
  write:     TransferSizes,
  beatBytes: Int = 8,
)(implicit p: Parameters) extends LazyModule {

  val node = AXI4SlaveNode(Seq(AXI4SlavePortParameters(
    Seq(AXI4SlaveParameters(
      address       = addr,
      regionType    = RegionType.UNCACHED,
      executable    = exec,
      supportsRead  = read,
      supportsWrite = write,
      interleavedId = Some(0)
    )),
    beatBytes = beatBytes
  )))

  lazy val module = new FireSimAXIImp("axi", this)
}

class FireSimAXIImp(n: String, o: FireSimAXI) extends LazyModuleImp(o) {
  val in      = o.node.in.head._1

  val ar_fire = in.ar.fire
  val aw_fire = in.aw.fire
  val  r_fire = in. r.fire
  val  w_fire = in. w.fire
  val  b_fire = in. b.fire

  val  r_last = in. r.bits.last
  val  w_last = in. w.bits.last

  // fsm
  val
     (fsm_idle ::
      fsm_r    ::
      fsm_w    ::
      fsm_b    ::
      fsm_null)  = Enum(4)

  val fsm_q   = dontTouch(Wire(UInt(2.W)))
  val fsm_en  = dontTouch(Wire(Bool()))
  val fsm_nxt = dontTouch(Wire(UInt(2.W)))

  // default
  fsm_en  := false.B
  fsm_nxt := fsm_q

  switch (fsm_q) {
    is (fsm_idle) {
      fsm_en  := ar_fire || aw_fire
      fsm_nxt := ar_fire ?? fsm_r    :: fsm_w
    }
    is (fsm_r) {
      fsm_en  := r_fire
      fsm_nxt := r_last  ?? fsm_idle :: fsm_r
    }
    is (fsm_w) {
      fsm_en  := w_fire
      fsm_nxt := w_last  ?? fsm_b    :: fsm_w
    }
    is (fsm_b) {
      fsm_en  := b_fire
      fsm_nxt := fsm_idle
    }
  }

  fsm_q := RegEnable(fsm_nxt, fsm_idle, fsm_en)

  val fsm_is_idle = fsm_q === fsm_idle
  val fsm_is_r    = fsm_q === fsm_r
  val fsm_is_w    = fsm_q === fsm_w
  val fsm_is_b    = fsm_q === fsm_b

  // not actually the io
  val io = dontTouch(Wire(new FireSimIO()))

  val tx_fire = io.tx.fire
  val rx_fire = io.rx.fire

  def connect_io(): Unit = {
    in.ar.ready  := fsm_is_idle &&  io.tx.ready && in.ar.valid
    in.aw.ready  := fsm_is_idle &&  io.tx.ready && in.aw.valid && !in.ar.valid
    in. r.valid  := fsm_is_r    &&  rx_fire
    in. w.ready  := fsm_is_w    &&  io.tx.ready
    in. b.valid  := fsm_is_b    &&  rx_fire

    io.tx.valid  := fsm_is_idle && (ar_fire || aw_fire || w_fire)
    io.rx.ready  := fsm_is_r    ??  in. r.ready ::
                    fsm_is_w    ??  in. w.ready ::
                                    false.B
  }

  // bridge inst
  val u_fsb = Module(new FireSimBridge(n))

  u_fsb.io.clock := clock
  u_fsb.io.reset := reset
  u_fsb.io.io    <> io

  in.r.bits.id   := RegEnable(in.ar.bits.id,   ar_fire)
  in.r.bits.user := RegEnable(in.ar.bits.user, ar_fire)
  in.r.bits.resp := AXI4Parameters.RESP_OKAY

  in.b.bits.id   := RegEnable(in.aw.bits.id,   aw_fire)
  in.b.bits.user := RegEnable(in.aw.bits.user, aw_fire)
  in.b.bits.resp := AXI4Parameters.RESP_OKAY
}
