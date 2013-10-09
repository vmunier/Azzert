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
    resolvers += "Sonatype Snapshots" at "http://oss.sonatype.org/content/repositories/snapshots/",
    autoCompilerPlugins := true,
    libraryDependencies <+= scalaVersion { v =>
      compilerPlugin("org.scala-lang.plugins" % "continuations" % v) },
    scalacOptions ++= Seq("-P:continuations:enable", "-unchecked", "-deprecation", "-feature")
  ).dependsOn(RootProject(uri("https://github.com/vmunier/securesocial.git#to-use-with-sbt-dependson")))

}
