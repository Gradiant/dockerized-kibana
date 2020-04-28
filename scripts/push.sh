#!/bin/bash

set -ex

source variables.env

IFS=';' read -ra VERSION_LIST <<< "$KIBANA_VERSIONS"

for KIBANA_VERSION in "${VERSION_LIST[@]}"; do
    IMAGE_TAG=$KIBANA_VERSION
    docker push $IMAGE_REPO:$IMAGE_TAG
done
