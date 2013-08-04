package models

import reactivemongo.bson.BSONObjectID
import org.joda.time.DateTime
import play.modules.reactivemongo.json.collection.JSONCollection
import scala.concurrent.Future
import play.api.libs.json.Json
import utils.Mongo._
import utils.JsonFormats.voteFormat
import play.modules.reactivemongo.json.BSONFormats.BSONObjectIDFormat
import scala.concurrent.ExecutionContext.Implicits.global

case class Vote(value: Int, answerId: BSONObjectID, date: DateTime = new DateTime(), _id: BSONObjectID = BSONObjectID.generate) {
  def save() = {
    Vote.collection.insert(this)
  }

  def toJson = {
    Json.obj(
      "_id" -> _id.stringify,
      "value" -> value,
      "answerId" -> answerId.stringify,
      "date" -> date
    )
  }
}

object Vote {
  def collection: JSONCollection = db.collection[JSONCollection]("votes")

  def find(_id: String): Future[Option[Vote]] = {
    collection.find(Json.obj("_id" -> BSONObjectID(_id))).one[Vote]
  }

  def findByAnswerId(answerId: String): Future[Seq[Vote]] = {
    collection.find(Json.obj("answerId" -> BSONObjectID(answerId))).cursor[Vote].toList
  }
}
