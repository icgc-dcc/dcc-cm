# ICGC DCC - Configuration Management

Collection of CM files and automation for DCC operational environments.

## Modules 

### [Ansible](ansible/README.md)
Ansible scripts for provisioning ETL, Portal, Downloader and Submission systems as well as the Hadoop cluster powering these systems. 

Can be used to provision systems on an OpenStack environment or bare metal. 

### [Docker](docker/README.md)
Module for the Docker containers used for provisioning software on docker hosts. Currently not in use for 
production and can be considered experimental. 

Contains docker files for CDH and an Elasticsearch, Logstash, Kibana stack. 

### [IDE](ide/README.md)
Module containing configuration files for IDE development.

### [Terraform](terraform/README.md)
Module for describing infrastrucure as code.
