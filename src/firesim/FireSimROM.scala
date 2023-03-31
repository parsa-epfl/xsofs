package xsofs.firesim
import  xsofs.util._

import  chisel3._
import  chisel3.util._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.diplomacy._


class FireSimROM(addr: Seq[AddressSet])(implicit p: Parameters)
  extends FireSimAXI(addr  = addr,
                     exec  = true,
                     read  = TransferSizes(1, 8),
                     write = TransferSizes(0, 0))(p) {

  override lazy val module = new FireSimAXIImp("rom", this) {

    // only single ar burst
    assert(in.ar.valid -> Non(in.ar.bits.len))
    assert(in.aw.valid -> false.B)

    // 2 bursts
    val r_tog_q = dontTouch(Wire(Bool()))
    val r_buf_q = dontTouch(Wire(UInt(32.W)))
    val r_tog_l = Non(r_tog_q)

    r_tog_q := RegEnable(r_tog_l, false.B, rx_fire)
    r_buf_q := RegEnable(io.rx.bits,       rx_fire && r_tog_l)

    // 64-bit aligned
    io.tx.valid     := fsm_is_idle &&  ar_fire
    io.tx.bits      := in.ar.bits.addr(in.ar.bits.addr.getWidth := 3) ## 0.U(3.W)
    io.rx.ready     := fsm_is_r    && (r_tog_l || in.r.ready)

    in.ar.ready     := fsm_is_idle &&  io.tx.ready
    in.aw.ready     := false.B
    in. w.ready     := false.B
    in. b.valid     := false.B

    in. r.valid     := fsm_is_r    &&  io.rx.valid && r_tog_q
    in. r.bits.data := io.rx.bits  ##  r_buf_q
    in. r.bits.last := true.B
  }
}
