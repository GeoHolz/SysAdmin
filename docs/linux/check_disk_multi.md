# PRTG Disk Monitoring

This repository contains `check_disk_multi.sh`, a custom Bash script designed to be used with the **SSH Script Advanced** sensor in PRTG Network Monitor.

It provides a dynamic, single-sensor solution to monitor multiple Logical Volumes (LVM) and mount points on Linux servers, returning data in PRTG-compatible XML format.

## How It Works

The script executes a standard `df -Ph` command on the target system and processes the output to:
1.  **Auto-discover** all relevant mount points as individual PRTG Channels.
2.  **Format** the usage data into XML.
3.  **Apply** warning and error thresholds directly within the output.

### Key Features

* **Dynamic Discovery:** No need to hardcode mount points. If a new Logical Volume is created, it will automatically appear in PRTG after the next scan.
* **Built-in Thresholds:**
    * **Warning:** 90% usage
    * **Error:** 95% usage
    * *Note: These limits are enforced via the `<limitmode>1</limitmode>` XML tag.*

### Filtering Logic

To ensure clean monitoring without false positives or noise, the script applies strict filtering to exclude:

* **Network Filesystems:** Ignores `NFS`, `NFS4`, and `CIFS` (SMB) mounts to prevent hanging checks if the network is down.
* **Container/Kubernetes Noise:** Explicitly filters out virtual mounts related to container runtimes, including:
    * `overlay`
    * `k0s`
    * `containerd`
    * `docker`
    * `kubelet`
    * `shm` / `tmpfs` / `devtmpfs`

## Usage

### Server Placement
The script must be placed on the **target** Linux server in the specific directory required by PRTG's SSH Script Advanced sensor:

```path
/var/prtg/scriptsxml/check_disk_multi.sh
```

### Execution

The script is executed via SSH by the PRTG probe user. It requires no arguments.
```bash
./check_disk_multi.sh
```

### Sample Output (XML):
```xml
<prtg>
  <result>
    <channel>/var</channel>
    <value>45</value>
    <unit>Percent</unit>
    <limitmode>1</limitmode>
    <limitmaxerror>95</limitmaxerror>
    <limitmaxwarning>90</limitmaxwarning>
  </result>
  ...
</prtg>
```





