# Gotify RAID Monitoring

This repository contains a lightweight Bash script designed to monitor Linux Software RAID (mdadm) health and send real-time alerts via Gotify.

It provides a simple, push-based solution to track RAID degradation, disk failures, or rebuild processes.

## How It Works

The script queries the mdadm utility for a specific MD device (e.g., /dev/md127) and performs the following logic:

1.  State Verification: It checks the current status. If the array is clean or active, the script exits silently to avoid spam.
1.  Health Check: It extracts counts for active, working, and failed devices.
1.  Fault Identification: If a drive is marked as faulty or removed, the script identifies the specific disk and includes it in the alert.
1.  Smart Priority:
    *  Priority 8: Used for resync operations.
    *  Priority 10: Used for critical failures.

### Key Features

*  Push Notifications: Instant alerts via Gotify.
*  Detailed Context: Includes state, statistics, and faulty drives.
*  Low Overhead: No external dependencies other than curl and mdadm.

## Configuration

Before running the script, update the configuration variables at the top of the file:

```bash

Gotify Configuration
GOTIFY_URL="http://YOUR_GOTIFY_URL/message?token=YOUR_TOKEN"
TITLE="RAID Alert"
MD_DEVICE="/dev/md127"
```

Note: Ensure the user executing the script has the necessary permissions to run mdadm --detail.

## Installation

1.  Download the script to your server.
1.  Make it executable:
```bash
chmod +x check_raid.sh
```

1.  Schedule it via Crontab:
```bash
*/10 * * * * /path/to/check_raid.sh
```

## Sample Notification Body

```text
⚠️ Problème détecté sur /dev/md127
État actuel : clean, degraded

Statistiques :

Actifs : 1

En panne : 1

Fonctionnels : 1

Disques concernés :
0      8        1        0      faulty   /dev/sda1
```