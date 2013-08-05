package models

import global.Global
import org.joda.time.DateTime
import scala.concurrent.Future
import reactivemongo.bson.BSONObjectID
import play.api.libs.json.Json
import play.modules.reactivemongo.json.collection.JSONCollection
import play.modules.reactivemongo.json.BSONFormats.BSONObjectIDFormat
import utils.Mongo._
import utils.JsonFormats.answerHistoryFormat
import scala.concurrent.ExecutionContext.Implicits.global
import play.api.libs.iteratee.Concurrent.Channel
import redis.clients.jedis.JedisPubSub
import reactivemongo.api.indexes.Index
import reactivemongo.api.indexes.IndexType
import akka.dataflow._
import play.api.libs.iteratee.Enumerator
import play.api.libs.iteratee.Concurrent
import RedisKeys._
import utils.Redis
import utils.EnumeratorUtil
import play.api.libs.iteratee.Enumeratee
import jobs.HistoryActor
import play.api.libs.json.JsValue

case class AnswerHistory(voteCount: Int, date: DateTime, answerId: BSONObjectID, _id: BSONObjectID = BSONObjectID.generate) {
  def save() = {
    AnswerHistory.collection.insert(this)
  }

  def toJson:JsValue = {
    Json.obj(
      "_id" -> _id.stringify,
      "voteCount" -> voteCount,
      "date" -> date,
      "answerId" -> answerId.stringify)
  }
}

object AnswerHistory {
  def collection: JSONCollection = db.collection[JSONCollection]("answer-history")

  collection.indexesManager.ensure(
    Index(List("answerId" -> IndexType.Ascending), unique = false))

  def findByAnswerId(answerId: String): Future[Seq[AnswerHistory]] = {
    collection.find(Json.obj("answerId" -> BSONObjectID(answerId))).cursor[AnswerHistory].toList
  }

  def getEnumerator(answerId: String): Future[Enumerator[AnswerHistory]] = flow {
    val history = getHistoryEnumerator(answerId)()
    val live = getLiveEnumerator(answerId)()
    history.andThen(live)
  }

  def getHistoryEnumerator(answerId: String): Future[Enumerator[AnswerHistory]] = flow {
    val answerHistorySeq = AnswerHistory.findByAnswerId(answerId)()
    Enumerator(answerHistorySeq: _*)
  }

  def getLiveEnumerator(answerId: String): Future[Enumerator[AnswerHistory]] = {

    def onDone(): Unit = {
      HistoryActor.unsubscribe(answerId)
      println("onDone() has been called !")
    }

    HistoryActor.subscribe(answerId).map { answerHistoryEnum =>
      // interleave with empty inputs continually to trigger onDone call when the iteratee is done
      answerHistoryEnum.interleave(EnumeratorUtil.emptyFlow).through(Enumeratee.onIterateeDone[AnswerHistory](onDone))
    }
  }
}
