import sbt._

object Dependencies {
  lazy val scalaTest = Seq(
    "org.scalatest" %% "scalatest" % "3.2.13" % Test,
  )

  val circeVersion = "0.14.1"
  val pureconfigVersion = "0.17.4"
  val catsVersion = "2.9.0"
  val sparkVersion = "3.5.1"

  lazy val core = Seq(
    // cats FP libary
    "org.typelevel" %% "cats-core" % catsVersion,

    // support for JSON formats
    "io.circe" %% "circe-core" % circeVersion,
    "io.circe" %% "circe-generic" % circeVersion,
    "io.circe" %% "circe-parser" % circeVersion,
    "io.circe" %% "circe-literal" % circeVersion,

    // support for typesafe configuration
    "com.github.pureconfig" %% "pureconfig" % pureconfigVersion,

    // logging
    "com.typesafe.scala-logging" %% "scala-logging" % "3.9.2",
    "ch.qos.logback" % "logback-classic" % "1.2.3",

    // spark
    "org.apache.spark" %% "spark-sql" % sparkVersion % Provided

  )
}
