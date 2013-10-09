package utils

import play.api.libs.json.Json
import play.modules.reactivemongo.json.BSONFormats._
import models.Question
import models.Answer
import models.Vote
import models.AnswerHistory
import models.User
import auth.GoogleAuth
import auth.FacebookAuth

object JsonFormats {
  implicit val answerFormat = Json.format[Answer]
  implicit val questionFormat = Json.format[Question]
  implicit val voteFormat = Json.format[Vote]
  implicit val userFormat = Json.format[User]
  implicit val googleAuthFormat = Json.format[GoogleAuth]
  implicit val facebookAuthFormat = Json.format[FacebookAuth]
  implicit val answerHistoryFormat = Json.format[AnswerHistory]
}