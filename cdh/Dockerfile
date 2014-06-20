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

# Installing Pig
RUN apt-get install -y pig

# Installing Oozie
RUN apt-get install -y oozie-client

# Installing FUSE
RUN apt-get install -y hadoop-hdfs-fuse && mkdir -p /hdfs/dcc

# Install command-line utils
RUN apt-get install -y vim.tiny

# Copy configuration files
#ADD ./etc/ /etc/
#ADD ./root_scripts/ /root/

# Init environment
#RUN cat /root/set_env >> /etc/profile

#RUN unlink /etc/hadoop/conf
#ADD ./hadoop/ /etc/hadoop/conf/

#RUN unlink /etc/hbase/conf
#ADD ./hbase/ /etc/hbase/conf/

#RUN unlink /etc/zookeeper/conf
#ADD ./zookeeper/ /etc/zookeeper/conf/

# Replace placeholders with the actual settings
#RUN sed -i 's/$HOST_ADDRESS/hstation.vanlab.com/g' /etc/hadoop/conf/*
#RUN sed -i 's/$HOST_ADDRESS/hstation.vanlab.com/g' /etc/hbase/conf/*
#RUN sed -i 's/$HOST_ADDRESS/hstation.vanlab.com/g' /etc/zookeeper/conf/*

#RUN sed -i 's/$FS_MOUNT_POINT/\/dfs/g' /etc/hadoop/conf/*
#RUN sed -i 's/$FS_MOUNT_POINT/\/dfs/g' /etc/hbase/conf/*
#RUN sed -i 's/$FS_MOUNT_POINT/\/dfs/g' /etc/zookeeper/conf/*
