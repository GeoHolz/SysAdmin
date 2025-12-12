# 🧹 WSUS Update Cleanup and Decline Tool for Windows 11

This PowerShell script is designed to automate common maintenance tasks on a WSUS server, focusing on declining unnecessary updates and performing cleanup to optimize disk space and performance.

It is specifically optimized for environments targeting **exclusively Windows 11 (21H2, 22H2, 23H2)**.

## 🚀 Key Features

The script accepts the following parameters:

| Parameter | Description |
| :--- | :--- |
| **`-WsusCleanup`** | Starts the WSUS server cleanup process (deleting unneeded content files, automatically declining expired/superseded updates, etc.). This operation takes **precedence** over others. |
| **`-AutoDecline`** | Automatically declines a wide range of updates deemed unnecessary for a standard Windows 11 environment. |
| **`-DeleteDeclined`**| Permanently deletes all updates marked as "Declined" from the WSUS server. |
| **`Server`**, **`UseSSL`**, **`PortNumber`** | Used to specify connection information for the WSUS server (default: `localhost`, `False`, `8530`). |

## 🎯 Decline Strategy (`-AutoDecline`)

When the `-AutoDecline` option is used, the script systematically declines the following:

1.  **Non-Final Updates:** Updates marked as *Preview*, *Beta*, or *Dev Channel*.
2.  **Superseded Updates:** Updates that have been made obsolete.
3.  **Non-x64 Architectures:** Updates targeting **x86** and **ARM64** architectures.
4.  **Older Windows Versions:** Any update that does **NOT** explicitly target the following Windows 11 versions:
    * Windows 11 Version 21H2
    * Windows 11 Version 22H2
    * Windows 11 Version 23H2
5.  **Specific Content:** *Language Packs* and updates classified as **Drivers**.

## 💡 Usage Examples

### 1. Decline and Full Deletion

Deep clean the server: first decline unnecessary updates, then delete the content of all updates marked as declined.
```powershell
.\Auto-WSUSUpdates.ps1 -AutoDecline -DeleteDeclined
```

### 2. WSUS Cleanup and Decline

Start the server cleanup (to handle expired updates, etc.), then run the specific decline logic to target Windows 11.
```powershell
.\Auto-WSUSUpdates.ps1 -WsusCleanup -AutoDecline
```

### 3. Deleting Existing Declines

Simply removes updates that are already in the "Declined" state on the WSUS server.
```powershell
.\Auto-WSUSUpdates.ps1 -DeleteDeclined
```

## ⚠️ Prerequisites

* The script must be run with **Administrator privileges** on the WSUS server or a machine with the necessary permissions.
* The WSUS Administration module (`Microsoft.UpdateServices.Administration`) must be available.
