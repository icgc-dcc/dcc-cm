#!/bin/bash

set -e
#set -x

#
# Constants
#
DCC_HOME=/opt/dcc
DCC_DATA=/mnt/dcc_data
DOWNLOAD_SERVER=https://download.icgc.org

# data.open.tar requires ~ 70GB
# ES index requires ~ 40GB. Indexed = import tar * 3
MIN_FREE_HDD=251658240 # 240 GB in KB

#
# Configuration
#
PROJECT=
SKIP_DOWNLOAD=NO

#
# Functions
#

check_data_dir() {
  echo Checking the data dir configuration...

  # Disable errors checking as grep returns error code when there's no match
  set +e
  echo Checking if data volume is mounted...
  if [[ $(mount | grep -c "$DCC_DATA") -ne 1 ]]; then
    echo No volume was mounted to $DCC_DATA. Exiting...
    exit 1
  fi

  # Reset errors checking back
  set -e
  #check_free_space
}

check_free_space() {
  echo Checking available space...
  free_hdd=$(df --output=avail $DCC_DATA | grep -iv avail)
  if [[ $free_hdd -lt $MIN_FREE_HDD ]]; then
    echo No enough available HDD space on $DCC_DATA volume. Available $free_hdd KB but required at least $MIN_FREE_HDD KB. Exiting...
    exit 1
  fi
}

prepare_dirs() {
  if [[ ! -d $DCC_DATA/tmp ]]; then
    mkdir $DCC_DATA/tmp
  fi

  if [[ ! -d $DCC_DATA/downloads ]]; then
    mkdir $DCC_DATA/downloads
  fi
}

download_imports() {
  cd $DCC_DATA/tmp
  wget --no-check-certificate ${DOWNLOAD_SERVER}/exports/repository.tar.gz 

  if [[ -n $PROJECT ]]; then
    wget --no-check-certificate -O data.open.tar "${DOWNLOAD_SERVER}/exports/data.open.tar?project=$PROJECT"
  else
    wget --no-check-certificate ${DOWNLOAD_SERVER}/exports/data.open.tar
  fi

  wget --no-check-certificate ${DOWNLOAD_SERVER}/exports/release.tar
}

import_files() {
  import_data 
  import_es 
}

alias_repository_index() {
  index_name=$(curl -s 'localhost:9200/_cat/indices?v' | grep icgc-repository | awk '{print $3}')
  echo -n '{"actions":[{"add":{"index":"' >> /tmp/icgc-repo-alias.json
  echo -n ${index_name} >> /tmp/icgc-repo-alias.json
  echo -n '","alias":"icgc-repository"}}]}' >> /tmp/icgc-repo-alias.json
  curl -XPOST 'http://localhost:9200/_aliases' -d@/tmp/icgc-repo-alias.json
}

import_data() {
  echo Importing download data...
  tar -C $DCC_DATA/downloads -xf $DCC_DATA/tmp/data.open.tar
  echo Finished importing download data.
}

import_es() {
  echo Installing Knapsack plugin
  /usr/share/elasticsearch/bin/plugin -url http://bit.ly/29A1hsz -install knapsack
  echo Import Elasticsearch indices...
  service elasticsearch start

  # Give ES some time to start
  sleep 30
  curl -XPOST "http://localhost:9200/_import?path=$DCC_DATA/tmp/repository.tar.gz"
  # Give ES some time to index the repository index
  sleep 60
  alias_repository_index

  if [[ -z $PROJECT ]]; then
    java -jar $DCC_HOME/dcc-download-import.jar -i $DCC_DATA/tmp/release.tar -es es://localhost:9300
  else
    echo "Importing Elasticsearch index for project ${PROJECT}..."
    java -jar $DCC_HOME/dcc-download-import.jar -i $DCC_DATA/tmp/release.tar -es es://localhost:9300 -p $PROJECT
  fi

  # Stop ES to ensure data is written to disk
  service elasticsearch stop
  echo Finished Elasticsearch indices import
}

start_services() {
  service mongodb start
  service elasticsearch start
  su -c "$DCC_HOME/dcc-download-server/bin/dcc-download-server start" dcc
  su -c "$DCC_HOME/dcc-portal-server/bin/dcc-portal-server start  --download.publicServerUrl=http://${1}:9090" dcc
}

usage() {
  echo Usage:
}

#
# Main
#
if [[ "$1" == "import" ]]; then
  shift

  # Start arguments parsing
  while [[ $# -gt 0 ]]; do
    key=$1
    case $key in
      -p|--project)
        shift
        PROJECT=$1
        shift
        ;;
      -s|--skip-download)
        SKIP_DOWNLOAD=YES
        shift
        ;;
      *)
        usage
        exit 1
    esac
  done

  # Check if data volume is mounted and has correct directories layout
  check_data_dir
  prepare_dirs

  # Data download
  if [[ $SKIP_DOWNLOAD == "YES" ]]; then
    echo Skipping data download.
  else
    echo Downloading data...
    download_imports
  fi

  # Data import
  import_files
  echo Finished data import
  exit 0
elif [[ "$1" == "start" ]]; then
  # Override download public server URL
  server_url=$2
  if [[ -z $server_url ]]; then
    echo Missing public hostname of the host
    exit 1
  fi

  chown -R elasticsearch:elasticsearch $DCC_DATA/elasticsearch
  start_services $2
  exec /bin/bash
  exit 0
fi

exec "$@"
