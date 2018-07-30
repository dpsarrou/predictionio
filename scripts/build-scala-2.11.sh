#!/usr/bin/env bash

git checkout --track sparse-speedup-13.0
export MAHOUT_HOME=/mahout

mvn clean package -DskipTests -Phadoop2 -Dspark.version=2.1.1 -Dscala.version=2.11.11 -Dscala.compat.version=2.11

echo "Make sure to put the custom repo in the right place for your machine!"
echo "This location will have to be put into the Universal Recommenders build.sbt"

mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/hdfs/target/mahout-hdfs-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-hdfs -Dversion=0.13.0
mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/math/target/mahout-math-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-math -Dversion=0.13.0
mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/math-scala/target/mahout-math-scala_2.11-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-math-scala_2.11 -Dversion=0.13.0
mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/spark/target/mahout-spark_2.11-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-spark_2.11 -Dversion=0.13.0
