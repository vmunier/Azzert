package controllers

import play.api.mvc.Controller
import play.api.mvc.Action
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import models.Answer
import play.api.libs.json.Json
import utils.JsonFormats._
import play.api.libs.json.JsArray
import models.Vote
import reactivemongo.bson.BSONObjectID

object AnswerCtrl extends Controller {
  def answers(questionId: String) = Action {
    Async {
      flow {
        val answers = Answer.findByQuestionId(questionId)()
        val json = JsArray(answers.map(_.toJson))
        Ok(json)
      }
    }
  }

  def answer(questionId:String, answerId: String) = Action {
    Async {
      flow {
        val maybeAnswer = Answer.find(answerId)()

        maybeAnswer.map { answer =>
          Ok(answer.toJson)
        }.getOrElse(NotFound(s"answer with id $answerId does not exist"))
      }
    }
  }
}