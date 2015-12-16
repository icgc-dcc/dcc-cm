FROM ubuntu:14.04
MAINTAINER ICGC <dcc-support@icgc.org>

RUN apt-get update
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN apt-get install oracle-java8-installer -y
RUN apt-get install oracle-java8-set-default

RUN apt-get install curl -y

#
# Install Elasticsearch
#
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
RUN echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
RUN apt-get update
RUN apt-get -y install elasticsearch
RUN service elasticsearch restart
RUN update-rc.d elasticsearch defaults 95 10


#
# Install Kibana
#

RUN groupadd -g 999 kibana
RUN useradd -u 999 -g 999 kibana

RUN cd ~; wget -P /tmp/ https://download.elastic.co/kibana/kibana/kibana-4.3.0-linux-x64.tar.gz
RUN tar xvf /tmp/kibana-*.tar.gz -C /tmp/
RUN mkdir -p /opt/kibana
RUN cp -R /tmp/kibana-4*/* /opt/kibana/
RUN chown -R kibana: /opt/kibana

RUN cd /etc/init.d && curl -o \
	kibana https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/fc5025c3fc499ad8262aff34ba7fde8c87ead7c0/kibana-4.x-init
RUN cd /etc/default && curl -o \
	kibana https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/fc5025c3fc499ad8262aff34ba7fde8c87ead7c0/kibana-4.x-default
RUN chmod +x /etc/init.d/kibana; update-rc.d kibana defaults 96 9; service kibana start

#
# Install Nginx
#
RUN apt-get install nginx apache2-utils -y