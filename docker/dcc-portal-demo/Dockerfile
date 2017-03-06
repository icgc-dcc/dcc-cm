#     ____  ____________   ____             __        __   ____                     
#    / __ \/ ____/ ____/  / __ \____  _____/ /_____ _/ /  / __ \___  ____ ___  ____ 
#   / / / / /   / /      / /_/ / __ \/ ___/ __/ __ `/ /  / / / / _ \/ __ `__ \/ __ \
#  / /_/ / /___/ /___   / ____/ /_/ / /  / /_/ /_/ / /  / /_/ /  __/ / / / / / /_/ /
# /_____/\____/\____/  /_/    \____/_/   \__/\__,_/_/  /_____/\___/_/ /_/ /_/\____/ 
#                                                                                  
# Banner @ http://goo.gl/WVEzIZ
#
# A docker container created from this Dockerfile is located following the link https://hub.docker.com/r/icgcdcc/dcc-portal-demo/

FROM java:8-jre
MAINTAINER ICGC <dcc-support@icgc.org>

#
# Configuration
#
ENV DCC_HOME /opt/dcc
RUN useradd -m dcc &&  mkdir -p $DCC_HOME
WORKDIR $DCC_HOME

#
# Elasticsearch installation
#
ENV ES_SKIP_SET_KERNEL_PARAMETERS true
ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.1.2.deb $DCC_HOME/elasticsearch.deb
RUN \
  dpkg -i -E --force-depends $DCC_HOME/elasticsearch.deb && \
  rm $DCC_HOME/elasticsearch.deb && \
  echo "elasticsearch - nofile 65535" >> /etc/security/limits.d/elasticsearch.conf && \
  echo "elasticsearch - memlock unlimited" >> /etc/security/limits.d/elasticsearch.conf && \
  echo "session required pam_limits.so" >> /etc/pam.d/common-session && \
  echo "session required pam_limits.so" >> /etc/pam.d/common-session-noninteractive && \
  echo "script.disable_dynamic: false" >> /etc/elasticsearch/elasticsearch.yml && \
  sed -i.bak s/^.*ES_HEAP_SIZE=.*$/ES_HEAP_SIZE=8g/ /etc/default/elasticsearch && \
  sed -i.bak -e 's|^.*DATA_DIR=.*$|DATA_DIR=/mnt/dcc_data/elasticsearch|' /etc/default/elasticsearch && \
  rm /etc/default/elasticsearch.bak

#
# Download server installation
#
ADD https://artifacts.oicr.on.ca/artifactory/dcc-release/org/icgc/dcc/dcc-download-server/[RELEASE]/dcc-download-server-[RELEASE]-dist.tar.gz $DCC_HOME/dcc-download-server-dist.tar.gz
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb && \
  tar xf dcc-download-server-dist.tar.gz && \
  rm dcc-download-server-dist.tar.gz && \
  mv dcc-download-server-* dcc-download-server && \
  sed -i.bak s/spring.profiles.active=.*$/spring.profiles.active=development/ $DCC_HOME/dcc-download-server/conf/wrapper.conf && \
  rm $DCC_HOME/dcc-download-server/conf/wrapper.conf.bak
COPY conf/download.yml $DCC_HOME/dcc-download-server/conf/application.yml

#
# Download import utility installation
#
ADD https://artifacts.oicr.on.ca/artifactory/dcc-release/org/icgc/dcc/dcc-download-import/[RELEASE]/dcc-download-import-[RELEASE].jar $DCC_HOME/dcc-download-import.jar


#
# Portal installation
#
ADD https://artifacts.oicr.on.ca/artifactory/dcc-release/org/icgc/dcc/dcc-portal-server/[RELEASE]/dcc-portal-server-[RELEASE]-dist.tar.gz $DCC_HOME/dcc-portal.tar.gz
RUN \
  tar xf dcc-portal.tar.gz && \
  rm dcc-portal.tar.gz && \
  mv dcc-portal-server-* dcc-portal-server && \
  sed -i.bak s/spring.profiles.active=.*$/spring.profiles.active=test/ $DCC_HOME/dcc-portal-server/conf/wrapper.conf && \
  rm $DCC_HOME/dcc-portal-server/conf/wrapper.conf.bak && \
  sed -i.bak '2iunset MAIL' $DCC_HOME/dcc-portal-server/bin/dcc-portal-server && \
  rm $DCC_HOME/dcc-portal-server/bin/dcc-portal-server.bak
COPY conf/portal.yml $DCC_HOME/dcc-portal-server/conf/application.yml

#
# Post-installation
#
RUN \ 
  mkdir $DCC_HOME/bin && \
  chown -R dcc:dcc $DCC_HOME && \
  rm -r /var/log/elasticsearch /tmp/* /var/lib/apt/lists/*

ENTRYPOINT ["/opt/dcc/bin/portal.sh"]
COPY bin/portal.sh $DCC_HOME/bin/portal.sh
