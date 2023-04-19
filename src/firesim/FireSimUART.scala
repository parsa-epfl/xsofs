// See LICENSE.md for license details

package xsofs.firesim
import  xsofs.util._

import  chisel3._
import  chisel3.util._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.diplomacy._


class FireSimUART(addr: Seq[AddressSet])(implicit p: Parameters)
  extends FireSimAXI(addr  = addr,
                     exec  = true,
                     read  = TransferSizes(1, 8),
                     write = TransferSizes(1, 8))(p) {

  override lazy val module = new FireSimAXIImp("uart", this) {
    val int = IO(Output(Bool()))

    // only single burst
    assert(in.ar.valid -> Non(in.ar.bits.len))
    assert(in.aw.valid -> Non(in.aw.bits.len))

    val ar_sel_q = RegEnable(Dec(in.ar.bits.addr(3, 2)), ar_fire)
    val aw_sel_q = RegEnable(Dec(in.aw.bits.addr(3, 2)), aw_fire)

    val int_q = RegEnable(in.w.bits.data(4),
                          false.B,
                          w_fire && aw_sel_q(3))

    // another rx queue
    val u_rxq = Module(new Queue(UInt(8.W), 64))

    u_rxq.io.enq.valid := rx_fire
    u_rxq.io.enq.bits  := io.rx.bits(8.W)
    u_rxq.io.deq.ready := r_fire && ar_sel_q(0)

    val rdata = Ext(OrM(ar_sel_q,
                        Seq(u_rxq.io.deq.bits,
                            0.U,
                            0.U,
                            int_q ## false.B ## true.B ##
                           !u_rxq.io.enq.ready ##
                            u_rxq.io.deq.valid)), 32)

    io.tx.valid        := w_fire && aw_sel_q(1)
    io.tx.bits         := in.w.bits.data(8.W)
    io.rx.ready        := true.B

    in.ar.ready        := fsm_is_idle && in.ar.valid
    in.aw.ready        := fsm_is_idle && in.aw.valid && !in.ar.valid
    in. w.ready        := fsm_is_w    && io.tx.ready

    in. r.valid        := fsm_is_r
    in. r.bits.last    := true.B
    in. r.bits.data    := Rep(rdata, 2)

    in. b.valid        := fsm_is_b

    // plic only supports level-high irq
    // the software continuously reads rxfifo until it is empty again,
    // which forms the natural handling of the interrupt
    int := int_q && u_rxq.io.deq.valid
  }
}
