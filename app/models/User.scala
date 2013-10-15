package models

import reactivemongo.bson.BSONObjectID
import org.joda.time.DateTime
import play.modules.reactivemongo.json.collection.JSONCollection
import scala.concurrent.Future
import play.api.libs.json.Json
import utils.Mongo._
import utils.JsonFormats.userFormat
import play.modules.reactivemongo.json.BSONFormats.BSONObjectIDFormat
import scala.concurrent.ExecutionContext.Implicits.global
import reactivemongo.api.indexes.Index
import reactivemongo.api.indexes.IndexType
import securesocial.core.Identity
import securesocial.core.OAuth1Info
import securesocial.core.OAuth2Info
import securesocial.core.IdentityId
import securesocial.core.AuthenticationMethod
import securesocial.core.PasswordInfo

case class User(email: String, firstName: String, lastName: String, fullName: String, inscriptionDate: DateTime = new DateTime(),
  _id: BSONObjectID = BSONObjectID.generate) {

  def save() = {
    User.collection.insert(this)
  }

  def wrapToIdentity(identityId: IdentityId): Identity = {
    UserIdentity(identityId, firstName, lastName, fullName, Some(email))
  }

  private case class UserIdentity(identityId: IdentityId, firstName: String, lastName: String, fullName: String, email: Option[String],
    avatarUrl: Option[String] = None, authMethod: AuthenticationMethod = AuthenticationMethod("oauth2"), oAuth1Info: Option[OAuth1Info] = None, oAuth2Info: Option[OAuth2Info] = None, passwordInfo: Option[PasswordInfo] = None) extends Identity
}



object User {
  def collection: JSONCollection = db.collection[JSONCollection]("users")

  def find(_id: String): Future[Option[User]] = {
    collection.find(Json.obj("_id" -> BSONObjectID(_id))).one[User]
  }

  def findByEmail(email: String): Future[Option[User]] = {
    collection.find(Json.obj("email" -> email)).one[User]
  }
}