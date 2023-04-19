// See LICENSE.md for license details

package xsofs.firesim
import  xsofs.util._

import  chisel3._
import  chisel3.util._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.jtag._


class FireSimJTAG()(implicit p: Parameters) extends Module {
  val io = IO(new JTAGIO(hasTRSTn = false))
  val fs = dontTouch(Wire(new FireSimIO()))

  // bridge
  val u_fsb = Module(new FireSimBridge("jtag"))

  u_fsb.io.clock := clock
  u_fsb.io.reset := reset
  u_fsb.io.io    <> fs

  val req_len     = fs.rx.bits(11,  0)
  val req_cmd     = fs.rx.bits(17, 16)

  val rx_fire     = fs.rx.fire
  val tx_fire     = fs.tx.fire
  val rx_init     = dontTouch(Wire(Bool()))

  val req_len_q   = RegEnable(req_len, rx_init)
  val req_cmd_q   = RegEnable(req_cmd, rx_init)
  val req_cnt_q   = dontTouch(Wire(UInt(12.W)))

  // 32-bit burst
  val req_mat_hi  = req_cnt_q(11, 5) ===                req_len_q(11, 5)
  val req_mat_lo  = req_cnt_q( 4, 0) === (req_mat_hi ?? req_len_q( 4, 0) :: 31.U)

  val req_mat_all = req_mat_lo && req_mat_hi
  val req_mat_ret = req_mat_lo && req_cmd_q(1)

  // fsm
  val
     (fsm_idle  ::
      fsm_req   ::
      fsm_prep  ::
      fsm_pos   ::
      fsm_neg   ::
      fsm_resp  ::
      fsm_null) = Enum(6)

  val fsm_q   = dontTouch(Wire(UInt(3.W)))
  val fsm_en  = dontTouch(Wire(Bool()))
  val fsm_nxt = dontTouch(Wire(UInt(3.W)))

  // default
  fsm_en  := false.B
  fsm_nxt := fsm_q

  switch (fsm_q) {
    is (fsm_idle) {
      fsm_en  := rx_fire
      fsm_nxt := fsm_pos
    }
    is (fsm_req) {
      fsm_en  := rx_fire
      fsm_nxt := fsm_prep
    }
    is (fsm_prep) {
      fsm_en  := true.B
      fsm_nxt := fsm_pos
    }
    is (fsm_pos) {
      fsm_en  := true.B
      fsm_nxt := fsm_neg
    }
    is (fsm_neg) {
      fsm_en  := true.B
      fsm_nxt := req_mat_ret ?? fsm_idle ::
                 req_mat_lo  ?? fsm_resp ::
                                fsm_pos
    }
    is (fsm_resp) {
      fsm_en  := tx_fire
      fsm_nxt := req_mat_all ?? fsm_idle ::
                                fsm_req
    }
  }

  fsm_q := RegEnable(fsm_nxt, fsm_idle, fsm_en)

  val fsm_is_idle = fsm_q === fsm_idle
  val fsm_is_req  = fsm_q === fsm_req
  val fsm_is_prep = fsm_q === fsm_prep
  val fsm_is_pos  = fsm_q === fsm_pos
  val fsm_is_neg  = fsm_q === fsm_neg
  val fsm_is_resp = fsm_q === fsm_resp

  rx_init     := rx_fire && fsm_is_idle

  // io
  val tms_q    = dontTouch(Wire(UInt(32.W)))
  val tdi_q    = dontTouch(Wire(UInt(32.W)))
  val tdo_q    = dontTouch(Wire(UInt(32.W)))

  val tms_flip = req_mat_hi && (req_cmd_q === 1.U)
  val shf      = BSL(Ext(fsm_is_req ?? tms_flip        :: io.TDO.data, 32),
                         fsm_is_req ?? req_len_q(4, 0) :: req_cnt_q(4, 0))

  // naturally reset to 0
  val tms_nxt  = ShR(tms_q, 1)
  val tdi_nxt  = ShR(tdi_q, 1)
  val tdo_nxt  = tdo_q | shf

  val tms_init = EnQ(req_cmd_q(1), fs.rx.bits) | shf
  val tdi_init = NeQ(req_cmd_q(1), fs.rx.bits)

  val req_data = fsm_is_req &&  rx_fire
  val req_pos  = fsm_is_pos || req_data
  val req_neg  = fsm_is_neg || req_data || fsm_is_prep

  tms_q       := RegEnable(req_data ?? tms_init :: tms_nxt, req_neg)
  tdi_q       := RegEnable(req_data ?? tdi_init :: tdi_nxt, req_neg)
  tdo_q       := RegEnable(req_data ?? 0.U      :: tdo_nxt, req_pos)

  req_cnt_q   := RegEnable(NeQ(rx_init, req_cnt_q + 1.U),
                           0.U,
                           fsm_is_neg)

  // output
  io.TCK      := fsm_is_pos.asClock
  io.TDI      := tdi_q(0)
  io.TMS      := tms_q(0)

  fs.rx.ready := fsm_is_idle ||
                 fsm_is_req

  fs.tx.valid := fsm_is_resp
  fs.tx.bits  := tdo_q
}
