FROM    ubuntu:precise
MAINTAINER Sepehr Mavedati <sepehr.mavedati@oicr.on.ca>

# Install dependencies
RUN apt-get update && apt-get install -y \
    python \
    python-dev \
    python-pip

# Install Ansible.
RUN pip install ansible

# Install OpenStack Python Libraries.
RUN pip install \
    python-neutronclient \
    python-novaclient

# Install Cloudera Manager API
RUN pip install cm-api

# Disable host key checking for ansible
ENV ANSIBLE_HOST_KEY_CHECKING false

# Define mountable directories.
VOLUME ["/Users"]

# Define working directory.
WORKDIR /Users

# Define default command.
CMD ["bash"]
