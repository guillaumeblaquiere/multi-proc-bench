# Overview

This benchmark proposes to run a mono CPU intensive computing (Fibonacci algorithm in recursive mode) 
and to run several processing in parallel on a various number of CPUs, locally and on Google Cloud.

The benchmark can be performed in Go or Java language. You can compare in similar conditions:

* Same number of CPU
* Same memory (set to 2GiB in all tests)
* Same container deployed 

This project comes in relation with [this medium article](https://medium.com/google-cloud/cloud-run-performance-with-multiple-cpu-a4c2fccb5192)

# Prerequisites

The bench script has been writen to be run on Linux environment. In you are on Windows (like me), use Cloud Shell or WSL/WSL2 environment

You need to have access to a Google Cloud project with the following roles

* Cloud Build Editor to run a build job ou Cloud Build
* Cloud Storage admin to push and pull image from Google Container Registry
* Cloud Run admin to create Cloud Run services
* Compute Instances Admin to create and destroy Compute Engine instances
* Compute Network Admin to create and destroy firewall rules

*Of course, any wider role, like Compute Admin or Owner, are compliant.*

This organisation policies mustn't be enforced on your project

* Domain restriction sharing -> You can't create a public Cloud Run service for the bench (or update the script for this)
 
And this one must allow all VM to use external IP

* Define allowed external IPs for VM instances -> To reach the Compute engine instance from internet  

# Build and bench

There are 2 steps

* Create a container image
* Bench the platform with this container image

For this 2 steps, the scripts are the same in each directory `springboot` for Java 11 language and `go115` for Golang version1.15

So, go in the correct directory, and follow the instructions

## Build the container

The image tag name is  `gcr.io/PROJECT_ID/multi-proc-bench:[go115|java]` according to the language

**Customization**

*The customization is based on Linux environment variable*

* **PROJECT_ID**: The project ID to push the Container image. If not set, the gcloud SDK current project is used.
 
*Example*
```
PROJECT_ID=my-awesome-project bash build-local.sh
```

### On local environment

*This step required Docker installed locally. If not, go to the next section with Cloud Build*

To build the container locally with Docker
```
bash build-local.sh
```

The script built locally the image and push it to Google Cloud Registry. [Docker authentication is required for this](https://cloud.google.com/container-registry/docs/advanced-authentication)

### On Cloud Build

To build the container with Cloud Build
```
bash build-cloud.sh
```

The local source are sent to the Cloud and the container built with Cloud Build.

The image tag name is  `gcr.io/PROJECT_ID/multi-proc-bench:[go115|java]`

## Start a bench

The bench deploy the container on the platform and then, after the end of the platform initialization, 
run one (or several) salvo of 4 fibonacci request in the "same time" (in few milliseconds)

**Common Customization**

* **PROJECT_ID**: The project ID to run the bench. The container image must be on the same project. If not set, the gcloud SDK current project is used.
* **NB_CPU**: The number of CPU to use for the bench. Must be 1, 2 or 4. If not set, 1 is used. 
***Some machine types required a minimal number of CPU, greater than 1***
* **N**: The fibonacci parameter. If not set, 43 is used.

*Example*
```
PROJECT_ID=my-awesome-project NB_CPU=4 bash build-local.sh
```

### On Cloud Run

To start a bench on Cloud Run, run this command

```
bash bench-cloud-run.sh
``` 

* A new revision will be created on the service (and the service created if not exists)
* 4 requests in the same time are performed

**Specific Customization**

* **REGION**: The region to deploy the service. If not set, the `us-central1` region is used

### On Compute Engine

To start a bench on Cloud Run, there are 2 commands

```
# Build a traditional Compute Engine with a startup script to start the container
bash bench-compute-engine.sh

# Use the create-with-container feature to build a Compute Engine with a specific container on it
bash bench-compute-engine-with-container.sh
``` 

* A firewall rule is created to accept the external connexion from any source (0.0.0.0/0) on the port 8080 
and for only VM with a specific network tag
* Create a compute engine with the network tag in the defined zone and the correct number of CPU
  * On standard compute engine, use a startup script to start the container with `Docker run` command
  * Simply define the container source with `create-with-container` compute engine feature
* A loop is performed on the `/` path of the webserver. Until the HTTP 200 return code is received, the loop continue 
-> wait the server starts. 
* Requests in the same time are performed
  * 2 runs of 4 requests in all cases
  * Except for create-with-container compute engine in Go, because the Go webserver in the container starts too quickly 
  (before the full starts of the VM, and cause slow first requests). There are 4 runs of 4 requests.
* The firewall rule is deleted
* The compute engine is deleted

**Specific Customization**

* **ZONE**: The zone to deploy the service. If not set, the `us-central1-a` region is used. 
* **MACHINE_TYPE**: The type of server to use. Must be one of `n1`, `n2`, `e2`, `n2d`, `c2`. If not set, `n1` is used. 
* **LIMIT_CPU**: *Only for standard compute engine* The capability to limit the number of CPU with the `docker run` command.
 Can be interesting if the machine type support only multi CPU capability, and you want to test with less.
 Must be equal or lower than `NB_CPU` option value. If not set, the `NB_CPU` option value is used. 

***Be careful, the performance can change from a region to another one (the intel platform is not always the same) 
for `n1` machine type. In addition, machine type are only available in certain regions***

### On local environment

*You need to have Docker intalled on your local environment to perform this bench*

To start a bench on Cloud Run, run this command

```
bash bench-local.sh
``` 
* Docker run is started in background
* A loop is performed on the `/` path of the webserver. Until the HTTP 200 return code is received, the loop continue 
-> wait the server starts. 
* 4 requests in the same time are performed
* The docker process is stopped

**Specific Customization**

* **PORT**: The local port to listen the service. If not set, 8080 is used. 
* **LIMIT_CPU**: The capability to limit the number of CPU with the `docker run` command.
 Can be interesting to compare with the same number of CPU allowed on Google Cloud component.
 The number must be equal or lower than the number of CPUs of your computer.  

***Be careful, you can limit the number of CPUs but not the speed of the CPU. Compare carefully with the cloud results***

# License

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://github.com/guillaumeblaquiere/multi-proc-bench/tree/master/LICENSE).




