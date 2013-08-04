package utils

import play.api.libs.json.Json
import play.modules.reactivemongo.json.BSONFormats._
import models.Question
import models.Answer

object JsonFormats {
  implicit val answerFormat = Json.format[Answer]
  implicit val questionFormat = Json.format[Question]
}