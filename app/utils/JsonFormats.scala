package utils

import play.api.libs.json.Json
import play.modules.reactivemongo.json.BSONFormats._
import models.Question
import models.Answer
import models.Vote
import models.VoteCount

object JsonFormats {
  implicit val answerFormat = Json.format[Answer]
  implicit val questionFormat = Json.format[Question]
  implicit val voteFormat = Json.format[Vote]
  implicit val voteCountFormat = Json.format[VoteCount]
}