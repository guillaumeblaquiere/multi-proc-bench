#!/usr/bin/bash

if [ -z ${PROJECT_ID} ]
then
  PROJECT_ID=$(gcloud config get-value project)
fi

if [ -z ${NB_CPU} ]
then
  NB_CPU=1
fi

if ! [[ "${NB_CPU}" =~ ^(1|2|4) ]]
then
  echo "NB_CPU must be one of: 1, 2, 4"
  exit 1
fi

if [ -z ${REGION} ]
then
  REGION="us-central1"
fi

if [ -z ${N} ]
then
  N=43
fi


DOCKER_TAG="gcr.io/${PROJECT_ID}/multi-proc-bench:java"
BASE_NAME="multi-proc-bench-java"

echo "Deploy on Cloud Run"
gcloud alpha run deploy --max-instances=1 --cpu=${NB_CPU} --memory=2Gi --image=${DOCKER_TAG} --allow-unauthenticated \
--region=${REGION} --platform=managed --project=${PROJECT_ID} ${BASE_NAME}

URL=$(gcloud run services describe ${BASE_NAME} --region=${REGION} --format='value(status.address.url)')

echo "Run 4 requests on this URL: ${URL}"
curl  ${URL}/fibonacci/?n=${N} &
curl  ${URL}/fibonacci/?n=${N} &
curl  ${URL}/fibonacci/?n=${N} &
curl  ${URL}/fibonacci/?n=${N}

