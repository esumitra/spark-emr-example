import Dependencies._

ThisBuild / organization := "com.example"
ThisBuild / scalaVersion := "2.12.17"
addCompilerPlugin("org.scalameta" % "semanticdb-scalac" % "4.7.8" cross CrossVersion.full)

lazy val root = (project in file(".")).
  settings(
    name := "spark-emr-example",
    scalacOptions ++= Seq(
      "-feature",
      "-deprecation",
      "-unchecked",
      "-language:postfixOps",
      "-language:higherKinds", // HKT required for Monads and other HKT types
      "-Yrangepos", // required for semantic db
    ),
    libraryDependencies ++= Dependencies.core ++ Dependencies.scalaTest,
    Compile / discoveredMainClasses := Seq(), // ignore discovered main classes
    Compile / mainClass := Some("com.example.SparkWordCountApp"),
    assembly / mainClass := Some("com.example.SparkWordCountApp"),
    assembly / assemblyJarName := "spark-emr-example.jar",
    assembly / test := {},
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case "application.conf"            => MergeStrategy.concat
      case x =>
        val oldStrategy = (assembly / assemblyMergeStrategy).value
        oldStrategy(x)
    }
  )
