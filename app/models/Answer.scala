package models

import scala.concurrent.Future

import play.api.libs.json.Json
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.modules.reactivemongo.json.collection.JSONCollection
import play.modules.reactivemongo.json.BSONFormats.BSONObjectIDFormat
import reactivemongo.bson.BSONObjectID
import utils.JsonFormats.answerFormat
import scala.concurrent.ExecutionContext.Implicits.global
import utils.Mongo._

case class Answer(name: String, voteCount: Int, questionId: BSONObjectID, _id: BSONObjectID = BSONObjectID.generate) {
  def save() = {
    Answer.collection.insert(this)
  }

  def toJson = {
    Json.obj(
      "_id" -> _id.stringify,
      "name" -> name,
      "voteCount" -> voteCount,
      "questionId" -> questionId.stringify)
  }
}

object Answer {
  def collection: JSONCollection = db.collection[JSONCollection]("answers")

  def find(_id: String): Future[Option[Answer]] = {
    collection.find(Json.obj("_id" -> BSONObjectID(_id))).one[Answer]
  }

  def findByQuestionId(questionId: String): Future[Seq[Answer]] = {
    collection.find(Json.obj("questionId" -> BSONObjectID(questionId))).cursor[Answer].toList
  }

  def incVoteCount(_id: String, inc: Int) = {
    collection.update(Json.obj("_id" -> BSONObjectID(_id)),
      Json.obj("$inc" -> Json.obj("voteCount" -> inc)))
  }
}