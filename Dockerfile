# Download pio
FROM appropriate/curl as pio_download
ARG PIO_VERSION
RUN curl -L http://apache.forthnet.gr/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}-bin.tar.gz -o /tmp/apache-predictionio.tar.gz

# Download spark
FROM appropriate/curl as spark_download
ENV SPARK_VERSION 2.1.1
RUN curl -L http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz -o /tmp/spark.tar.gz

# Download jdbc driver
FROM appropriate/curl as jdbc_download
ENV JDBC_PGSQL_VERSION 42.2.2
RUN curl -L https://jdbc.postgresql.org/download/postgresql-${JDBC_PGSQL_VERSION}.jar -o /tmp/postgresql-${JDBC_PGSQL_VERSION}.jar

# Download scala
FROM appropriate/curl as scala_download
RUN curl -L https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.deb -o /tmp/scala.deb

# Prepare the base image with all the tools
FROM phusion/baseimage as base
RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl openjdk-8-jdk libgfortran3 python-pip python3-pip git wget unzip vim ca-certificates

# Install maven
RUN apt-get install -y maven
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install scala
COPY --from=scala_download /tmp/scala.deb /tmp/scala.deb
RUN dpkg -i /tmp/scala.deb

# Install python dependencies
RUN pip install --upgrade pip
RUN pip install setuptools
RUN pip install wheel predictionio

RUN rm -rf /etc/service/{cron,syslog-forwarder,syslog-ng,sshd}

# The actual pio image
FROM base as pio
ENV PIO_HOME /opt/pio
ENV PATH=${PIO_HOME}/bin:$PATH

ARG PIO_VERSION
COPY --from=pio_download /tmp/apache-predictionio.tar.gz /tmp/apache-predictionio.tar.gz
RUN tar zxvf /tmp/apache-predictionio.tar.gz -C /tmp \
    && mkdir ${PIO_HOME} && mv -T /tmp/PredictionIO-${PIO_VERSION}/ ${PIO_HOME} \
    && mkdir ${PIO_HOME}/vendors

# install spark
ENV SPARK_VERSION 2.1.1
COPY --from=spark_download /tmp/spark.tar.gz /tmp/spark.tar.gz
RUN tar -xvzf /tmp/spark.tar.gz -C ${PIO_HOME}/vendors

# install postgresql jdbc driver
ENV JDBC_PGSQL_VERSION 42.2.2
COPY --from=jdbc_download /tmp/postgresql-${JDBC_PGSQL_VERSION}.jar ${PIO_HOME}/vendors/postgresql-${JDBC_PGSQL_VERSION}.jar

# install the template engine
ARG PIO_ENGINE=''
ARG PIO_APP_NAME=''
RUN if [ "x$PIO_ENGINE" != "x" -a "x$PIO_APP_NAME" != "x" ] ; then mkdir /apps/ && git clone ${PIO_ENGINE} /apps/${PIO_APP_NAME} && cd /apps/${PIO_APP_NAME}/ && pio build ; fi

# Configure the template engine for the app
ARG PIO_APP_KEY=''
RUN if [ "x$PIO_APP_KEY" != "x" ]; then cd /apps/$PIO_APP_NAME/ \
    && sed -i "s/INVALID_APP_NAME/$PIO_APP_NAME/" engine.json ; fi;

# Configure PIO settings
COPY config/pio-env.sh /opt/pio/conf/pio-env.sh
ENV PIO_APP_NAME $PIO_APP_NAME
ENV PIO_APP_KEY $PIO_APP_KEY
COPY config/pio_app.sh /etc/service/pio_app
COPY config/pio_events.sh /etc/service/pio_events