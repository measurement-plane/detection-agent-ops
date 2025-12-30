#!/bin/bash

# ========== CONFIGURABLE PARAMETERS ==========
# Container and image configuration
CONTAINER_NAME="detection_agent_container"
IMAGE_NAME="amlabdr/detection_agent:latest"

# ---------------- Core connectivity ----------------
BROKER_URL="nats://localhost:4222"
ENDPOINT="/timetagger/alice"

# ---------------- TimeTagger config ----------------
TT_TYPE="swabian"
TT_SERIAL="2138000XI2"
PPS_CHANNEL="8"
TT_CHANNELS="1|2|3|4|5|6|7|8"
MAX_EVENTS="10000000"
BUFFER_SECONDS="10"

# Per-channel config
TT_TRIGGER_LEVELS="1=0.5,2=0.5,3=0.5,4=0.5,5=0.5,6=0.5,7=0.5,8=0.5"
TT_EVENT_DIVIDERS="1=10,2=10,3=10,4=10"
TT_DEAD_TIMES=""
TT_DELAYS=""


# ---------------- Stop old container ----------------
echo "Stopping and removing existing container (if any)..."
docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true

# Pull the latest pre-built image
echo "Pulling the latest image..."
if ! docker pull "$IMAGE_NAME"; then
    echo "Error: Failed to pull the image. Exiting."
    exit 1
fi

# Prepare the run command
echo "Starting the container..."
DOCKER_CMD="docker run --name \"$CONTAINER_NAME\""

# Core connectivity
DOCKER_CMD+=" -e BROKER_URL=\"$BROKER_URL\""
DOCKER_CMD+=" -e ENDPOINT=\"$ENDPOINT\""

# TimeTagger config
DOCKER_CMD+=" -e TT_TYPE=\"$TT_TYPE\""
DOCKER_CMD+=" -e TT_SERIAL=\"$TT_SERIAL\""
DOCKER_CMD+=" -e PPS_CHANNEL=\"$PPS_CHANNEL\""
DOCKER_CMD+=" -e TT_CHANNELS=\"$TT_CHANNELS\""
DOCKER_CMD+=" -e MAX_EVENTS=\"$MAX_EVENTS\""
DOCKER_CMD+=" -e BUFFER_SECONDS=\"$BUFFER_SECONDS\""

# Per-channel parameters
DOCKER_CMD+=" -e TT_TRIGGER_LEVELS=\"$TT_TRIGGER_LEVELS\""
DOCKER_CMD+=" -e TT_EVENT_DIVIDERS=\"$TT_EVENT_DIVIDERS\""
DOCKER_CMD+=" -e TT_DEAD_TIMES=\"$TT_DEAD_TIMES\""
DOCKER_CMD+=" -e TT_DELAYS=\"$TT_DELAYS\""

# Hardware access
DOCKER_CMD+=" --privileged"

# Add the image name
DOCKER_CMD+=" \"$IMAGE_NAME\""

# Execute the run command
if ! eval $DOCKER_CMD; then
    echo "Error: Failed to start the container."
    exit 1
fi
