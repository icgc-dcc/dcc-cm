FROM    ubuntu:precise
MAINTAINER Sepehr Mavedati <sepehr.mavedati@oicr.on.ca>

# Versions
ENV CDH_MAJOR 5
ENV CDH_VERSION 5.3.1
ENV MONGODB_VERSION 2.4.1

# Installing Oracle JDK
RUN apt-get update && apt-get install -y python-software-properties
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update && apt-get upgrade -y
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y \
    oracle-java8-installer \
    oracle-java8-set-default
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Cloudera CDH5 APT key and DPKG repositories
RUN apt-get -y install curl ;\
    curl -s http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh/archive.key | apt-key add - ;\
    echo "deb [arch=amd64] http://archive.cloudera.com/cdh$CDH_MAJOR/ubuntu/precise/amd64/cdh precise-cdh$CDH_VERSION contrib\n" > /etc/apt/sources.list.d/cloudera.list ;\
    echo "deb-src http://archive.cloudera.com/cdh$CDH_MAJOR/ubuntu/precise/amd64/cdh precise-cdh$CDH_VERSION contrib" >> /etc/apt/sources.list.d/cloudera.list ;\
    apt-get update

# Installing HBase
RUN apt-get install -y hadoop-hdfs

# Installing HBase
RUN apt-get install -y hbase

# Installing Pig
RUN apt-get install -y pig

# Installing Oozie
RUN apt-get install -y oozie-client

# Installing FUSE
RUN apt-get install -y hadoop-hdfs-fuse && mkdir -p /hdfs/dcc

# Install command-line utils
RUN apt-get install -y \
    vim.tiny \
    git \
    curl \
    tree \
    inetutils-ping \
    sendemail

# Installing MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
RUN apt-get update && apt-get install -y \
    mongodb-10gen=$MONGODB_VERSION

# Create the MongoDB data directory
RUN mkdir -p /data/db

# Remove defaults in preparation for mounting
RUN unlink /etc/hadoop/conf
RUN unlink /etc/hbase/conf
