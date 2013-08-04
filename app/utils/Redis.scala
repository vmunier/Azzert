package utils

import play.api.libs.concurrent.Akka
import scala.concurrent.ExecutionContext
import play.api.Play.current

object Redis {
  import java.util.concurrent.Executors
  import concurrent.ExecutionContext
  private val executorService = Executors.newFixedThreadPool(4)

  // Execution context used to avoid blocking on subscribe
  val executionContext = ExecutionContext.fromExecutorService(executorService)

  //implicit val executionContext: ExecutionContext = Akka.system.dispatchers.lookup("akka.actor.redis-pubsub-context")
}

