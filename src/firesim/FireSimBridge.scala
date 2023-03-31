package xsofs.firesim

import  chisel3._
import  chisel3.util._

import  midas.widgets._

import  chipsalliance.rocketchip.config._


class FireSimIO extends Bundle {
  val tx    = Flipped(Decoupled(UInt(32.W)))
  val rx    =         Decoupled(UInt(32.W))
}

class FireSimBridgeIO extends Bundle {
  val clock = Input(Clock())
  val reset = Input(Bool ())
  val io    = new FireSimIO()
}


class FireSimBridge(n: String)(implicit p: Parameters)
  // TODO: workaround
  // java.lang.ClassCastException: firrtl.annotations.InstanceTarget cannot be cast to firrtl.annotations.ModuleTarget
  // at midas.widgets.SerializableBridgeAnnotation.duplicate(BridgeAnnotations.scala:40)
  extends BlackBox(Map("NAME" -> n))
  with    Bridge[HostPortIO[FireSimBridgeIO], FireSimBridgeImp] {

  val io       = IO(new FireSimBridgeIO())
  def bridgeIO = HostPort(io)

  def constructorArg = Some(n)

  generateAnnotations()
}

class FireSimBridgeImp(n: String)(implicit p: Parameters)
  extends BridgeModule[HostPortIO[FireSimBridgeIO]]()(p) {

  lazy val module = new BridgeModuleImp(this) {
    val io    = IO(new WidgetIO())
    val hPort = IO(HostPort(new FireSimBridgeIO()))

    val u_txq = Module(new Queue(UInt(32.W), 16))
    val u_rxq = Module(new Queue(UInt(32.W), 16))

    // the host can be arbitrarily slow. wait for it
    val fire     = hPort.  toHost.hValid &&
                   hPort.fromHost.hReady &&
                   u_txq.io.enq.ready

    val targ     = hPort.hBits.io
    val targ_rst = hPort.hBits.reset || fire && reset.asBool

    hPort.  toHost.hReady := fire
    hPort.fromHost.hValid := fire

    u_txq.io.enq.valid    := fire && targ.tx.valid
    u_txq.io.enq.bits     :=         targ.tx.bits
    u_txq.reset           := targ_rst
    u_rxq.io.deq.ready    := fire && targ.rx.ready
    u_rxq.reset           := targ_rst

    targ.tx.ready         := fire
    targ.rx.valid         := fire && u_rxq.io.deq.valid
    targ.rx.bits          :=         u_rxq.io.deq.bits

    // host rx <-> target tx
    genROReg(u_txq.io.deq.valid, "rx_valid")
    genROReg(u_txq.io.deq.bits,  "rx_bits")

    Pulsify(genWORegInit(u_txq.io.deq.ready, "rx_ready", false.B), pulseLength = 1)

    // host tx <-> target rx
    genROReg(u_rxq.io.enq.ready, "tx_ready")
    genWOReg(u_rxq.io.enq.bits,  "tx_bits")

    Pulsify(genWORegInit(u_rxq.io.enq.valid, "tx_valid", false.B), pulseLength = 1)

    genCRFile()
  }
}
