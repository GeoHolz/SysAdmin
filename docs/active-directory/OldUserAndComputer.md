# Password Expiry & Stale Computer Auditor

This script provides an automated way to monitor Active Directory health by identifying two critical security concerns: users with expired passwords and computers that haven't contacted the domain for a specified number of days. It can output results directly to the console or send a formatted HTML report via email.

## 🚀 Features

* **Expired Password Detection:** Filters active users whose passwords have expired and are not set to "Never Expires".
* **Stale Computer Identification:** Lists computers that haven't logged onto the domain for X days (based on `LastLogonTimeStamp`).
* **Dual Output Modes:**
    * **Console:** Quick view using formatted tables.
    * **Email:** Sends a professional HTML email with CSS styling to a sysadmin or a support team.
* **AD Integration:** Uses standard Active Directory cmdlets for reliable data gathering.

## 🛠 Prerequisites

* **Active Directory Module:** Requires RSAT for AD installed.
* **SMTP Server:** An accessible SMTP relay to send email notifications.
* **Permissions:** Must run with an account having read access to Active Directory objects and attributes.

## 📖 Usage

### Console Output
To quickly display users and computers older than 30 days in the console:
```powershell
.\PasswordChangeNotification.ps1 -smtpServer "mail.domain.com" -Days 30 -smtpfrom "it@domain.com" -smtpto "admin@domain.com" -Console
```

### Email Notification
To send a formatted HTML report via email:
```powershell
.\PasswordChangeNotification.ps1 -smtpServer "mail.domain.com" -Days 30 -smtpfrom "IT Alert <alerts@domain.com>" -smtpto "support@domain.com" -Email
```

## ⚙️ Parameters

| Parameter | Description |
| :--- | :--- |
| **smtpServer** | Hostname or IP of your SMTP server. |
| **Days** | The threshold for stale computers (e.g., 30 for computers inactive for a month). |
| **smtpfrom** | The sender address (supports "Display Name <email@domain.com>"). |
| **smtpto** | The recipient address for the report. |
| **Console** | Switch to output results in the PowerShell window. |
| **Email** | Switch to send the results via email. |

## 📧 Email Report Format

The script generates an HTML body with built-in CSS styling including:
* A table of users with **Name** and **DistinguishedName**.
* A table of computers with **Name**, **DistinguishedName**, and **LastLogonDate**.

{{ github_link() }}