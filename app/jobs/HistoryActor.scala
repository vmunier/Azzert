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
import play.api.libs.iteratee.Concurrent
import play.api.libs.iteratee.Enumerator
import collection.mutable
import play.api.libs.iteratee.Concurrent.Channel
import akka.util.Timeout
import akka.pattern.ask
import scala.concurrent.Future

class HistoryActor extends Actor {

  private val answerIds = mutable.HashSet[String]()

  private val sseEnums = mutable.HashMap[String, (Enumerator[AnswerHistory], Channel[AnswerHistory])]()
  private val nbListenersMap = mutable.HashMap[String, Int]()

  override def preStart() = {
    self ! Publish
  }

  def receive() = {
    case VoteChanged(answerId) =>
      answerIds.add(answerId)
    case Subscribe(answerId) =>
      val sseEnum = getOrCreateSseEnum(answerId)
      sender ! sseEnum
    case Unsubscribe(answerId) =>
      unsubscribe(answerId)
    case Publish =>
      for (answerId <- answerIds) {
        publishToLive(answerId)
      }
      answerIds.clear()
  }

  private def unsubscribe(answerId: String) = {
    val nbListeners = incNbListenersMap(answerId, -1)
    if (nbListeners <= 0) {
      sseEnums.remove(answerId)
      nbListenersMap.remove(answerId)
    }
  }

  private def incNbListenersMap(answerId: String, inc: Int): Int = {
    val prevNbListeners = nbListenersMap.getOrElse(answerId, 0)
    val newNbListeners = prevNbListeners + inc
    nbListenersMap.put(answerId, newNbListeners)
    newNbListeners
  }

  private def getOrCreateSseEnum(answerId: String): Enumerator[AnswerHistory] = {
    incNbListenersMap(answerId, 1)
    sseEnums.getOrElse(answerId, createSseEnum(answerId))._1
  }

  private def createSseEnum(answerId: String): (Enumerator[AnswerHistory], Channel[AnswerHistory]) = {
    val (enumerator, channel) = Concurrent.broadcast[AnswerHistory]
    sseEnums.put(answerId, (enumerator, channel))
    (enumerator, channel)
  }

  private def publishToLive(answerId: String) = flow {
    for (answer <- Answer.find(answerId)()) {
      val answerHistory = AnswerHistory(answer.voteCount, new DateTime(), answer._id)
      answerHistory.save()
      for ((_, channel) <- sseEnums.get(answerId)) {
        channel.push(answerHistory)
      }
    }
  }
}

object HistoryActor {
  case class Publish()
  case class VoteChanged(answerId: String)
  case class Subscribe(answerId: String)
  case class Unsubscribe(answerId: String)

  val publishInterval = 1.seconds
  val historyActor = Akka.system.actorOf(Props[HistoryActor])

  def startup() = {
    Akka.system.scheduler.schedule(0.seconds, publishInterval, historyActor, Publish)
  }

  implicit val timeout = Timeout(5.seconds)

  def subscribe(answerId: String): Future[Enumerator[AnswerHistory]] = {
    val untypedResponse = historyActor.ask(Subscribe(answerId))
    untypedResponse.asInstanceOf[Future[Enumerator[AnswerHistory]]]
  }

  def unsubscribe(answerId: String) = {
    historyActor ! Unsubscribe(answerId)
  }

  def signalVoteChanged(answerId: String) = {
    historyActor ! VoteChanged(answerId)
  }
}
