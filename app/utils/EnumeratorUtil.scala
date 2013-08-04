package utils

import scala.concurrent.ExecutionContext.Implicits.global
import play.api.libs.iteratee.Enumerator
import play.api.libs.iteratee.Iteratee
import play.api.libs.concurrent.Promise
import scala.concurrent.Future
import play.api.libs.iteratee.Input
import scala.concurrent.duration.DurationInt

object EnumeratorUtil {
  def emptyFlow[E]: Enumerator[E] = Enumerator.checkContinue0 {
    val generator = () => Promise.timeout(Input.Empty, 5.seconds)
    new Enumerator.TreatCont0[E] {
      def apply[A](loop: Iteratee[E, A] => Future[Iteratee[E, A]], k: Input[E] => Iteratee[E, A]) = generator().flatMap { e =>
        loop(k(e))
      }
    }
  }
}