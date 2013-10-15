package auth

import scala.concurrent.Future

import reactivemongo.bson.BSONObjectID

trait OAuthInstance {
  def oauthUserId: String
  def userId: String
  def save: Unit

}

object OAuthInstance {
  def apply(provider: String, oauthUserId: String, userId: String) = {
      OAuth.findByProvider(provider).newInstance(oauthUserId, userId)
  }

  def findByOAuthUserId(provider: String, oauthUserId: String): Future[Option[OAuthInstance]] = {
    val oauth = OAuth.findByProvider(provider)
    oauth.findByOAuthUserId(oauthUserId)
  }
}

trait OAuth {
  def provider: String
  def findByOAuthUserId(oauthUserId: String): Future[Option[OAuthInstance]]
  def newInstance(oauthUserId: String, userId: String, _id: BSONObjectID = BSONObjectID.generate): OAuthInstance
}

object OAuth {
  val list: List[OAuth] = List(FacebookAuth, GoogleAuth)

  def findByProvider(provider: String): OAuth = {
    list.find(oauth => oauth.provider == provider).get
  }

}
