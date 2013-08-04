package jobs

import global.Global
import scala.concurrent.ExecutionContext.Implicits.global
import redis.clients.jedis.Jedis
import redis.clients.jedis.JedisPool
import play.api.Logger
import play.api.libs.concurrent.Akka
import scala.concurrent.duration.DurationInt
import akka.actor.Actor
import akka.actor.Props
import akka.actor.actorRef2Scala
import play.api.Play.current
import models.Answer
import akka.dataflow._
import models.AnswerHistory
import play.api.libs.json.Json
import utils.JsonFormats._
import org.joda.time.DateTime
import HistoryActor._
import models.RedisKeys._

class HistoryActor extends Actor {

  val jedisPool: JedisPool = Global.sedisPool.underlying
  val client: Jedis = jedisPool.getResource()
  private val answerIds = collection.mutable.HashSet[String]()

  override def preStart() = {
    self ! Publish
  }

  override def postStop() = {
    jedisPool.returnResourceObject(client)
  }

  def receive() = {
    case Subscribe(answerId) =>
      answerIds.add(answerId)
    case Publish =>
      for (answerId <- answerIds) {
        publishToLive(answerId)
      }
      answerIds.clear()
  }

  private def publishToLive(answerId: String) = flow {
    for (answer <- Answer.find(answerId)()) {
      val answerHistory = AnswerHistory(answer.voteCount, new DateTime(), answer._id)
      answerHistory.save()
      println("publish : " + answerHistory)
      client.publish(liveKey(answerId), Json.toJson(answerHistory).toString)
    }
  }
}

object HistoryActor {
  case class Publish()
  case class Subscribe(answerId: String)

  val publishInterval = 3.seconds
  val historyActor = Akka.system.actorOf(Props[HistoryActor])

  def startup() = {
    Akka.system.scheduler.schedule(0.seconds, publishInterval, historyActor, Publish)
  }

  def subscribe(answerId: String) = {
    historyActor ! Subscribe(answerId)
  }
}
