# Active Directory Directory Permissions Auditor

This PowerShell script audits and lists all users who have access to a specific directory. It goes beyond simple ACL listing by **recursively expanding Active Directory groups** to identify the individual users behind them.

## 🚀 Features

* **Group Expansion:** Automatically resolves AD Groups to list the actual members (recursive expansion).
* **Recursion Support:** Can audit a single folder or an entire directory tree.
* **Exclusion List:** Built-in variable to filter out administrative groups (e.g., Domain Admins) to reduce noise in reports.
* **Detailed Output:** Provides Path, Group Name, User Name, Permissions (FileSystemRights), and Inheritance status.

## 🛠 Prerequisites

* **Active Directory Module:** The script requires the RSAT (Remote Server Administration Tools) for AD.
* **Permissions:** Must be run with an account that has read access to the target filesystem and Active Directory.

## 📖 Usage

### Basic Usage
```powershell
.\Get-FolderAccess.ps1 -Path "C:\Shares\Finance"
```

### Recursive Audit
```powershell
.\Get-FolderAccess.ps1 -Path "\\Server01\Data" -Recurse
```

### With Verbose Output
```powershell
.\Get-FolderAccess.ps1 -Path "D:\Marketing" -Recurse -Verbose
```

## ⚙️ Configuration

You can customize the `$ListExclusion` variable inside the script to ignore specific groups that you don't want to see in the report:

```powershell
$ListExclusion = "local.local\domain admins", "local.local\other_group_to_exclude"
```

## 📊 Output Format

The script returns an object for each permission entry with the following properties:

| Property | Description |
| :--- | :--- |
| **Path** | The full path to the folder. |
| **Group** | The AD Group name (empty if permission is assigned directly to a user). |
| **User** | The Display Name of the user. |
| **FileSystemRights** | The specific rights (Read, Write, FullControl, etc.). |
| **AccessControlType** | Allow or Deny. |
| **Inherited** | Boolean indicating if the permission is inherited from a parent folder. |

{{ github_link() }}