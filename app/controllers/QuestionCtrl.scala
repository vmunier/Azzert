package controllers

import play.api._
import play.api.mvc._
import models.Question
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import play.api.data.Form
import play.api.data.Forms._
import models.Answer
import reactivemongo.bson.BSONObjectID
import scala.concurrent.Await
import akka.util.Timeout
import scala.concurrent.duration.DurationInt

case class QuestionMapping(name: String, answers: Seq[String])

object QuestionCtrl extends Controller {

  def questionPage() = Action {
    Ok(views.html.question())
  }

  val questionForm: Form[QuestionMapping] = Form(
    mapping(
      "name" -> nonEmptyText,
      "answers" -> seq(nonEmptyText))(QuestionMapping.apply)(QuestionMapping.unapply))

  def question(id: String) = Action {
    Async {
      flow {
        val maybeQuestion = Question.find(id)()

        maybeQuestion.map { question =>
          Ok(question.toJson)
        }.getOrElse(NotFound(s"question with id $id does not exist"))
      }
    }
  }

  val total = 100000

  def save() = Action { implicit request =>
    questionForm.bindFromRequest.fold(
      formWithErrors => BadRequest(""),
      questionMapping => {
        val question = Question(questionMapping.name)
        val answers = questionMapping.answers.map(Answer(_, 0, question._id))
        question.save()
        for (answer <- answers) {
          answer.save()
        }

        Ok("created")
      })
  }
}