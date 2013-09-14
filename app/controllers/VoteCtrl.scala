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
import play.api.mvc.Result
import scala.concurrent.Future
import play.api.mvc.SimpleResult

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

  def save(questionId: String, answerId: String, vote: Int) = Action { request =>
    Async {
      if (!(vote == -1 || vote == 1)) {
        Future(BadRequest("authorized vote values : -1 or 1"))
      } else {
        Answer.find(answerId).flatMap { maybeAnswer =>
          maybeAnswer.map { answer =>
            println("answer.voteCount : " + answer.voteCount)
            if (answer.voteCount <= 0 && vote == -1) {
              Future(BadRequest("An answer with 0 vote cannot be downvoted"))
            } else {
              Vote.findAnswerVoteByIp(answerId, request.remoteAddress).map { maybePreviousVote =>
                maybePreviousVote.map { previousVote =>
                  BadRequest(s"You already voted for this answer at the date ${previousVote.date}")
                }.getOrElse {
                  Answer.incVoteCount(answerId, vote).map { _ =>
                    Vote(vote, new DateTime(), request.remoteAddress, BSONObjectID(answerId)).save()
                    HistoryActor.signalVoteChanged(answerId)
                  }
                  Ok((answer.voteCount + vote).toString)
                }
              }
            }
          }.getOrElse(Future(NotFound(s"answer with id $answerId does not exist")))
        }
      }
    }
  }

  def getVoteByIp(questionId: String, answerId: String) = Action { request =>
    Async {
      Vote.findAnswerVoteByIp(answerId, request.remoteAddress).map { maybePreviousVote =>
        maybePreviousVote.map { previousVote =>
          Ok(previousVote.toJson)
        }.getOrElse {
          NotFound("You did not vote for this answer")
        }
      }
    }
  }
}
