package controllers

import global.Global
import play.api._
import play.api.mvc._

object Application extends Controller {

  def index(any: String = "") = Action {
    models.Autocomplete.initialize()
    Ok(views.html.main())
  }
}