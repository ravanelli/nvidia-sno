#!/usr/bin/env bash
set -xeuo pipefail

OCP_VERSION="4.22.0-rc.2"
RHCOS_BUILD="10.2.20260423-0102"
RHCOS_ISO="rhcos-${RHCOS_BUILD}-live-iso.aarch64.iso"


if [[ ! -x ./openshift-install ]]; then
    curl -LO \
      "https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/${OCP_VERSION}/openshift-install-linux.tar.gz"
    tar -xzf openshift-install-linux.tar.gz
    chmod +x openshift-install
fi

if [[ ! -f "${RHCOS_ISO}" ]]; then
    curl -L -O \
      "https://releases-rhcos--prod-pipeline.apps.int.prod-stable-spoke1-dc-iad2.itup.redhat.com/storage/prod/streams/rhel-10.2-ocp4nv-preview/builds/${RHCOS_BUILD}/aarch64/${RHCOS_ISO}"
fi

rm -Rf ocp
mkdir ocp


export SSH_KEY=$(cat ssh.pub | tr -d '\n\r')
export PULL_SECRET=$(cat pull-secret.json  | tr -d '\n\r')


envsubst < install-config.yaml.template > install-config.yaml

cp install-config.yaml ocp/

./openshift-install create manifests --dir ocp/

cp local_openshift/* ocp/openshift/

./openshift-install create single-node-ignition-config --dir ocp/

cp ocp/bootstrap-in-place-for-live-iso.ign .
butane --pretty --strict --files-dir . dnsmasq.bu -o tpm.ign
cp tpm.ign ocp/bootstrap-in-place-for-live-iso.ign 

RANDOM_ID=$(tr -dc 'a-z' </dev/urandom | head -c 5 || true)
ISO_NAME="rhcos-${RANDOM_ID}.iso"


coreos-installer iso ignition embed \
  -i ocp/bootstrap-in-place-for-live-iso.ign \
  "${RHCOS_ISO}" \
  -o "${ISO_NAME}"

scp "${ISO_NAME}" \
  root@10.8.2.218:/srv/nfs/iso/"${ISO_NAME}"
