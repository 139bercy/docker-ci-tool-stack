#! /bin/bash

# Parse a support-core plugin -style txt file as specification for jenkins plugins to be installed
# in the reference directory, so user can define a derived Docker image with just :
#
# FROM jenkins
# COPY plugins.txt /plugins.txt
# RUN /usr/local/bin/plugins.sh /plugins.txt
#

set -e

REF=/var/lib/jenkins/plugins
mkdir -p $REF
JENKINS_UC_DOWNLOAD=http://updates.jenkins-ci.org/download

while read spec || [ -n "$spec" ]; do
    plugin=(${spec//:/ });
    [[ ${plugin[0]} =~ ^# ]] && continue
    [[ ${plugin[0]} =~ ^\s*$ ]] && continue
    [[ -z ${plugin[1]} ]] && plugin[1]="latest"
    echo "Downloading ${plugin[0]}:${plugin[1]}"

    curl -sSL -f ${JENKINS_UC_DOWNLOAD}/plugins/${plugin[0]}/${plugin[1]}/${plugin[0]}.hpi -o $REF/${plugin[0]}.jpi
    unzip -qqt $REF/${plugin[0]}.jpi
done  < $1
