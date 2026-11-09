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
- The `--privileged` flag is used to grant full access to USB devices.
- On Windows, the Time Tagger must first be forwarded into WSL2. Follow the steps below.

## Running on Windows
 
Docker Desktop runs Linux containers inside a WSL2 virtual machine, so the container cannot see Windows USB devices directly. The Time Tagger has to be forwarded from Windows into WSL2 with [usbipd-win](https://github.com/dorssel/usbipd-win), and `run.sh` should be run from a WSL shell.
 
### Windows prerequisites
- Docker Desktop with the **WSL 2 based engine** enabled (Settings → General).
- A WSL distro (e.g. Ubuntu) with Docker Desktop integration turned on (Settings → Resources → WSL Integration).
- WSL up to date: run `wsl --update` in PowerShell.

### 1. Install usbipd-win
In PowerShell:
 
```powershell
winget install usbipd
```
 
Close and reopen the terminal afterward.
 
### 2. Share the Time Tagger with WSL
With the Time Tagger plugged in, open **PowerShell as Administrator**:
 
```powershell
usbipd list
```
 
Note the BUSID of the Time Tagger (e.g. `2-3`), then share and attach it:
 
```powershell
usbipd bind --busid 2-3                      # one-time per device, requires admin
usbipd attach --wsl --busid 2-3 --auto-attach
```
 
- `bind` only needs to be done once per device.
- `--auto-attach` re-attaches the device automatically if it is unplugged or re-enumerates. Leave that window open while you work. Without it, `usbipd attach --wsl --busid 2-3` must be repeated after every unplug or reboot.
- While attached, the device is unavailable to Windows. To release it: `usbipd detach --busid 2-3`.

### 3. Verify the device in WSL
Open a WSL shell (e.g. Ubuntu) and check that the device is listed:
 
```bash
lsusb
docker info | grep -i "operating system"   # should report Docker Desktop
```
 
All WSL distros, including Docker Desktop's own, share one kernel, so a device visible here is also visible to Docker.
 
### 4. Run the deployment script from WSL
Run `run.sh` from the WSL shell, not from Git Bash or PowerShell:
 
```bash
cd /mnt/c/path/to/detection-agent-ops
sed -i 's/\r$//' run.sh   # strip Windows line endings if the repo was cloned on Windows
chmod +x run.sh
./run.sh
```
 
### Windows troubleshooting
- **Device not found in the container:** confirm it appears in `lsusb` in WSL. If not, re-run `usbipd attach`. Attach the device *before* starting the container. If it was re-plugged, re-run `./run.sh`.
- **Running from Git Bash:** Git Bash rewrites Unix-style paths (e.g. `/dev/...`) into Windows paths. Use a WSL shell instead, or add `export MSYS_NO_PATHCONV=1` at the top of the script.
- **`$'\r': command not found`:** the script has Windows line endings. Run `sed -i 's/\r$//' run.sh` or `dos2unix run.sh`.
- **Broker running on the Windows host:** inside the container, `localhost` refers to the container itself. Set `BROKER_URL="nats://host.docker.internal:4222"` to reach a broker running on Windows.
- **Do not install Docker Engine inside WSL** (e.g. `apt install docker.io`). That creates a second, separate daemon. Docker Desktop's WSL integration is all that is needed.
