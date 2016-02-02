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

### TODOs:

A list can be found [here.](https://jira.oicr.on.ca/browse/DCC-2962)
