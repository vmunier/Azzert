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

object AnswerHistoryCtrl extends Controller {
  def sseQuestionSession(questionId: String) = Action {
    Async {
      flow {
        val answers = Answer.findByQuestionId(questionId)()
        val enumeratorsFuture = Future.sequence(answers.map { answer => AnswerHistory.getEnumerator(answer._id.stringify) })
        val enumerators = enumeratorsFuture()
        val combinedEnums = Enumerator.interleave(enumerators)
        Ok.feed(combinedEnums.map(_.toJson).through(EventSource()).andThen(Enumerator.eof[String])).as("text/event-stream")
      }
    }
  }

}
