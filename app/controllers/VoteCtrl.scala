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
import org.joda.time.DateTime
import jobs.HistoryActor

object VoteCtrl extends Controller {
  def votes(questionId: String, answerId: String) = Action {
    Async {
      flow {
        val votes = Vote.findByAnswerId(answerId)()
        val json = JsArray(votes.map(_.toJson))
        Ok(json)
      }
    }
  }

  def save(questionId: String, answerId: String, vote: Int) = Action {
    Async {
      flow {
        if (!(vote == -1 || vote == 1)) {
          BadRequest("authorized vote values : -1 or 1")
        } else {
          Answer.find(answerId)().map { answer =>
            println("answer.voteCount : " + answer.voteCount)
            if (answer.voteCount <= 0 && vote == -1) {
              BadRequest("An answer with 0 vote cannot be downvoted")
            } else {
              Answer.incVoteCount(answerId, vote).map { _ =>
                Vote(vote, new DateTime(), BSONObjectID(answerId)).save()
                HistoryActor.signalVoteChanged(answerId)
              }
              Ok((answer.voteCount + vote).toString)
            }
          }.getOrElse(NotFound(s"answer with id $answerId does not exist"))
        }
      }
    }
  }
}