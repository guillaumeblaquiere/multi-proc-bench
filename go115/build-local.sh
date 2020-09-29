#!/usr/bin/bash

if [ -z ${PROJECT_ID} ]
then
  PROJECT_ID=$(gcloud config get-value project)
fi

DOCKER_TAG="gcr.io/${PROJECT_ID}/multi-proc-bench:go115"

echo "Docker tag used: ${DOCKER_TAG}"

echo "Build..."
docker build -t ${DOCKER_TAG} .

echo "Push..."
docker push ${DOCKER_TAG}