package models

import scala.concurrent.ExecutionContext.Implicits.global
import play.modules.reactivemongo.json.collection.JSONCollection
import play.modules.reactivemongo.MongoController
import play.api.mvc.Controller
import play.modules.reactivemongo.ReactiveMongoPlugin
import play.api.libs.json.Json
import play.api.data._
import reactivemongo.bson.BSONObjectID
import play.api.libs.json.JsObject
import play.api.Play.current
import utils.JsonFormats.questionFormat
import reactivemongo.api.Cursor
import scala.concurrent.Future
import utils.Mongo._
import play.modules.reactivemongo.json.BSONFormats.BSONObjectIDFormat

case class Question(name: String, _id: BSONObjectID = BSONObjectID.generate) {
  import Question._

  def save() = {
    Question.collection.insert(this)
  }

  def toJson = {
    Json.obj(
      "_id" -> _id.stringify,
      "name" -> name)
  }
}

object Question {

  def collection: JSONCollection = db.collection[JSONCollection]("questions")

  def find(_id: String): Future[Option[Question]] = {
    collection.find(Json.obj("_id" -> BSONObjectID(_id))).one[Question]
  }

  def findAll() = {
    collection.find(Json.obj()).cursor[Question].toList
  }
}