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

object Autocomplete {

  val elasticsearchHost = "http://localhost:9200"

  def search(keyword: String): Future[Response] = {
    val body: JsValue = Json.obj(
      "query" -> Json.obj(
        "multi_match" -> Json.obj(
          "query" -> keyword,
          "fields" -> Json.arr("question.autocomplete", "answers.autocomplete")
        )
      )
    )

    WS.url(s"$elasticsearchHost/autocomplete/questions/_search").withTimeout(10.seconds.toMillis.toInt).post(body).flatMap {
      case response if response.status == 200 =>
        Future.successful(response)
      case response =>
        Future.failed(new AzzertException(s"Response error from elasticsearch : ${response.status} ${response.statusText}"))
    }
  }
}
