package controllers

import global.Global
import play.api.mvc.Controller
import play.api.mvc.Action
import scala.concurrent.ExecutionContext.Implicits.global
import models.Answer
import play.api.libs.json.Json
import akka.dataflow._
import utils.JsonFormats._
import play.api.libs.json.JsArray
import reactivemongo.bson.BSONObjectID
import models.AnswerHistory
import utils.JsonFormats.answerHistoryFormat
import play.api.libs.EventSource
import play.api.libs.iteratee.Enumerator
import models.Question
import scala.concurrent.Future
import org.joda.time.DateTime
import jobs.HistoryActor
import play.api.mvc.PlainResult

object AnswerHistoryCtrl extends Controller {
  def sseQuestionSession(questionId: String) = Action {
    Async {
      flow {
        val answers = Answer.findByQuestionId(questionId)()
        val enumeratorsFuture = Future.sequence(answers.map { answer => HistoryActor.getLiveEnumerator(answer._id.stringify) })
        val enumerators = enumeratorsFuture()
        val combinedEnums = Enumerator.interleave(enumerators)

        Ok.feed(combinedEnums.map(_.toJson).map { x => println(x); x }.through(EventSource()).andThen(Enumerator.eof[String])).as("text/event-stream")
      }
    }
  }

  def history(questionId: String, startTimestamp: Long, interval: String) = Action {
    Async {
      val f = flow {
        val answers = Answer.findByQuestionId(questionId)()
        val start = new DateTime(startTimestamp)
        val history = AnswerHistory.find(start, interval, questionId)()
        Ok(JsArray(history.map(_.toJson))).as("application/json")
      }
      f.fallbackTo(Future(BadRequest("Failed to process the history")))
    }
  }
}
