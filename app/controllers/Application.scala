package controllers

import global.Global
import play.api._
import play.api.mvc._
import securesocial.core.SecureSocial

object Application extends Controller {

  def index(any: String = "") = Action { implicit request =>
    SecureSocial.withRefererAsOriginalUrl(Ok(views.html.main()))
  }

  def login(provider: String, refererParam: Option[String]) = Action { implicit request =>
    if ( SecureSocial.currentUser.isDefined ) {
      // if the user is already logged in just redirect to the app
      val to = refererParam.getOrElse("/")

      if ( Logger.isDebugEnabled ) {
        Logger.debug("User already logged in, skipping login page. Redirecting to %s".format(to))
      }
      Redirect(to)
    } else {
      SecureSocial.withRefererAsOriginalUrl(Redirect(s"/authenticate/$provider"), refererParam)
    }
  }
}
