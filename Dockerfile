FROM ubuntu:14.04.2

MAINTAINER khiraiwa

# Install Java
RUN \
  apt-get update && \
  apt-get install software-properties-common python-software-properties wget unzip -y && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Add elasticsearch user
RUN \
  mkdir -p /home/elasticsearch/ && \
  groupadd -r elasticsearch && useradd -r -d /home/elasticsearch -s /bin/bash -g elasticsearch elasticsearch && \
  echo 'elasticsearch ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install ElastciSearch
RUN \
  cd /home/elasticsearch && \
  wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/2.0.0/elasticsearch-2.0.0.zip && \
  unzip elasticsearch-2.0.0.zip && \
  rm -f elasticsearch-2.0.0.zip

# Install Marvel plugin
RUN \
  /home/elasticsearch/elasticsearch-2.0.0/bin/plugin install license && \
  /home/elasticsearch/elasticsearch-2.0.0/bin/plugin install marvel-agent

ADD config/elasticsearch.yml /home/elasticsearch/elasticsearch-2.0.0/config/elasticsearch.yml

RUN mkdir -p /data_elasticsearch/
VOLUME ["/data_elasticsearch/"]

# Mount data dir and setup home dir
RUN \
  chown -R elasticsearch:elasticsearch /data_elasticsearch && \
  chown -R elasticsearch:elasticsearch /home/elasticsearch

USER elasticsearch
WORKDIR /home/elasticsearch/elasticsearch-2.0.0

EXPOSE 9200 9300

CMD \
  sudo chown -R elasticsearch:elasticsearch /data_elasticsearch && \
  /home/elasticsearch/elasticsearch-2.0.0/bin/elasticsearch
