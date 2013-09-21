package global

import java.util.concurrent.atomic.AtomicReference
import play.api.Application
import play.api.GlobalSettings
import models.Autocomplete

object Global extends GlobalSettings {

  override def onStart(app: Application) {
    //add autocomplete questions settings + questions mapping
    Autocomplete.initialize()
    jobs.HistoryActor.startup()
  }

  override def onStop(app: Application) {
  }
}
