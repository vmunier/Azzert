package utils

import play.modules.reactivemongo.ReactiveMongoPlugin
import play.api.Play.current

object Mongo {
  implicit def connection = ReactiveMongoPlugin.connection
  val db = ReactiveMongoPlugin.db
}