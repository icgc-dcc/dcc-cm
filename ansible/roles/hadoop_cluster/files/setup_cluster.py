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
config.read("roles/hadoop_cluster/files/cloudera_config.ini")

zookeeper_service_name = "ZOOKEEPER"
hdfs_service_name = "HDFS"
mapred_service_name = "MAPRED"
hbase_service_name = "HBASE"
oozie_service_name = "OOZIE"

# Configuration
service_types_and_names = {
    "ZOOKEEPER": zookeeper_service_name,
    "HDFS": hdfs_service_name,
    "MAPREDUCE": mapred_service_name,
    "HBASE": hbase_service_name,
    "OOZIE": oozie_service_name}

# Cluster name
cluster_name = config.get("CDH", "cluster.name")

# These include hosts that will run NameNode, DataNode, JobTracker, TaskTracker, etc as well as things like gateways and zookeeper nodes
host_list = config.get("CDH", "cluster.hosts").split(',')

cdh_version = "CDH5"
cdh_version_number = "5"

cm_port = 7180
cm_username = "admin"
cm_password = "admin"
cm_service_name = "mgmt"
cm_repo_url = None

reports_manager_host = config.get("SERVICES", "reports_manager_host")
reports_manager_name = "reports_manager"
reports_manager_username = "rman"
reports_manager_password = ""
reports_manager_database_type = "postgresql"

host_username = config.get("CM", "host_username")


def setup_cluster(cm_host, private_key_path):
    # get a handle on the instance of CM that we have running
    api = ApiResource(cm_host, cm_port, cm_username, cm_password, version=9)

    # get the CM instance
    cm = ClouderaManager(api)

    # activate the CM trial license
    try:
        cm.begin_trial()
    except:
        print 'Trial has been used already.'
        pass

    # create the management service
    # TODO check for existence
    service_setup = ApiServiceSetupInfo(name=cm_service_name, type="MGMT")
    try:
        cm.create_mgmt_service(service_setup)
    except:
        pass

    # read private key
    private_key = open(private_key_path, 'rb').read()

    # install hosts on this CM instance
    cmd = cm.host_install(host_username, host_list, private_key=private_key, cm_repo_url=cm_repo_url)
    print "Installing hosts. This will take a while."
    while cmd.success is None:
        sleep(30)
        cmd = cmd.fetch()

    if cmd.success is not True:
        print "cm_host_install failed: " + cmd.resultMessage
        exit(0)

    print "cm_host_install succeeded."

    # first auto-assign roles and auto-configure the CM service
    cm.auto_assign_roles()
    cm.auto_configure()

    # create a cluster on that instance
    cluster = create_cluster(api, cluster_name, cdh_version)

    # add all our hosts to the cluster
    cluster.add_hosts(host_list)

    cluster = api.get_cluster(cluster_name)

    parcels_list = []
    # get and list all available parcels
    print "Available parcels:"
    for p in cluster.get_all_parcels():
        print '\t' + p.product + ' ' + p.version
        if p.version.startswith(cdh_version_number) and p.product == "CDH":
            parcels_list.append(p)

    if len(parcels_list) == 0:
        print "No " + cdh_version + " parcel found!"
        exit(0)

    cdh_parcel = parcels_list[0]
    for p in parcels_list:
        if p.version > cdh_parcel.version:
            cdh_parcel = p

    # download the parcel
    print "Starting parcel download. This might take a while."
    cmd = cdh_parcel.start_download()
    if cmd.success is not True:
        print "Parcel download failed!"
        exit(0)

    # make sure the download finishes
    while cdh_parcel.stage != 'DOWNLOADED':
        sleep(30)
        cdh_parcel = get_parcel(api, cdh_parcel.product, cdh_parcel.version, cluster_name)

    print cdh_parcel.product + ' ' + cdh_parcel.version + " downloaded"

    # distribute the parcel
    print "Starting parcel distribution. This might take a while."
    cmd = cdh_parcel.start_distribution()
    if cmd.success is not True:
        print "Parcel distribution failed!"
        exit(0)

    # make sure the distribution finishes
    while cdh_parcel.stage != "DISTRIBUTED":
        sleep(30)
        cdh_parcel = get_parcel(api, cdh_parcel.product, cdh_parcel.version, cluster_name)

    print cdh_parcel.product + ' ' + cdh_parcel.version + " distributed"

    # activate the parcel
    cmd = cdh_parcel.activate()
    if cmd.success is not True:
        print "Parcel activation failed!"
        exit(0)

    # make sure the activation finishes
    while cdh_parcel.stage != "ACTIVATED":
        sleep(30)
        cdh_parcel = get_parcel(api, cdh_parcel.product, cdh_parcel.version, cluster_name)

    print cdh_parcel.product + ' ' + cdh_parcel.version + " activated"

    # inspect hosts and print the result
    print "Inspecting hosts. This might take a few minutes."

    cmd = cm.inspect_hosts()
    while cmd.success is None:
        sleep(30)
        cmd = cmd.fetch()

    if cmd.success is not True:
        print "Host inspection failed!"
        exit(0)

    print "Hosts successfully inspected: \n" + cmd.resultMessage

    # create all the services we want to add; we will only create one instance
    # of each
    for s in service_types_and_names.keys():
        cluster.create_service(service_types_and_names[s], s)

    # we will auto-assign roles; you can manually assign roles using the
    # /clusters/{clusterName}/services/{serviceName}/role endpoint or by using
    # ApiService.createRole()
    cluster.auto_assign_roles()
    cluster.auto_configure()

    # start the management service
    cm_service = cm.get_service()
    cm_service.start().wait()

    # this will set the Reports Manager database password
    # first we find the correct role
    rm_role = None
    for r in cm.get_service().get_all_roles():
        if r.type == "REPORTSMANAGER":
            rm_role = r

    if rm_role is None:
        print "No REPORTSMANAGER role found!"
        exit(0)

    # then we get the corresponding role config group -- even though there is
    # only once instance of each CM management service, we do this just in case
    # it is not placed in the base group
    rm_role_group = rm_role.roleConfigGroupRef
    rm_rcg = get_role_config_group(api, rm_role.type, rm_role_group.roleConfigGroupName, None)

    # update the appropriate fields in the config
    rm_rcg_config = {"headlamp_database_host": reports_manager_host,
                     "headlamp_database_name": reports_manager_name,
                     "headlamp_database_user": reports_manager_username,
                     "headlamp_database_password": reports_manager_password,
                     "headlamp_database_type": reports_manager_database_type}

    rm_rcg.update_config(rm_rcg_config)

    # restart the management service with new configs
    cm_service.restart().wait()

    # execute the first run command
    print "Executing first run command. This might take a while."
    cmd = cluster.first_run()

    while cmd.success is None:
        sleep(30)
        cmd = cmd.fetch()

    if cmd.success is not True:
        print "The first run command failed: " + cmd.resultMessage()
        exit(0)

    print "First run successfully executed. Cluster has been set up!"


def main(argv):
    cm_host = ''
    private_key_path = ''
    try:
        opts, args = getopt.getopt(argv, "p:c:", ["private_key_path=", "cloudera_manager_host="])
    except getopt.GetoptError:
        print 'cluster_setup.py -p <private_key_path> -c <cloudera_manager_host>'
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-p", "--private_key_path"):
            private_key_path = arg
        elif opt in ("-c", "--cloudera_manager_host"):
            cm_host = arg
    
    print "private_key_path = \"" + private_key_path + "\""
    print "cm_host = \"" + cm_host + "\""
    setup_cluster(cm_host, private_key_path)

if __name__ == "__main__":
    main(sys.argv[1:])
