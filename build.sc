import mill._
import mill.modules._
import mill.scalalib._

import coursier.maven.MavenRepository


trait Common extends ScalaModule {
  def sv = "2.12.12"

  def chisel        = ivy"edu.berkeley.cs::chisel3:3.5.0"
  def chisel_plugin = ivy"edu.berkeley.cs:::chisel3-plugin:3.5.0"
  def paradise      = ivy"org.scalamacros:::paradise:2.1.1"
  def circt         = ivy"com.sifive::chisel-circt:0.4.0"

  override def scalaVersion  = sv
  override def scalacOptions = Seq(
    "-Xsource:2.11"
  )

  override def compileIvyDeps      = Agg(paradise)
  override def scalacPluginIvyDeps = Agg(paradise)

  override def repositories = super.repositories ++ Seq(
    MavenRepository("https://oss.sonatype.org/content/repositories/snapshots"),
    MavenRepository("https://oss.sonatype.org/service/local/staging/deploy/maven2")
  )
}


object config extends Common {
  override def millSourcePath = os.pwd / "repo" / "config" / "cde"
}


object hard_float extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "hard_float"

  override def ivyDeps    = Agg(chisel)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object rocket_macros extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "rocket" / "macros"

  override def ivyDeps    = Agg(
    chisel,
    ivy"${scalaOrganization()}:scala-reflect:${scalaVersion()}"
  )
}

object rocket extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "rocket"

  override def ivyDeps    = Agg(
    chisel,
    ivy"org.json4s::json4s-jackson:3.6.1"
  )
  override def moduleDeps = Seq(config, hard_float, rocket_macros)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object fudian extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "fudian"

  override def ivyDeps    = Agg(chisel)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object huancun extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "huancun"

  override def ivyDeps    = Agg(chisel)
  override def moduleDeps = Seq(rocket)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object difftest extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "difftest"

  override def ivyDeps    = Agg(chisel)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object xiangshan extends SbtModule with Common {
  override def millSourcePath = os.pwd / "repo" / "xiangshan"

  override def ivyDeps    = Agg(chisel, circt)
  override def moduleDeps = Seq(rocket, fudian, huancun, difftest)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object firesim extends Common {
  val sim = os.pwd / "repo" / "firesim" / "sim"

  override def sources    = T.sources(
    sim / "midas" / "targetutils" / "src" / "main" / "scala",
    sim / "midas"                 / "src" / "main" / "scala",
    sim / "firesim-lib"           / "src" / "main" / "scala",
    sim /                           "src" / "main" / "scala"
  )

  override def ivyDeps    = Agg(chisel)
  override def moduleDeps = Seq(rocket)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}


object xsofs extends Common {
  override def millSourcePath = os.pwd

  override def ivyDeps    = Agg(chisel)
  override def moduleDeps = Seq(xiangshan, firesim)

  override def scalacPluginIvyDeps =
    super.scalacPluginIvyDeps() ++ Agg(chisel_plugin)
}
