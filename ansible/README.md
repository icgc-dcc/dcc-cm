# ICGC DCC - Ansible
===

Ansible scripts for ETL, Portal and Submission systems

### Requirements:

#### 1. Install Ansible

Easiest way for MacOSX to get the latest Ansible is using Homebrew:

```bash
$ brew install ansible
```

For other platfroms, refer to [Ansible documentation.](http://docs.ansible.com/intro_installation.html)

#### 2. Install Open Stack clients, Nova and Neutron.

```bash
$ sudo pip install python-novaclient
$ sudo pip install python-neutronclient
```

They install the required dependencies, but you might need to install addional clients from [here.](http://docs.openstack.org/user-guide/content/install_clients.html)

#### 3. Install Cloudera Manager API Python Client

Cloudera provides wrappers for rest api access to manager [here.](https://github.com/cloudera/cm_api)

```bash
$ git clone https://github.com/cloudera/cm_api.git
$ cd cm_api/python
$ python setup.py install
```

#### 4. Provide the settings.

Create a new file, `vars/main.yml` using `vars/main.yml.template` as template, providing necessary credentials.

#### 5. Edit ssh config

Edit `/etc/ssh_config` and all the following to avoid having to accept connecting to each server.

```
Host 10.5.74.*
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
```

### RUN

Run teh following command:

```bash
$ ansible-playbook -i config/hosts etl_main.yml
```

### Additional Notes

`./portal` needs to be integrated into the rest of the configuration. It was copied from `dcc/dcc-portal/src/main/ansible`
