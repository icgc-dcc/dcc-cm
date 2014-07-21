FROM    ubuntu:precise
MAINTAINER Bob Tiernay

# Install dependencies
RUN apt-get update && apt-get install -y python python-dev python-pip python-virtualenv

# Install Ansible.
RUN pip install ansible python-keystoneclient python-neutronclient python-novaclient python-quantumclient

# Disable host key checking for ansible
ENV ANSIBLE_HOST_KEY_CHECKING false

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]
