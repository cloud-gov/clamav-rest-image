# clamav-rest-image

Image for malware scanning of file uploads. 

## Approach

The image is based on the https://github.com/ajilach/clamav-rest repo. This implementation provides a Golang REST implmentation to interact with ClamAV running in a Docker container. This version of clamav-rest is maintained by a document company and receives regular updates.

We need to make a few changes to use this repository/project. 

- Two Dockerfiles are provided: one based on Alpine and the other Centos. We need a stig'd image based on Ubuntu.
- The Golang application starts an https endpoint in addition to an http endpoint. The code requires certificates. This https listeneer (and the certificates) are not necessary in our deployment (https and certificates are handled in AWS and CF).

Despite these differences, we DO NOT want to maintain a fork of this repository. Forks get stale very quickly and become harder to maintain over time. This repository is not a fork. Instead it:

- Provides a Dockerfile to build a clamav-rest Docker image on our Ubuntu-stig base image (`ubuntu-hardened-stig`).
- Installs the clamav-rest Golang application in our image. 
- Deploys the image to Cloud Foundry as a Docker application.
- Runs scanning tests against the deployed application.

This approach eliminates the need for a fork. We are able to control ClamAV configuration more closely and provide an optimized `freshclam` update strategy. 

### Configuring ClamAV

The `clamd.conf` and `freshclam.conf` in [image/conf](./image/conf) are copied directly to the ClamAV image. Refer to the ClamAV documentation for configuraiton options. 

### Certificates

The https://github.com/ajilach/clamav-rest codebase starts both an http and https listener. Removing the https listener would require forking the codebase (which we don't want to do). Instead, we can allow the listener to start without using it. 

Certificates are required to start the https listener. For simplicity, we generate certificate in the Dockerfile during each build.

## Pipelines

- `clamav-rest-candidate`: Builds the candidate image (not yet tested) using the shared internal pipeline in https://github.com/cloud-gov/common-pipelines. The image is built with the Ubuntu-hardended-stig base image. It is published to the `clamav-rest-candidate` ECR.

- `clamav-rest-image`: Tests the candidate image by deploying it to Cloud Foundry and invoking scans. The image is deployed on the `apps.internal` domain. Therefore, another app (in the [test](./test) directory) is used to run tests. Tests are implemented as a `cf task`. The validated image is uploaded to the `clamav-rest` ECR. This is the image that should be used for malware scanning. 








