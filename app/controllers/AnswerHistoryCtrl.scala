package controllers

import global.Global
import play.api.mvc.Controller
import play.api.mvc.Action
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import models.Answer
import play.api.libs.json.Json
import utils.JsonFormats._
import play.api.libs.json.JsArray
import reactivemongo.bson.BSONObjectID
import models.AnswerHistory
import utils.JsonFormats.answerHistoryFormat
import play.api.libs.EventSource
import play.api.libs.iteratee.Enumerator

object AnswerHistoryCtrl extends Controller {
  def sseSession(answerId: String) = Action {
    Async {
      flow {
        val enumerator = AnswerHistory.getEnumerator(answerId)()
        Ok.feed(enumerator.map(Json.toJson(_)).through(EventSource()).andThen(Enumerator.eof[String])).as("text/event-stream")
      }
    }
  }

}