package models

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import scala.concurrent.duration._
import play.api.Play
import play.api.Play.current
import play.api.libs.ws.WS
import play.api.libs.ws.Response
import play.api.libs.json._
import java.net.URL
import utils.AzzertException
import play.api.libs.ws.WS.WSRequestHolder
import java.io.File

object Autocomplete {

  val elasticsearchHost = "http://localhost:9200"

  private def elasticsearchRequest(queryString: String, request: WSRequestHolder => Future[Response]) = {
    request(WS.url(s"$elasticsearchHost/$queryString").withTimeout(10.seconds.toMillis.toInt)).flatMap {
      case response if response.status == 200 =>
        Future.successful(response)
      case response =>
        Future.failed(new AzzertException(s"Response error from elasticsearch : ${response.status} ${response.statusText}"))
    }
  }

  def search(keyword: String): Future[Response] = {
    val body: JsValue = Json.obj(
      "query" -> Json.obj(
        "multi_match" -> Json.obj(
          "query" -> keyword,
          "fields" -> Json.arr("question.autocomplete", "answers.autocomplete")
        )
      )
    )

    elasticsearchRequest("/autocomplete/questions/_search", _.post(body))
  }

  def save(question: Question, answers: Seq[Answer]): Future[Response] = {
    val questionId = question._id.stringify
    val body: JsValue = Json.obj(
      "questionId" -> questionId,
      "question" -> question.name,
      // the pipe has no meaning, it is just here to visually separate each answers
      "answers" -> answers.map(_.name).mkString(" | "))

      elasticsearchRequest(s"/autocomplete/questions/$questionId", _.post(body))
  }

  def initialize(): Future[Response] = {
    val file = new File("conf/initialize-autocomplete.json")
    elasticsearchRequest("/autocomplete", _.put(file))
  }
}
