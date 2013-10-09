package controllers

import play.api.mvc.Action
import play.api.mvc.Controller
import models.Question
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import play.api.libs.json.JsArray
import java.net.Socket
import java.io.PrintWriter
import java.util.Date
import play.api.libs.ws.WS
import java.net.URL
import java.net.URI
import java.util.Date
import org.joda.time.DateTime
import play.api.libs.json.Json

object QuestionsCtrl extends Controller {

  def questionsPage = Action {
    Ok(views.html.questions())
  }

  def questions = Action.async {
      flow {
        val questions = Question.findAll()()
        Ok(JsArray(questions.map(_.toJson)))
      }
  }

  def tsdbOutputToJson(output: String) = {
    output.split(" ") match {
      case Array(_, date, voteCount, answerIdTag) =>
        val answerId = answerIdTag.split("=", 2)(1)
        Json.obj(
          "voteCount" -> voteCount,
          "date" -> date,
          "answerId" -> answerId)
    }
  }
}