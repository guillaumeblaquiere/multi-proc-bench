#!/usr/bin/bash

if [ -z ${PROJECT_ID} ]; then
  PROJECT_ID=$(gcloud config get-value project)
fi

if [ -z ${NB_CPU} ]; then
  NB_CPU=1
fi

if ! [[ "${NB_CPU}" =~ ^(1|2|4) ]]
then
  echo "NB_CPU must be one of: 1, 2, 4"
  exit 1
fi

if [ -z ${REGION} ]; then
  REGION="us-central1"
fi

if [ -z ${N} ]; then
  N=43
fi

DOCKER_TAG="gcr.io/${PROJECT_ID}/multi-proc-bench:go115"
BASE_NAME="multi-proc-bench-go115"

echo "Deploy on Cloud Run"
gcloud alpha run deploy --max-instances=1 --cpu=${NB_CPU} --memory=2Gi --image=${DOCKER_TAG} --allow-unauthenticated \
  --region=${REGION} --platform=managed --project=${PROJECT_ID} ${BASE_NAME}

URL=$(gcloud run services describe ${BASE_NAME} --region=${REGION} --format='value(status.address.url)')

echo "Run 4 requests on this URL: ${URL}"
curl ${URL}/fibonacci/?n=${N} &
curl ${URL}/fibonacci/?n=${N} &
curl ${URL}/fibonacci/?n=${N} &
curl ${URL}/fibonacci/?n=${N}

#gcloud beta compute --project=gbl-imt-homerider-basguillaueb instances create-with-container instance-3 --zone=europe-west1-b --machine-type=n2-standard-2 --subnet=europe-west1 --network-tier=PREMIUM --metadata=google-logging-enabled=true --maintenance-policy=TERMINATE --service-account=763366003587-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=cos-stable-85-13310-1041-9 --image-project=cos-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=instance-3 --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --container-image=gcr.io/gbl-imt-homerider-basguillaueb/multi-proc-bench:go115 --container-restart-policy=always --labels=container-vm=cos-stable-85-13310-1041-9 --reservation-affinity=any
