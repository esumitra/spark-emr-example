package com.example

import org.apache.spark.sql.SparkSession
import com.typesafe.scalalogging.{LazyLogging}
import com.example.config.{ConfigUtils, SparkAppSettings}
import pureconfig.generic.auto._
import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.SaveMode


/**
  * EMR spark job
  * job parameters: <input file> <output folder>
  * main class: com.example.SparkWordCountApp
  * spark parameters: --conf spark.executor.cores=1 --conf spark.executor.memory=4g --conf spark.driver.cores=1 --conf spark.driver.memory=4g --conf spark.executor.instances=1
  */
object SparkWordCountApp extends LazyLogging {

  def main(args: Array[String]): Unit = {
    // read arguments and configuration
    val Array(infile, outfile) = args
    logger.info("XXXX: Start of Spark EMR Example App")
    implicit val appSettings = ConfigUtils.loadAppConfig[SparkAppSettings]("com.example.spark-word-count-app")
    logger.info(s"settings: $appSettings")

    // create spark session
    lazy val spark = SparkSession
      .builder()
      .appName(appSettings.name)
      .master(appSettings.masterUrl)
      .getOrCreate()

    // load and transform data
    transformData(appSettings, infile, outfile, spark)

    // stop spark session
    spark.stop()
    logger.info("XXXX: Stopped Advanced SparkApp")
  }

  /**
    * batch data processing pipeline
    *
    * @param conf configuration settings
    * @param infile path input file or folder
    * @param outfile path to output folder
    * @param spark spark session
    */
  def transformData(conf: SparkAppSettings, infile: String, outfile: String, spark: SparkSession): Unit  = {
    // enable automatic encoder/decoder for known types
    import spark.implicits._

    // read input as dataset
    val lines = spark.read.textFile(infile)

    // process data
    val counts = lines
      .flatMap(_.split(" "))
      .map(word => (word, 1))
      .groupByKey(_._1)
      .count

    // write output
    counts
      .coalesce(1)
      .write
      .mode(SaveMode.Overwrite)
      .save(outfile) // defaults to parquet format
  }
}
