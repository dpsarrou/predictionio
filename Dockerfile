# Download pio
FROM appropriate/curl as pio_download
ARG PIO_VERSION=0.12.1
RUN curl -L http://apache.forthnet.gr/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}-bin.tar.gz | tar xz -C /tmp \
    && mv /tmp/PredictionIO-${PIO_VERSION}/ /tmp/pio/

# Download spark
FROM appropriate/curl as spark_download
ARG SPARK_VERSION=2.1.1
RUN curl -L http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz | tar xz -C /tmp \
    && mv /tmp/spark-${SPARK_VERSION}-bin-hadoop2.6 /tmp/spark

# Download jdbc driver
FROM appropriate/curl as jdbc_download
ARG JDBC_PGSQL_VERSION=42.2.2
RUN curl -L https://jdbc.postgresql.org/download/postgresql-${JDBC_PGSQL_VERSION}.jar -o /tmp/postgresql.jar

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

# Install prediction io
COPY --from=pio_download /tmp/pio/ ${PIO_HOME}

# install spark
COPY --from=spark_download /tmp/spark ${PIO_HOME}/vendors/spark

# install postgresql jdbc driver
COPY --from=jdbc_download /tmp/postgresql.jar ${PIO_HOME}/vendors/postgresql.jar

# configure the environment
COPY config/pio-env.sh /opt/pio/conf/pio-env.sh
COPY config/pio_events.sh /etc/service/pio_events
COPY config/pio_app.sh /etc/service/pio_app

RUN mkdir -p /app
WORKDIR /app

CMD /etc/service/pio_events