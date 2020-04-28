#!/bin/bash

set -ex

source variables.env


IFS=';' read -ra VERSION_LIST <<< "$KIBANA_VERSIONS"
if [[ "$IMAGE_REPO" == *-oss ]]; then
    BASE_IMAGE="docker.elastic.co/kibana/kibana-oss";
else
    BASE_IMAGE="docker.elastic.co/kibana/kibana";
fi

for KIBANA_VERSION in "${VERSION_LIST[@]}"; do
    IMAGE_TAG=$KIBANA_VERSION
    docker build -t $IMAGE_REPO:$IMAGE_TAG \
      --build-arg version=$KIBANA_VERSION \
      --build-arg base_image=$BASE_IMAGE ..
done