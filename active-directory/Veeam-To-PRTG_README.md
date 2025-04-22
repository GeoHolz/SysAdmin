# 📡 Veeam-To-PRTG.ps1

This script is used to **monitor the health and backup status of a Veeam Backup & Replication server**, and send the results to a **PRTG Network Monitor** server using an **HTTP Push sensor**.

---

## 🧰 What It Does

- Connects to a specified Veeam Backup & Replication server.
- Collects the latest status of:
  - Backup jobs
  - Repository health
- Formats the results into XML compatible with **PRTG custom sensors**.
- Sends the XML to PRTG using HTTP Push.

---

## ⚙️ Requirements

- **Veeam Backup & Replication** must be installed and accessible.
- A **PRTG HTTP Push Data Advanced Sensor** must be created in advance.
  - The sensor provides:
    - A **token** (`httptoken`)
    - A **port** (`httpport`)
    - A **URL endpoint** to send the XML to

---

## 🚀 Execution

The script should be run via a **Windows Scheduled Task** (e.g., every 10 minutes), with the following parameters:

```powershell
.\Veeam-To-PRTG.ps1 `
  -BRHost "YourVeeamServer.domain.local" `
  -httppush:$true `
  -httpserver "prtg.domain.local" `
  -httpport 5050 `
  -httptoken "my-prtg-token"
