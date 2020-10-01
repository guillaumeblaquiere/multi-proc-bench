#!/usr/bin/bash

if [ -z ${PROJECT_ID} ]
then
  PROJECT_ID=$(gcloud config get-value project)
fi

if [ -z ${NB_CPU} ]
then
  NB_CPU=1
fi

echo "NB_CPU is ${NB_CPU}. It must be compliant with the machine type (n2, e2 and n2d require at least 2 CPU, c2 at least 4)"

if ! [[ "${NB_CPU}" =~ ^(1|2|4) ]]
then
  echo "NB_CPU must be one of: 1, 2, 4"
  exit 1
fi

if [ -z ${LIMIT_CPU} ]
then
  LIMIT_CPU=${NB_CPU}
fi

if [[ ${LIMIT_CPU} > ${NB_CPU} ]]
then
  echo "LIMIT_CPU can be higher than the NB_CPU value (${NB_CPU})"
  exit 1
fi

if [ -z ${ZONE} ]
then
  ZONE="us-central1-a"
fi

if [ -z ${N} ]
then
  N=43
fi

if [ -z ${MACHINE_TYPE} ]
then
  MACHINE_TYPE="n1"
fi

if ! [[ ${MACHINE_TYPE} =~ ^(n1|n2|e2|n2d|c2) ]]
then
  echo "MACHINE_TYPE must be one of: n1, n2, e2, c2, n2d"
  exit 1
fi


MACHINE_TYPE=${MACHINE_TYPE}-standard-${NB_CPU}
DOCKER_TAG="gcr.io/${PROJECT_ID}/multi-proc-bench:java"
BASE_NAME="multi-proc-bench-java"

echo "Create firewall rule"
gcloud compute firewall-rules create --allow=tcp:8080 --source-ranges=0.0.0.0/0 --target-tags=${BASE_NAME} \
   --network=default ${BASE_NAME}-http --project=${PROJECT_ID}

echo "Create Compute Engine"
gcloud beta compute instances create ${BASE_NAME}-${NB_CPU} --project=${PROJECT_ID} --zone=${ZONE} \
  --machine-type=${MACHINE_TYPE} --image-project=cos-cloud --image-family=cos-85-lts --boot-disk-size=10GB \
  --boot-disk-type=pd-standard --subnet=default --tags=${BASE_NAME} --metadata=startup-script="#!/bin/bash
  export HOME=/tmp
  docker-credential-gcr configure-docker
  docker run --cpus=${LIMIT_CPU} --memory=2000m -d -p 8080:8080 ${DOCKER_TAG}"

IP=$(gcloud compute instances describe ${BASE_NAME}-${NB_CPU} --project=${PROJECT_ID} --zone=${ZONE} \
  --format="value(networkInterfaces.accessConfigs.natIP)" | sed -r "s/\[|\]|'//g")

echo "Wait the server starts with the container"

while true
do
  HTTP_CODE=$(curl -m 1 -s -o /dev/null -w "%{http_code}" http://${IP}:8080)
  if [ "200" == "${HTTP_CODE}" ]
  then
    break
  fi
  sleep 1
done

echo "Run 4 requests on this IP: ${IP}"
curl  http://${IP}:8080/fibonacci/?n=${N} &
curl  http://${IP}:8080/fibonacci/?n=${N} &
curl  http://${IP}:8080/fibonacci/?n=${N} &
curl  http://${IP}:8080/fibonacci/?n=${N}

echo "Run 4 more requests"
curl  http://${IP}:8080/fibonacci/?n=${N} &
curl  http://${IP}:8080/fibonacci/?n=${N} &
curl  http://${IP}:8080/fibonacci/?n=${N} &
curl  http://${IP}:8080/fibonacci/?n=${N}


echo "Delete firewall rule"
gcloud compute firewall-rules delete ${BASE_NAME}-http --quiet --project=${PROJECT_ID}

echo "Delete the instance"
gcloud compute instances delete ${BASE_NAME}-${NB_CPU} --project=${PROJECT_ID} --zone=${ZONE} --quiet



