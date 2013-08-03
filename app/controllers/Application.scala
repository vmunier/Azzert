package controllers

import play.api._
import play.api.mvc._

object Application extends Controller {

  def index = Action {
    Redirect(routes.Application.questions);
  }

  def questions = Action {
    Ok(views.html.questions())
  }

  def question(name:String) = Action {
    Ok(views.html.question(name))
  }
}