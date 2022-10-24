ARG VARIANT
FROM checkmk/check-mk-free:2.1.0p11

USER root
# This Dockerfile is based on the official Checkmk Dockerfile (Free Edition)
# and adds some additional features for development: 
# - Python 3.9.4
# - Some cmdline tools (htop, git etc.)
# - Python modules for development (black, pylint, pytest etc.)
# - sets CMK default password
# - fix permissions for cmk agent directory
# - bash aliases
# - tmux config

# install python3 on the container
RUN apt-get update
RUN apt-get install -y wget
RUN export DEBIAN_FRONTEND=noninteractive \ 
    && apt-get -y install build-essential libreadline-gplv2-dev libncursesw5-dev \
    libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev
# RUN cd /tmp && wget https://www.python.org/ftp/python/3.9.4/Python-3.9.4.tgz \
#     && tar xzf Python-3.9.4.tgz  \
#     && cd Python-3.9.4 \
#     && ./configure \
#     && make build_all \
#     && make install


RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends jq tree htop vim git telnet file less tmux

# install default python modules. 
# Project dependencies can either be installed in postCreateCommend.sh (using the default Docker image)
# or in the Dockerfile (resulting in a project-wise Docker image), see Ref #6TEtDq
# ADD .devcontainer/requirements.txt /tmp/requirements.txt
# RUN pip3 install -r /tmp/requirements.txt

# Site
ENV CMK_SITE_ID="gitpod"
# default passwort for user checkmkadmin
ENV CMK_PASSWORD="cmk"

# bash aliases for root user
COPY .devcontainer/.root_bash_aliases /root/.bash_aliases
RUN echo ". /root/.bash_aliases" >> /root/.bashrc

# tmux configuration inside container
COPY .devcontainer/.tmux.conf /root/.tmux.conf

# COPY .devcontainer/docker-entrypoint.d /docker-entrypoint.d
RUN bash /docker-entrypoint.sh /bin/true

USER gitpod