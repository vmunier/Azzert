package controllers

import play.api.mvc.Action
import play.api.mvc.Controller
import models.Question
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import play.api.libs.json.JsArray

object QuestionsCtrl extends Controller {

  def questionsPage = Action {
    Ok(views.html.questions())
  }

  def questions = Action {
    Async {
      flow {
        val questions = Question.findAll()()
        Ok(JsArray(questions.map(_.toJson)))
      }
    }
  }
}