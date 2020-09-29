#!/usr/bin/bash

if [ -z ${PROJECT_ID} ]
then
  PROJECT_ID=$(gcloud config get-value project)
fi

DOCKER_TAG="gcr.io/${PROJECT_ID}/multi-proc-bench:java"

echo "Docker tag used: ${DOCKER_TAG}"

echo "Run Cloud Build"
gcloud builds submit -t ${DOCKER_TAG}
