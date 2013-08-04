package global

import java.util.concurrent.atomic.AtomicReference
import com.typesafe.plugin.RedisPlugin
import play.api.Application
import play.api.GlobalSettings

object Global extends GlobalSettings {
  val redisPlugin = new AtomicReference[RedisPlugin]()

  def sedisPool = redisPlugin.get().sedisPool

  override def onStart(app: Application) {
    val plugin = app.plugin(classOf[RedisPlugin]).get
    plugin.onStart()
    redisPlugin.set(plugin)
    jobs.HistoryActor.startup()
  }

  override def onStop(app: Application) {
    redisPlugin.get().onStop()
  }
}