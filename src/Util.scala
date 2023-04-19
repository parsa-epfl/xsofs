// See LICENSE.md for license details

package xsofs

import  scala.annotation.tailrec

import  chisel3._
import  chisel3.experimental._
import  chisel3.util._
import  chisel3.util.random._
import  chisel3.internal.firrtl._


package object util {

  // see: https://github.com/chipsalliance/chisel3/issues/1743

  def Any[T <: Data](d: T): Bool = {
    d.asUInt().orR()
  }
  def All[T <: Data](d: T): Bool = {
    d.asUInt().andR()
  }
  def Non[T <: Data](d: T): Bool = {
    d.asUInt() === 0.U
  }

  def ShL(d: UInt, n: Int): UInt = {
    val w = d.getWidth

    if (n == 0)
      d
    else if (n >= w)
      0.U(w.W)
    else
      d(w - n - 1, 0) ## 0.U(n.W)
  }
  def ShR(d: UInt, n: Int): UInt = {
    val w = d.getWidth

    if (n == 0)
      d
    else if (n >= w)
      0.U(w.W)
    else
      0.U(n.W) ## d(w - 1, n)
  }
  def SSL(d: UInt, n: Int): UInt = {
    val w = d.getWidth

    if (n == 0)
      d
    else if (n >= w)
     ~0.U(w.W)
    else
      d(w - n - 1, 0) ## ~0.U(n.W)
  }
  def SSR(d: UInt, n: Int): UInt = {
    val w = d.getWidth

    if (n == 0)
      d
    else if (n >= w)
     ~0.U(w.W)
    else
     ~0.U(n.W) ## d(w - 1, n)
  }

  def RoL(d: UInt, n: Int): UInt = {
    val w = d.getWidth
    val m = n % w

    if (m == 0)
      d
    else
      d(w - m - 1, 0) ## d(w - 1, w - m)
  }
  def RoR(d: UInt, n: Int): UInt = {
    val w = d.getWidth
    val m = n % w

    if (m == 0)
      d
    else
      d(m - 1, 0) ## d(w - 1, m)
  }

  @tailrec
  private def shf(f: (UInt, Int) => UInt, d: UInt, s: UInt, n: Int): UInt = {
    if (n >= s.getWidth)
      d
    else
      shf(f, Mux(s(n),
               f(d, 1 << n),
                 d),
          s, n + 1)
  }
  def BSL(d: UInt, s: UInt): UInt = {
    shf(ShL, d, s, 0)
  }
  def BSR(d: UInt, s: UInt): UInt = {
    shf(ShR, d, s, 0)
  }
  def BRL(d: UInt, s: UInt): UInt = {
    shf(RoL, d, s, 0)
  }
  def BRR(d: UInt, s: UInt): UInt = {
    shf(RoR, d, s, 0)
  }

  def Rev(d: UInt): UInt = {
    Cat(d.asBools()).asUInt()
  }

  def Rep(d: UInt, n: Int): UInt = {
    Cat(Seq.fill(n)(d))
  }
  def Div(d: UInt, n: Int): Seq[UInt] = {
    val s = (d.getWidth + n - 1) / n
    val t =  Ext(d, s * n)

    Seq.tabulate(s) { i =>
      t(i * n + n - 1, i * n)
    }
  }

  def Ext(d: UInt, n: Int): UInt = {
    require(n != 0)

    val w = d.getWidth
    val m = n.abs
    val e = if (n > 0) 0.U(1.W) else d(w - 1);

    if (w >= m)
      d(m - 1, 0)
    else
      Rep(e, m - w) ## d
  }

  def EnQ[T <: Data](e: Bool, d: T): T = {
    Mux(e, d, 0.U.asTypeOf(d))
  }
  def NeQ[T <: Data](e: Bool, d: T): T = {
    Mux(e, 0.U.asTypeOf(d), d)
  }

  @tailrec
  private def rex(f: (UInt, Int) => UInt, o: (UInt, UInt) => UInt, d: UInt, n: Int): UInt = {
    if (n >= d.getWidth)
      d
    else
      rex(f, o, o(d, f(d, n)), n << 1)
  }
  private def or (a: UInt, b: UInt): UInt = {
    a | b
  }
  private def ar (a: UInt, b: UInt): UInt = {
    a & b
  }
  def OrL(d: UInt): UInt = {
    rex(ShL, or, d, 1)
  }
  def OrR(d: UInt): UInt = {
    rex(ShR, or, d, 1)
  }
  def ArL(d: UInt): UInt = {
    rex(SSL, ar, d, 1)
  }
  def ArR(d: UInt): UInt = {
    rex(SSR, ar, d, 1)
  }

  private def pri(f: UInt => UInt, g: (UInt, Int) => UInt, d: UInt): UInt = {
    val o = f(d)

    o ^ g(o, 1)
  }
  def PrL(d: UInt): UInt = {
    pri(OrR, ShR, d)
  }
  def PrR(d: UInt): UInt = {
    pri(OrL, ShL, d)
  }

  def RRA(d: UInt, e: Bool): UInt = {
    val w = d.getWidth

    if (w > 1) {
      val arb_q = dontTouch(Wire(UInt(w.W)))
      val fwd   = d &  arb_q
      val bwd   = d & ~arb_q
      val sel   = PrR(Mux(Any(fwd), fwd, bwd))

      arb_q := RegEnable(OrL(RoL(sel, 1)),
                        ~0.U,
                         e)
      sel

    } else
     ~0.U(w.W)
  }

  def PRA(w: Int,  e: Bool): UInt = {
    Dec(LFSR(log2Ceil(w).max(2), e))(w - 1, 0)
  }

  def OHp(d: UInt, z: Bool): Bool = {
    Non(d & ShL(OrL(d), 1)) && (z || Any(d))
  }

  def Dec = UIntToOH
  def Enc = OHToUInt
  def OrM = Mux1H

  private def exp(v: Seq[Bool], n: Int): Seq[Bool] = {
    if (n == 0)
      v
    else
      exp(RegNext(v.head) +: v, n - 1)
  }

  def Exp(b: Bool, n: Int): UInt = {
    Cat(exp(Seq(b), n))
  }

  def Src(i: Bool, o: Bool, s: Bool, n: Int = 2): Bool = {
    require(n >= 2)

    val w = BigInt(n).bitLength

    val src_q = Wire(UInt(n.W))
    val ptr_q = Wire(UInt(w.W))

    src_q := RegEnable(src_q(n - 2, 0) ## s,              0.U, i)
    ptr_q := RegEnable(ptr_q + (Rep(o, w - 1) ## true.B), 0.U, i ^ o)

    assert((ptr_q === n.U) -> !i)
    assert((ptr_q === 0.U) -> !o)

    Any(src_q & Dec(ptr_q)(n, 1))
  }


  case class pair[T1, +T2](a: T1, b: T2)

  implicit class withIInt(d: Int) {
    def :+(a: Int): pair[Int, Int] = {
      pair(d + a, d)
    }
    def :-(a: Int): pair[Int, Int] = {
      pair(d, d - a)
    }
    def :=(a: Int): pair[Int, Int] = {
      pair(d, a)
    }
  }

  implicit class withBits[T <: Bits](d: T) {
    def apply(p: pair[Int, Int]): UInt = {
      d(p.a   - 1, p.b)
    }
    def apply(p: Width): UInt = {
      d(p.get - 1, 0)
    }
  }

  implicit class withBool(d: Bool) {
    def ??[T <: Data](t: T): pair[Bool, T] = {
      pair(d, t)
    }
    def ->(c: Bool): Bool = {
      !(d && !c)
    }
  }

  implicit class withData[T <: Data](d: T) {
    def ::[S <: Data](p: pair[Bool, S]): T = {
      Mux(p.a, p.b.asInstanceOf[T], d)
    }
    def V: Vec[Bool] = {
      VecInit(d.asUInt().asBools())
    }
  }

  implicit class withVec[T <: Data](v: Vec[T]) {
    def U: UInt = {
      v.asUInt()
    }
  }

  implicit class withSeq[T <: Data](s: Seq[T]) {
    def U: UInt = {
      Cat(s.map(_.asUInt()).reverse)
    }
  }

  implicit class withValid[T <: Data](d: ValidIO[T]) {
    def tie: Unit = {
      d.valid := false.B
      d.bits  := DontCare
    }
  }

  implicit class withDecoupled[T <: Data](d: DecoupledIO[T]) {
    def <=(s: DecoupledIO[T]): Unit = {
      d.valid := RegEnable(s.valid || d.valid && !d.ready,
                           false.B,
                           s.valid || d.valid)
      d.bits  := RegEnable(s.bits,
                           s.valid)
    }

    def tie: Unit = {
      DataMirror.directionOf(d) match {
        case ActualDirection.Bidirectional(ActualDirection.Flipped) =>
          d.ready := false.B
        case _ =>
          d.valid := false.B
          d.bits  := DontCare
      }
    }
  }
}
