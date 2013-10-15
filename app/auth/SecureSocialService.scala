package auth

import java.util.concurrent.TimeUnit.SECONDS

import scala.concurrent.Await
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import scala.concurrent.duration.Duration

import akka.dataflow.DataflowFuture
import akka.dataflow.flow
import models.User
import play.api.Application
import securesocial.core.Identity
import securesocial.core.IdentityId
import securesocial.core.UserServicePlugin
import securesocial.core.providers.Token

class SecureSocialService(application: Application) extends UserServicePlugin(application) {
  def find(id: IdentityId): Option[Identity] = {
    val futureIdentity = OAuthInstance.findByOAuthUserId(id.providerId, id.userId).flatMap { maybeInstance =>
      maybeInstance.map { instance =>
        User.find(instance.userId).map { maybeUser =>
          maybeUser.map(user => user.wrapToIdentity(id))
        }
      }.getOrElse(Future(None))
    }

    Await.result(futureIdentity, Duration(10, SECONDS))
  }

  def save(userIdentity: Identity): Identity = {
    println("!! in save(userIdentity: Identity) dlkdlkdfklfkldfl")
    val identity = userIdentity.identityId
    OAuthInstance.findByOAuthUserId(identity.providerId, identity.userId).map { found =>
      val needsCreation = found.isEmpty
      if (needsCreation) {
        flow {
          val email: String = userIdentity.email.getOrElse("")
          // maybe a user already exists with that email
          val user = User.findByEmail(email)().getOrElse {
            // if not, create a new user
            val newUser = User(email, userIdentity.firstName, userIdentity.lastName, userIdentity.fullName)
            newUser.save()
            newUser
          }
          OAuthInstance(identity.providerId, identity.userId, user._id.stringify).save
        }
      }
    }
    userIdentity
  }

  // Empty implementations because the UsernamePassword provider is not used
  def save(token: Token) = ???
  def findToken(token: String): Option[Token] = ???
  def deleteToken(uuid: String) = ???
  def deleteTokens() = ???
  def deleteExpiredTokens() = ???
  def findByEmailAndProvider(email: String, providerId: String): Option[Identity] = ???
}
