package models

import reactivemongo.bson.BSONObjectID
import play.modules.reactivemongo.json.collection.JSONCollection
import scala.concurrent.Future
import play.api.libs.json.Json
import utils.Mongo._
import utils.JsonFormats.voteCountFormat
import play.modules.reactivemongo.json.BSONFormats.BSONObjectIDFormat
import scala.concurrent.ExecutionContext.Implicits.global

case class VoteCount(count: Int, answerId: BSONObjectID, _id: BSONObjectID = BSONObjectID.generate) {
  def save() = {
    VoteCount.collection.insert(this)
  }

  def toJson = {
    Json.obj(
      "_id" -> _id.stringify,
      "count" -> count,
      "answerId" -> answerId.stringify)
  }
}

object VoteCount {
  def collection: JSONCollection = db.collection[JSONCollection]("voteCounts")

  def find(_id: String): Future[Option[VoteCount]] = {
    collection.find(Json.obj("_id" -> BSONObjectID(_id))).one[VoteCount]
  }

  def findByAnswerId(answerId: String): Future[Option[VoteCount]] = {
    collection.find(Json.obj("answerId" -> BSONObjectID(answerId))).one[VoteCount]
  }

  def increment(answerId: String, inc: Int) = {
    collection.update(Json.obj("answerId" -> BSONObjectID(answerId)),
      Json.obj("$inc" -> Json.obj("count" -> inc)))
  }
}