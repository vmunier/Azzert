package auth

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

import play.api.libs.json.Json
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.modules.reactivemongo.json.collection.JSONCollection
import reactivemongo.api.indexes.Index
import reactivemongo.api.indexes.IndexType
import reactivemongo.bson.BSONObjectID
import utils.JsonFormats.googleAuthFormat
import utils.Mongo.db

case class GoogleAuth(oauthUserId: String, userId: String, _id: BSONObjectID = BSONObjectID.generate) extends OAuthInstance {

  def save() = {
    GoogleAuth.collection.insert(this)
  }
}

object GoogleAuth extends OAuth {
  val provider = "google"
  def collection: JSONCollection = db.collection[JSONCollection]("google-auth")

  def newInstance(oauthUserId: String, userId: String, _id: BSONObjectID = BSONObjectID.generate): OAuthInstance = {
    GoogleAuth(oauthUserId, userId: String, _id)
  }

  collection.indexesManager.ensure(
    Index(List("oauthUserId" -> IndexType.Ascending), unique = false))

  def findByOAuthUserId(oauthUserId: String): Future[Option[GoogleAuth]] = {
    collection.find(Json.obj("oauthUserId" -> oauthUserId)).one[GoogleAuth]
  }
}



