package xsofs

import  firrtl._
import  firrtl.ir._
import  firrtl.options._
import  firrtl.stage._
import  firrtl.stage.TransformManager._


// TODO: workaround
// firrtl.passes.CheckHighFormLike$DefnameDifferentPortsException: :
// ports of extmodule XXX with defname XXX are different for an extmodule with the same defname
class RenameExtModule extends Transform with DependencyAPIMigration {
  override def prerequisites: Seq[TransformDependency] = Forms.HighForm

  override def invalidates(a: Transform): Boolean = false

  def execute(state: CircuitState): CircuitState = {
    def rename(m: DefModule): DefModule = {
      m match {
        case e: ExtModule =>
          // this should be special enough
          val idx = e.defname.indexOf("___")

          if (idx > 0)
            e.copy(defname = e.defname.substring(0, idx))
          else
            e

        case _ => m
      }
    }

    state.copy(circuit = state.circuit.copy(modules = state.circuit.modules.map(rename)))
  }
}
