package controllers

import play.api.mvc.Action
import play.api.mvc.Controller
import models.Question
import scala.concurrent.ExecutionContext.Implicits.global
import akka.dataflow._
import models.VoteCount

object VoteCountCtrl extends Controller {
  def voteCount(questionId:String, answerId: String) = Action {
    Async {
      flow {
        val maybeVoteCount = VoteCount.findByAnswerId(answerId)()
        maybeVoteCount.map { voteCount =>
          Ok(voteCount.toJson)
        }.getOrElse(NotFound(s"vote count with answerId $answerId does not exist"))
      }
    }
  }

  def increment(questionId: String, answerId: String, inc: Int) = Action {
    Async {
      flow {
        if (!(inc == -1 || inc == 1)) {
          BadRequest("authorized vote values : -1 or 1")
        } else {
          VoteCount.increment(answerId, inc)
          Ok("")
        }
      }
    }
  }
}