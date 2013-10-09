package controllers

import scala.concurrent.ExecutionContext.Implicits.global
import play.api._
import play.api.mvc._

import models.Autocomplete

object AutocompleteCtrl extends Controller {

  def autocomplete(keyword: String) = Action.async {
    Autocomplete.search(keyword).map { result =>
      Ok(result.json).as("application/json")
    } recover {
      case t => BadRequest(t.getMessage)
    }
  }
}
