import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {

  val appName         = "azzert"
  val appVersion      = "1.0-SNAPSHOT"

  val appDependencies = Seq(
    // Add your project dependencies here,
    "com.typesafe.akka" %% "akka-dataflow" % "2.1.2",
    "org.reactivemongo" %% "reactivemongo" % "0.10.0-SNAPSHOT",
    "org.reactivemongo" %% "play2-reactivemongo" % "0.10.0-SNAPSHOT"
  )


  val main = play.Project(appName, appVersion, appDependencies).settings(
    autoCompilerPlugins := true,
    libraryDependencies <+= scalaVersion { v =>
      compilerPlugin("org.scala-lang.plugins" % "continuations" % v) },
    scalacOptions ++= Seq("-P:continuations:enable", "-unchecked", "-deprecation", "-feature")
  )

}
