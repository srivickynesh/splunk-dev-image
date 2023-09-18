# splunk-dev-image

This README provides an overview and steps to build a Splunk image, run it in a container, and send data to it.

## Deployment Overview

1. Build a Splunk image on your local machine.
2. Wait for the Splunk service to come up and be responsive.
3. Send test data to the Splunk service to validate it's working as expected.

### Prerequisites

1. Podman installed in local machine
2. An image of Splunk or appropriate Dockerfile

### Steps to Deploy
1. Setting Environment Variables
    Set env variables within preview.env

2. Execution
    To execute the script, run:
        ```
        ./run_splunk_container.sh
        ```
