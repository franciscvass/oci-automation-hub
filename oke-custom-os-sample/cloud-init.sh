#!/bin/bash

# Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

# ------------------------------
# This script is intended to be used as part of a 
# custom image build process for OKE.

# PLEASE NOTE, that Oracle, and specifically OKE, 
# cannot offer official support for these scripts. 
# You must provide your own validation and testing 
# in non-production environments.

set -e
set -o pipefail

kubernetes_version="1.34.0"

### DO NOT EDIT BELOW THIS LINE ###

oke_repo_version="${kubernetes_version%.*}"
oci_region=$(curl -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | grep "canonicalRegionName" | sed -E 's/.*"([^"]+)".*/\1/')

function yum_repo_setup() {
  local repo=$(cat <<'EOL'
[oke-packages]
baseurl = https://odx-oke.objectstorage.canonicalRegionName.oci.customer-oci.com/n/odx-oke/b/okn-repositories/o/prod/yum/kubernetes/oke_repo_version/os/$releasever/$basearch
gpgcheck = 0
repo_gpgcheck = 0
name = 'Oracle $releasever Container Engine for Kubernetes Nodes ($basearch)'
EOL
)
  echo "$repo" > /etc/yum.repos.d/oke-packages.repo
  sed -i "s/oke_repo_version/$oke_repo_version/g" /etc/yum.repos.d/oke-packages.repo
  sed -i "s/canonicalRegionName/$oci_region/g" /etc/yum.repos.d/oke-packages.repo
  echo "$(date) Yum repos: $(ls -m /etc/yum.repos.d)"
  yum repolist
}

mkdir -p /etc/rpm
RPM_SPEC=/etc/rpm/macros.verify
### add override to OSMS to enable oke_node repo
echo "Checking if OSMS plugin is enabled in this instance.."
OSMS_PLUGIN_CONF_PATH="/etc/yum/pluginconf.d/osmsplugin.conf"
OSMS_ENABLED=0
if [ -e "$OSMS_PLUGIN_CONF_PATH" ]; then
  OSMS_ENABLED=$(awk -F ' *= *' -v k="enabled" '/^[^#]/ && $1 == k {print $2}' /etc/yum/pluginconf.d/osmsplugin.conf)
fi
echo "$(date) Creating OSMS override for oke-packages repo.."
mkdir -p /etc/oracle-cloud-agent/plugins/osms/
echo "oke-packages.repo" >> /etc/oracle-cloud-agent/plugins/osms/ignored_repos.conf
if [ "$OSMS_ENABLED" -eq 1 ]; then
  echo "$(date) OSMS plugin is enabled in this instance, restart oracle-cloud-agent.service"
  systemctl restart oracle-cloud-agent.service
fi
# disable rpm digest check to allow package installation without sha256 digest
echo "%_pkgverify_level none" > $RPM_SPEC

mkdir -p /etc/yum.repos.d
yum_repo_setup
yum install -y oci-oke-node-all-$kubernetes_version

sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install oracle-cloud-agent --classic
sudo dnf install -y iscsi-initiator-utils
sudo dnf install -y device-mapper-multipath
sudo systemctl enable --now multipathd

rm -f $RPM_SPEC
