FROM phusion/baseimage:0.9.22

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl openjdk-8-jdk libgfortran3 python-pip git wget unzip vim ca-certificates \
    && apt-get clean

ENV PIO_HOME /opt/pio
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# install prediction io
ARG PIO_VERSION
RUN curl -L http://apache.forthnet.gr/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}-bin.tar.gz -o /tmp/apache-predictionio.tar.gz
RUN tar zxvf /tmp/apache-predictionio.tar.gz -C /tmp \
    && mkdir ${PIO_HOME} && mv -T /tmp/PredictionIO-${PIO_VERSION}/ ${PIO_HOME} \
    && mkdir ${PIO_HOME}/vendors

# install spark
ENV SPARK_VERSION 2.1.1
RUN curl -L http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz -o /tmp/spark.tar.gz
RUN tar -xvzf /tmp/spark.tar.gz -C ${PIO_HOME}/vendors

# install postgresql jdbc driver
ENV JDBC_PGSQL_VERSION 42.2.2
RUN curl -L https://jdbc.postgresql.org/download/postgresql-${JDBC_PGSQL_VERSION}.jar -o ${PIO_HOME}/vendors/postgresql-${JDBC_PGSQL_VERSION}.jar

# install scala 2.11.12
RUN curl -L https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.deb -o /tmp/scala.deb
RUN dpkg -i /tmp/scala.deb

# Install python dependencies & upgradePIP (note version 10.* is incompatible)
RUN pip install --upgrade pip==9.0.3 x\
    && pip install setuptools \
    && pip install wheel predictionio


# install maven
RUN apt-get install -y maven

# Build special mahout version (this is needed for universal recommender engine latest version)
RUN git clone https://github.com/actionml/mahout.git /mahout
COPY scripts/build-scala-2.11.sh /mahout/build-scala-2.11.sh
RUN cd /mahout \
    && mvn -T 4C clean package -DskipTests -Phadoop2 -Dspark.version=2.1.1 -Dscala.version=2.11.11 -Dscala.compat.version=2.11
#RUN cd /mahout && ./build-scala-2.11.sh

RUN cd /mahout \
    && mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/hdfs/target/mahout-hdfs-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-hdfs -Dversion=0.13.0 \
    && mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/math/target/mahout-math-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-math -Dversion=0.13.0 \
    && mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/math-scala/target/mahout-math-scala_2.11-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-math-scala_2.11 -Dversion=0.13.0 \
    && mvn deploy:deploy-file -Durl=file:///mahout/.custom-scala-m2/repo/ -Dfile=//mahout/spark/target/mahout-spark_2.11-0.13.0.jar -DgroupId=org.apache.mahout -DartifactId=mahout-spark_2.11 -Dversion=0.13.0

RUN rm -rf /etc/service/{cron,syslog-forwarder,syslog-ng,sshd}

# install the template engine
ARG PIO_ENGINE=''
ARG PIO_APP_NAME=''
RUN if [ "x$PIO_ENGINE" != "x" -a "x$PIO_APP_NAME" != "x" ] ; then mkdir /apps/ && git clone ${PIO_ENGINE} /apps/${PIO_APP_NAME} && cd /apps/${PIO_APP_NAME}/ && pio build ; fi


# Configure the template engine for the app
ARG PIO_APP_KEY=''
RUN if [ "x$PIO_APP_KEY" != "x" ]; then cd /apps/$PIO_APP_NAME/ \
    && sed -i "s/INVALID_APP_NAME/$PIO_APP_NAME/" engine.json ; fi;

# @TODO: move this to the setup of PIO section. Cannot do it know because building the engine takes a lot of time
# And it will fuckup the cache and I will have to wait 1hour again for this step..
# Configure PIO settings
COPY config/pio-env.sh /opt/pio/conf/pio-env.sh

ENV PIO_APP_NAME $PIO_APP_NAME
ENV PIO_APP_KEY $PIO_APP_KEY
COPY config/pio_app.sh /etc/service/pio_app
COPY config/pio_events.sh /etc/service/pio_events
