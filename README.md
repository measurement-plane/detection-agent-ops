# Detection and TimeTags Measurement Agent Deployment

This document provides instructions for deploying the detection_agent Docker container on a Linux system. The agent interacts with a Time Tagger device for precision measurements.

## Prerequisites

Before deploying the container, ensure the following:
- Docker installed on your system.
- Device Connections:
    - Time Tagger: Connected via USB with its serial number known (e.g., `2138000XXX`).
- A running message broker (e.g., NATS) accessible at the specified `BROKER_URL`.

## Deployment Steps

### 1. Clone the Repository
Clone or download the repository containing the run.sh script.
```bash
git clone <repo-url>
cd detection-agent-ops
```

### 2. Configure Environment Variables
Update the run.sh script to match your setup:

```bash
BROKER_URL: Broker URL (e.g., nats://localhost:4222).
ENDPOINT: The agent's endpoint identifier (e.g., /timetagger/alice).
TT_TYPE: Time Tagger backend type.
TT_SERIAL: Serial number of the connected Time Tagger device.
PPS_CHANNEL: Channel index receiving the 1-PPS synchronization pulse.
TT_CHANNELS: List of enabled detector channels separated by "|" (e.g., 1|2|3|4|5|6|7|8).
MAX_EVENTS: Maximum number of time tags to buffer per acquisition.
BUFFER_SECONDS: Duration of the internal acquisition buffer in seconds.

TT_TRIGGER_LEVELS: Per-channel trigger thresholds in the format "ch=value" separated by commas.
TT_EVENT_DIVIDERS: Per-channel event thinning ratios (e.g., x=10 means keep 1 out of 10 events for channel number x).
TT_DEAD_TIMES: Optional per-channel dead times in picoseconds.
TT_DELAYS: Optional per-channel timing delays in picoseconds.
```

### 3. Run the Deployment Script
Make the script executable and run it:

```bash
chmod +x run.sh
./run.sh
```

### Notes
- This setup assumes the environment is Linux-only due to complications with serial port mapping on Windows.
- The `--privileged` flag is used to grant full access to USB devices.
