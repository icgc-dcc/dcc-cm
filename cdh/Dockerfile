FROM    ubuntu:precise
MAINTAINER Bob Tiernay

# Installing Oracle JDK
RUN apt-get update && apt-get install -y python-software-properties
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update && apt-get upgrade -y
RUN echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java6-installer oracle-java6-set-default
ENV JAVA_HOME /usr/lib/jvm/java-6-oracle

# Cloudera CDH4 APT key and DPKG repositories
RUN apt-get -y install curl ;\
    curl -s http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh/archive.key | apt-key add - ;\
    echo "deb [arch=amd64] http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh precise-cdh4.1.2 contrib\ndeb-src http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh precise-cdh4.1.2 contrib" > /etc/apt/sources.list.d/cloudera.list ;\
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
RUN apt-get install -y vim.tiny git curl tree mongodb inetutils-ping

# Remove defaults in preparation for mounting
RUN unlink /etc/hadoop/conf
RUN unlink /etc/hbase/conf
