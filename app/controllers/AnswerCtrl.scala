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
import jobs.HistoryActor

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

  def answer(questionId: String, answerId: String) = Action {
    Async {
      flow {
        val maybeAnswer = Answer.find(answerId)()

        maybeAnswer.map { answer =>
          Ok(answer.toJson)
        }.getOrElse(NotFound(s"answer with id $answerId does not exist"))
      }
    }
  }

  def incVoteCount(questionId: String, answerId: String, inc: Int) = Action {
    Async {
      flow {
        if (!(inc == -1 || inc == 1)) {
          BadRequest("authorized vote values : -1 or 1")
        } else {
          Answer.incVoteCount(answerId, inc).map { _ =>
            HistoryActor.signalVoteChanged(answerId)
          }
          Ok("")
        }
      }
    }
  }
}