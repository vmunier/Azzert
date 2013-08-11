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
import java.net.Socket
import java.io.PrintWriter
import play.api.libs.ws.WS
import java.util.Date
import java.net.URI
import java.net.URL
import play.api.libs.json.JsArray
import scala.concurrent.duration._
import utils.AzzertException

case class AnswerHistory(questionId:String, answerId: String, voteCount: Int, date: DateTime) {
  def save() = {
    AnswerHistory.out.println(toTSDBPutFormat)
  }

  private def toTSDBPutFormat: String = {
    s"put $questionId " + (date.getMillis() / 1000) + " " + voteCount + " answer=" + answerId
  }

  def toJson: JsValue = {
    Json.obj(
      "voteCount" -> voteCount,
      "date" -> date,
      "answerId" -> answerId)
  }
}

object AnswerHistory {
  val socket = new Socket("127.0.0.1", 4242)
  val out = new PrintWriter(socket.getOutputStream(), true)

  private def get(query: String): Future[Seq[AnswerHistory]] = {
    val url = new URL(s"http://localhost:4242/q?$query")
    val uri = new URI(url.getProtocol, url.getUserInfo, url.getHost, url.getPort, url.getPath, url.getQuery, url.getRef)
    WS.url(uri.toURL.toString).withTimeout(10.seconds.toMillis.toInt).get.flatMap {
      case response if response.status == 200 =>
        Future(response.body.split("\n").map(transformTsdbOutput(_)))
      case _ =>
        Future.failed(new AzzertException("BadRequest from OpenTSDB"))
    }
  }

  private def transformTsdbOutput(tsdbOutput: String): AnswerHistory = {
    tsdbOutput.split(" ") match {
      case Array(questionId, date, voteCount, answerIdTag) =>
        val answerId = answerIdTag.split("=", 2)(1)
        AnswerHistory(questionId, answerId, voteCount.toInt, new DateTime(date.toLong * 1000))
    }
  }

  // answerId may be a fixed ID or a * to match all answers of the question identified by questionId
  def find(start: DateTime, interval: String, questionId: String, answerId: String = "*"): Future[Seq[AnswerHistory]] = {
    // Don't use 1h-ago in the OpenTSDB request because it will use the cache.
    // Using the header "Cache-Control: no-cache" don't seem to work.
    // So to avoid OpenTSDB caching we have to send a different request every time.
    // That's why we pass a new date for the start parameter instead of using 1h-ago.
    val time = new Date().getTime() / 1000
    val formattedStart = start.toString("yyyy/MM/dd-HH:mm:ss")
    get(s"start=$formattedStart&m=avg:$interval-avg:$questionId{answer=$answerId}&ascii") map {
      // TODO : find a solution to have values sorted by date directly out of OpenTSDB
      _.sortBy { answerHistory => answerHistory.date.getMillis()
      }
    }
  }
}
