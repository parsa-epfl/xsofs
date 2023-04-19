// See LICENSE.md for license details

package xsofs

import  device._
import  difftest._

import  chipsalliance.rocketchip.config._
import  freechips.rocketchip.amba.axi4._
import  freechips.rocketchip.diplomacy._


// see: SimMMIO
class SysDev(m: AXI4MasterPortParameters)(implicit p: Parameters) extends LazyModule {
  val u_node = AXI4MasterNode(Seq(m))

  val u_rom  = LazyModule(new AXI4Flash(Seq(AddressSet(0x10000000L, 0xfffffff))))
  val u_uart = LazyModule(new AXI4UART (Seq(AddressSet(0x40600000L, 0xf))))
  val u_bus  = LazyModule(new AXI4Xbar ())

  u_rom .node := u_bus.node
  u_uart.node := u_bus.node
  u_bus .node := u_node

  lazy val module = new LazyModuleImp(this) {
    val dev  = u_node.makeIOs()
    val uart = IO(new UARTIO())

    uart <> u_uart.module.io.extra.get
  }
}
