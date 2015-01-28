# Copyright (c) 2014 The Ontario Institute for Cancer Research. All rights reserved.
#
# This program and the accompanying materials are made available under the terms of the GNU Public License v3.0.
# You should have received a copy of the GNU General Public License along with                                  
# this program. If not, see <http://www.gnu.org/licenses/>.                                                     
#                                                                                                               
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY                           
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES                          
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT                           
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,                                
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED                          
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;                               
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER                              
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN                         
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from cm_api.api_client import ApiResource
from cm_api.endpoints.clusters import create_cluster
from cm_api.endpoints.parcels import get_parcel
from cm_api.endpoints.cms import ClouderaManager
from cm_api.endpoints.services import ApiServiceSetupInfo
from cm_api.endpoints.role_config_groups import get_role_config_group
from time import sleep
import sys
import yaml
import getopt
import ConfigParser

# Prep for reading config props from external file
config = ConfigParser.ConfigParser()
config.read("roles/hadoop_node/files/cloudera_config.ini")

zookeeper_service_name = "ZOOKEEPER"
hdfs_service_name = "HDFS"
mapred_service_name = "MAPRED"
hbase_service_name = "HBASE"
oozie_service_name = "OOZIE"

# Cluster name
cluster_name = config.get("CDH", "cluster.name")

cm_port = 7180
cm_username = "admin"
cm_password = "admin"

host_username = config.get("CM", "host_username")

def configure_host(cm_host, private_key_path, hostname):

    # get a handle on the instance of CM that we have running
    api = ApiResource(cm_host, cm_port, cm_username, cm_password, version=9)

    # get the CM instance
    cm = ClouderaManager(api)

    # read private key
    private_key = open(private_key_path, 'rb').read()

    # install hosts on etl-main
    cmd = cm.host_install(host_username, [hostname], private_key=private_key, cm_repo_url=None)
    print "Installing hostname. This will take a while."
    while cmd.success is None:
        sleep(30)
        cmd = cmd.fetch()

    if cmd.success is not True:
        print "cm_host_install failed: " + cmd.resultMessage
        exit(0)

    print "cm_host_install succeeded."

    cluster = api.get_cluster(cluster_name)

    print "adding hostname to cluster"
    cluster.add_hosts([hostname])

    print "adding gateway role to hostname for hbase, hdfs and mapreduce"

    # install HDFS client on etl main node so it can access HDFS
    hdfs_service = cluster.get_service(hdfs_service_name)
    hdfs_service.create_role("{0}-gw-1".format(hdfs_service_name), "GATEWAY", hostname)

    # install MapReduce client on the etl main node so it can run exporter
    mapred_service = cluster.get_service(mapred_service_name)
    mapred_service.create_role("{0}-gw-1".format(mapred_service_name), "GATEWAY", hostname)

    # install HBase client on etl main node
    hbase_service = cluster.get_service(hbase_service_name)
    hbase_service.create_role("{0}-gw-1".format(hbase_service_name), "GATEWAY", hostname)

    print "deploying client configurations"
    cluster.deploy_client_config()

    print "Updating configurations for HBASE"
    # See hbase.dynamic.jars.dir in http://hbase.apache.org/book.html
    config_value = '<property><name>hbase.dynamic.jars.dir</name><value>/hbase_lib</value></property>'
    hbase_service_config = {
      'hbase_service_config_safety_valve' : config_value
    }
    hbase_service.update_config(hbase_service_config)

    # Edit /etc/hbase/conf/hbase-site.xml in the main ETL node to get around hbase max hfile limitation
    # See: http://stackoverflow.com/questions/24950393/trying-to-load-more-than-32-hfiles-to-one-family-of-one-region
    gw = hbase_service.get_role_config_group("{0}-GATEWAY-BASE".format(hbase_service_name))
    hbase_gw_config = {
      'hbase_client_config_safety_valve' : '<property><name>hbase.mapreduce.bulkload.max.hfiles.perRegion.perFamily</name><value>5000</value></property>'
    }
    gw.update_config(hbase_gw_config)
    # deploy client config again.
    cluster.deploy_client_config()

    print "Updating configurations for MAPREDUCE"
    # Configure compression codecs for TaskTracker, a comma separated list
    config_value = 'org.apache.hadoop.io.compress.DefaultCodec,' \
            'org.apache.hadoop.io.compress.GzipCodec,'\
            'org.apache.hadoop.io.compress.BZip2Codec,'\
            'com.hadoop.compression.lzo.LzoCodec,'\
            'com.hadoop.compression.lzo.LzopCodec,'\
            'org.apache.hadoop.io.compress.SnappyCodec'
    mapred_tt_config = {
      'override_io_compression_codecs' : config_value
    }
    tt = mapred_service.get_role_config_group("{0}-TASKTRACKER-BASE".format(mapred_service_name))
    tt.update_config(mapred_tt_config)

    config_value = 'HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/usr/lib/hadoop/lib/*\n' \
            'JAVA_LIBRARY_PATH=$JAVA_LIBRARY_PATH:/usr/lib/hadoop/lib/native'
    mapred_service_config = {
      'mapreduce_service_env_safety_valve' : config_value
    }
    mapred_service.update_config(mapred_service_config)

    # Now restart the cluster for changes to take effect.
    print "About to restart cluster"
    cluster.stop().wait()
    cluster.start().wait()
    print "Done restarting cluster"

    # deploy client config again.
    cluster.deploy_client_config()


def main(argv):
    cm_host = ''
    private_key_path = ''
    hostname = ''
    try:
        opts, args = getopt.getopt(argv, "p:c:h:", ["private_key_path=", "cloudera_manager_host=", "hostname="])
    except getopt.GetoptError:
        print 'cluster_setup.py -p <private_key_path> -c <cloudera_manager_host> -h <hostname>'
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p", "--private_key_path"):
            private_key_path = arg
        elif opt in ("-c", "--cloudera_manager_host"):
            cm_host = arg
        elif opt in ("-h", "--hostname"):
            hostname = arg
    
    print "private_key_path = \"" + private_key_path + "\""
    print "cm_host = \"" + cm_host + "\""
    print "hostname = \"" + hostname + "\""
    configure_host(cm_host, private_key_path, hostname)


if __name__ == "__main__":
    main(sys.argv[1:])
