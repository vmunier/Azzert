package controllers

import play.api.mvc.Controller
import play.api.mvc.Action
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import models.Answer
import play.api.libs.json.Json
import utils.JsonFormats._
import play.api.libs.json.JsArray

object AnswerCtrl extends Controller {
  def answers(id: String) = Action {
    Async {
      flow {
        val answers = Answer.findByQuestionId(id)()
        val json = JsArray(answers.map(_.toJson))
        println("json : " + json)
        Ok(json)
      }
    }
  }

  def vote(id: String, vote: Int) = Action {
    if (!(vote == -1 || vote == 1)) {
      BadRequest("authorized vote values : -1 or 1")
    } else {
      Ok("")
    }
  }
}