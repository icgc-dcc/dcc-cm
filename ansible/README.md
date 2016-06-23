# ICGC DCC - Ansible

Ansible scripts for provisioning ETL, Portal, Downloader and Submission systems

### Requirements:

#### 1. Install Ansible

Easiest way for MacOSX to get the latest Ansible is using Homebrew:

```bash
$ brew install ansible
```

For other platforms, refer to [Ansible documentation.](http://docs.ansible.com/intro_installation.html)

#### 2. Install Open Stack clients, Nova and Neutron.

```bash
$ sudo pip install python-novaclient
$ sudo pip install python-neutronclient
```

They install the required dependencies, but you might need to install additional clients from [here.](http://docs.openstack.org/user-guide/content/install_clients.html)

#### 3. Install Cloudera Manager API Python Client

Cloudera provides wrappers for REST API access to manager [here.](https://github.com/cloudera/cm_api)

```bash
$ git clone https://github.com/cloudera/cm_api.git
$ cd cm_api/python
$ python setup.py install
```

#### 4. Provide the settings.

Create a new file, `vars/main.yml` using `vars/main.yml.template` as template, providing necessary settings.

To run Portal successfully, you also need to provide required values for CUD credentials in cud.yml, which is referenced in portal.yml. You can provide your own, or provide Ansible vault password to unlock the provided values:

```bash
$ cd ansible/vars
$ ansible-vault edit cud.yml
```

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

#### 5. (Optional) Edit ssh config

Edit `/etc/ssh_config` and add the following to avoid having to accept connecting to each server.

```
Host 10.5.74.*
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
```


### Run

Execute the following command:

```bash
$ ansible-playbook -i config/hosts site.yml --ask-vault-pass
```

You can also execute playbooks individually:

```bash
$ ansible-playbook -i config/hosts submission.yml
```

### Extra Tips and Notes:

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

#### Hadoop and Cloudera

Be aware that during setup of the hadoop cluster timeouts could occur, such as waiting for the
Cloudera manager to come up. Generally, simply rerunning the playbook should be fine.

The python setup script responsible for obtaining the parcels for CDH however is not idempotent, 
so a failure here might require a rebuild of the cluster.

It is a good idea that once the hadoop cluster is provisioned, that you inspect the manager to ensure
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
