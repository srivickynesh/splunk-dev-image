#!/bin/bash

source ./preview.env

SPLUNK_PASSWORD="Password"
SPLUNK_START_ARGS="'--accept-license'"
URL="http://localhost:8089"
HEC_ENDPOINT="http://localhost:8088"
HEC_TOKEN_DEV_APP="71a657fe-ea4c-4994-adc8-2032d95c9861"
HEC_TOKEN_DEV_AUDIT="5ab43f3f-0eae-4066-9151-d5d2cbfd3a5a"

build_image() {
    # Ensure the IMAGE_NAME exists
    [[ -z "$IMAGE_NAME" ]] \
      && echo "Error: IMAGE_NAME ENV is not set!" && exit 1

    echo "Building Splunk image..."
    podman build -t "$IMAGE_NAME" . \
      && echo "Image '$IMAGE_NAME' built successfully!" \
      || { echo "Error: Failed to build the image."; exit 1; }
}

run_image() {
    echo "Running Splunk container..."
    podman run -d \
      -e SPLUNK_PASSWORD="$SPLUNK_PASSWORD" \
      -e SPLUNK_START_ARGS="$SPLUNK_START_ARGS" \
      -p 8000:$WEB_PORT \
      -p 8089:$API_PORT \
      -p 8088:$HEC_PORT \
      "$IMAGE_NAME" \
      && echo "Container from image '$IMAGE_NAME' started successfully!" \
      || { echo "Error: Failed to start the container."; exit 1; }
}

is_splunk_up() {
    [[ "$(curl -s -o /dev/null -w %{http_code} \
      -u admin:$SPLUNK_PASSWORD \
      --insecure $URL/services/server/info)" == "200" ]]
}

wait_for_splunk() {
    TIMEOUT=120
    SLEEP_INTERVAL=5
    echo "Waiting for Splunk to come up"
    start_time=$(date +%s)

    until is_splunk_up \
      || [[ $(( $(date +%s) - start_time )) -ge $TIMEOUT ]]; do
        sleep $SLEEP_INTERVAL
    done

    is_splunk_up && echo "Splunk CLI is Up" \
      || echo "Timeout reached while waiting for Splunk to come up"
}

build_image
run_image
wait_for_splunk
