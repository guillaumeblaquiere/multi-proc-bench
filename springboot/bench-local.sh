#!/usr/bin/bash

if [ -z ${PROJECT_ID} ]
then
  PROJECT_ID=$(gcloud config get-value project)
fi

if [ -z ${LIMIT_CPU} ]
then
  LIMIT_CPU=1
fi

if [ -z ${N} ]
then
  N=43
fi

if [ -z ${PORT} ]
then
  PORT=8080
fi

DOCKER_TAG="gcr.io/${PROJECT_ID}/multi-proc-bench:java"

echo "Start the container"
PID=$(docker run --cpus=${LIMIT_CPU} --memory=2000m -d -p ${PORT}:8080 ${DOCKER_TAG})

IP="localhost:${PORT}"
echo "Wait the server starts with the container"

while true
do
  HTTP_CODE=$(curl -m 1 -s -o /dev/null -w "%{http_code}" http://${IP})
  if [ "200" == "${HTTP_CODE}" ]
  then
    break
  fi
  sleep 1
done

echo "Run 4 requests on this IP: ${IP}"
curl  http://${IP}/fibonacci/?n=${N} &
curl  http://${IP}/fibonacci/?n=${N} &
curl  http://${IP}/fibonacci/?n=${N} &
curl  http://${IP}/fibonacci/?n=${N}

echo "Print the container logs"
docker logs ${PID}

echo "Stop the container"
docker stop ${PID}

