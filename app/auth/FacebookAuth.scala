package auth

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

import play.api.libs.json.Json
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.modules.reactivemongo.json.collection.JSONCollection
import reactivemongo.api.indexes.Index
import reactivemongo.api.indexes.IndexType
import reactivemongo.bson.BSONObjectID
import utils.JsonFormats.facebookAuthFormat
import utils.Mongo.db

case class FacebookAuth(oauthUserId: String, userId: String, _id: BSONObjectID = BSONObjectID.generate) extends OAuthInstance {

  def save(): Unit = {
    FacebookAuth.collection.insert(this)
  }
}

object FacebookAuth extends OAuth {
  val provider = "facebook"

  def newInstance(oauthUserId: String, userId: String, _id: BSONObjectID = BSONObjectID.generate): OAuthInstance = {
    FacebookAuth(oauthUserId, userId: String, _id)
  }

  def collection: JSONCollection = db.collection[JSONCollection]("facebook-auth")

  collection.indexesManager.ensure(
    Index(List("oauthUserId" -> IndexType.Ascending), unique = false))

  def findByOAuthUserId(oauthUserId: String): Future[Option[FacebookAuth]] = {
    collection.find(Json.obj("oauthUserId" -> oauthUserId)).one[FacebookAuth]
  }
}



