# ICGC DCC - Ansible

Ansible scripts for provisioning ETL, Portal, Downloader and Submission systems

### Requirements:

#### 1. Install Ansible

Easiest way for MacOSX to get the latest Ansible is using Homebrew:

Note: Ansible version should be at least `1.9`

```bash
$ brew install ansible
```

For other platforms, refer to [Ansible documentation.](http://docs.ansible.com/intro_installation.html)

#### 2. Install Open Stack shade client.

```bash
$ sudo pip install shade
```

They install the required dependencies, but you might need to install additional clients from [here.](http://docs.openstack.org/user-guide/content/install_clients.html)


#### 3. Provide the settings.

Create a new file, `vars/main.yml` using `vars/main.yml.template` as template, providing necessary settings.

Furthermore, there are several variables that need to be set in: `group_vars/vars/main.yml`

* Proxy
 * http_proxy
* External URLs
 * external_submission_url
 * external_docs_url
* Misc
 * icgc_url
* Contact
 * smtp_server
 * sender
 * recipients

#### 4. (Optional) Edit ssh config

Edit `/etc/ssh_config` and add the following to avoid having to accept connecting to each server.

```
Host 10.5.74.*
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
```


### Run

Execute the following command:

You can also execute playbooks individually:

```bash
$ ansible-playbook -i config/hosts submission.yml
```

### Extra Tips and Notes:

#### Ansible in memory inventory

During the running of a playbook, our tasks and roles are configured to add new groups of hosts to the in memory inventory.

For the following explanations, we will use the first few lines of the `download.yml` playbook as an example:
```
- include: tasks/setup.yml group=hadoop-master:hadoop-worker:download
- include: tasks/setup-existing.yml group=hadoop-master:hadoop-worker:download
```

* `all_instances` - All hosts from all groups that are either being provisioned and/or used are lumped together into a single host group.
The purpose of this group is so we can write out the hostname and ips of every server to the `/etc/hosts` file of every server. This way, 
every server, knows about every other server.

* We do some parsing of host names to generate groups of related servers based on the the way they are named. For example,
in the `hadoop-worker` group we have the hostnames `dcc-hadoop-worker-[1:2]`. A group called `hadoop_worker` is created containing 
the hosts `dcc-hadoop-worker-1` and `dcc-hadoop-worker-2`. The utility of this becomes more obvious when you look at groups and playbooks that use
a wider array of servers with different purposes, such as the `portal.yml` playbook with the `portal` host group. 


#### Data

The playbooks do not load any production data into either Elasticsearch or Postgres. This
is left up to the user. 

#### Hosts
Ensure that the host images for the openstack instances provide enough resources. 
The hosts provisioned by the playbook in testing had the following configuration

|   |   |
|---|---|
| OS | Ubuntu 12.04 |
| RAM | 16GB |
| # CPU | 8 |
| Storage | 160GB |

#### HDFS & Spark

It is a good idea that once the hadoop cluster is provisioned, that you inspect the web UI of the NameNode/Master to ensure
the nodes are up and their services are enabled. The created NameNode can easily provision more 
RAM than you provided it, so that is something to be aware of. Also ensure the configuration on the nodes
is not stale.

#### Software
All downloaded software from ICGC comes with install scripts. Should you require a more up to date
version of any of the software, the install script should provide you with the functionality to update
the software. 

Example installing a specific version:
```bash
$ ./install -r 4.0.4
```

### TODOs:

A list can be found [here.](https://jira.oicr.on.ca/browse/DCC-2962)

### Misc

##### Java Install
Installs the latest Oracle Java 8 using PPA repository.

- Create a custom playbook

```
- name: Installs Oracle JDK with PPA
  hosts: all
  gather_facts: no
  sudo: yes
  roles:
    - jdk-ppa
```
- Create a custom hosts file

```
[java]
127.0.0.1
```

- Run the playbook

```
ansible-playbook -i java_hosts java.yml
```
