#!/bin/bash

# Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
# The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/

# OKE INSTALL SCRIPT
# ------------------------------
# This script is intended to be used as part of a 
# custom image build process for OKE.

# PLEASE NOTE, that Oracle, and specifically OKE, 
# cannot offer official support for these scripts. 
# You must provide your own validation and testing 
# in non-production environments.

set -xe
set -o pipefail

function has_api_server() {
  if [[ -n "$(curl --fail --silent --retry-delay 1 --retry 5 -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/ansible_args | base64 -d | jq .k8s_apiserver_addr)" ]]; then
    return 0
  elif [ -n "$(curl --fail --silent --retry-delay 1 --retry 5 -H "Authorization: Bearer Oracle" -L0 http://[fd00:c1::a9fe:a9fe]/opc/v2/instance/metadata/ansible_args | base64 -d | jq .k8s_apiserver_addr)" ]; then
    return 0
  fi
  return 1
}

function restart_crio() {
  image_name=$(curl --fail --silent --retry-delay 1 --retry 5 -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke-image-name)
  if [[ -z "$image_name" ]]; then
    image_name=$(curl --fail --silent --retry-delay 1 --retry 5 -H "Authorization: Bearer Oracle" -L0 http://[fd00:c1::a9fe:a9fe]/opc/v2/instance/metadata/oke-image-name)
  fi
  if [[ -n "$image_name" ]] && [[ "$image_name" == "Oracle-Linux-7.9"* ]] && [[ "$image_name" == *"OKE-1.30.10"* ]]; then
    systemctl restart crio
  fi
}

# Allow user to specify arguments through custom cloud-init
while [[ $# -gt 0 ]]; do
  key="$1"
  case "$key" in
    --kubelet-extra-args)
      export KUBELET_EXTRA_ARGS="$2"
      shift
      shift
      ;;
    --cluster-dns)
      export CLUSTER_DNS="$2"
      shift
      shift
      ;;
    --apiserver-endpoint)
      export APISERVER_ENDPOINT="$2"
      shift
      shift
      ;;
    --kubelet-ca-cert)
      export KUBELET_CA_CERT="$2"
      shift
      shift
      ;;
    *) # Ignore unsupported args
      shift
      ;;
  esac
done

echo "KUBELET_EXTRA_ARGS=$KUBELET_EXTRA_ARGS"
echo "CLUSTER_DNS=$CLUSTER_DNS"
echo "APISERVER_ENDPOINT=$APISERVER_ENDPOINT"

if [[ -n $KUBELET_EXTRA_ARGS ]]; then
  OKE_EXTRA_ARGS="--kubelet-extra-args=\"$KUBELET_EXTRA_ARGS\""
fi

if [[ -e "/usr/bin/nvidia-smi" ]]; then
  OKE_EXTRA_ARGS="--manage-gpu-services=true $OKE_EXTRA_ARGS"
fi

echo "OKE_EXTRA_ARGS=$OKE_EXTRA_ARGS"

if [[ -n "$APISERVER_ENDPOINT" && -n "$KUBELET_CA_CERT" ]]; then
  mkdir -p /etc/kubernetes
  mkdir -p /etc/oke
  echo OKE_EXTRA_ARGS=${OKE_EXTRA_ARGS} > /etc/oke/oke.conf
  echo CLUSTER_DNS=${CLUSTER_DNS} >> /etc/oke/oke.conf
  echo APISERVER_ENDPOINT=${APISERVER_ENDPOINT} >> /etc/oke/oke.conf
  echo "$KUBELET_CA_CERT" | base64 -d > /etc/kubernetes/ca.crt
elif has_api_server; then
  mkdir -p /etc/kubernetes
  mkdir -p /etc/oke
  OKE_EXTRA_ARGS="--skip-growfs=true $OKE_EXTRA_ARGS"
  echo OKE_EXTRA_ARGS=${OKE_EXTRA_ARGS} > /etc/oke/oke.conf
  echo CLUSTER_DNS=${CLUSTER_DNS} >> /etc/oke/oke.conf
else
  echo "--apiserver-endpoint and/or --kubelet-ca-cert args must be set"
  exit 1
fi
mkdir -p /etc/systemd/system/oke.service.d
echo -e "[Service]\nEnvironmentFile=/etc/oke/oke.conf" > /etc/systemd/system/oke.service.d/10-args.conf
echo -e "StandardOutput=journal+console" >> /etc/systemd/system/oke.service.d/10-args.conf
echo -e "StandardError=journal+console" >> /etc/systemd/system/oke.service.d/10-args.conf
mkdir -p /etc/systemd/system/kubelet.service.d
echo -e "[Service]\nStandardError=journal+console" > /etc/systemd/system/kubelet.service.d/10-args.conf
swapoff -a || true
systemctl enable --now oke
restart_crio || true
touch /etc/.oke_init_complete || true
echo "$(date) Finished OKE Provisioning"
