package xsofs

import  chisel3.stage._
import  firrtl._
import  firrtl.options._
import  firrtl.stage._

import  top._
import  huancun.utils._

import  midas.stage._

import  freechips.rocketchip.diplomacy._
import  freechips.rocketchip.util._


object Env {
  val hart = sys.env.getOrElse("HART", "1").toInt
  val fpga = sys.env.getOrElse("FPGA", "0").toInt
  val chk  = sys.env.getOrElse("CHK",  "0").toInt
  val gen  = sys.env.getOrElse("GEN",  "gen")
}

object Main extends App with HasRocketChipStageUtils {
  new java.io.File(Env.gen).mkdir()

  println(s"HART: ${Env.hart}")
  println(s"FPGA: ${Env.fpga}")
  println(s"CHK:  ${Env.chk}")
  println(s"GEN:  ${Env.gen}")

  implicit val p = new SysCfg()
  implicit val v = ValName("Dut")

  val a = Array("-X",            "sverilog",
                "-o",            "Dut.sv",
                "--target-dir", s"${Env.gen}")

  // firesim does its own memory optimizations
  val b = if (Env.fpga == 2)
            a
          else
            a ++ Array("--infer-rw",
                       "--gen-mem-verilog", "full")

  new XiangShanStage().execute(b, Seq(
    ChiselGeneratorAnnotation(() => new Dut()),
    CustomDefaultRegisterEmission(
      useInitAsPreset      = false,
      disableRandomization = true
    ),
    RunFirrtlTransformAnnotation(Dependency[RenameExtModule])
  ))

  if (Env.chk > 0) {
    ChiselDB.addToElaborationArtefacts
  }

  ElaborationArtefacts.files.foreach {
    case (ext, content) =>
      writeOutputFile(Env.gen, s"Dut.${ext}", content())
  }

  if (Env.fpga == 2) {
    val a = Array("-i",                          s"${Env.gen}/Dut.fir",
                  "--annotation-file",           s"${Env.gen}/Dut.anno.json",
                  "--target-dir",                s"${Env.gen}",
                  "--golden-gate-config-package", "xsofs",
                  "--golden-gate-config-string",  "SysCfg",
                  "--output-filename-base",       "Dut.fs",
                  "--no-dedup")

    new GoldenGateStage().execute(a, Seq.empty)
  }

  println("done.")
}
