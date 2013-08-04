package models

object RedisKeys {
  def liveKey(answerId: String) = s"answer:${answerId}:live"
}