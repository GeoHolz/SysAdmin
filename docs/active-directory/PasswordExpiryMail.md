# Automated Password Expiry Email Reminders

This script automates the process of notifying users when their Active Directory passwords are about to expire. It sends personalized emails to each user and a summary report to the IT administration team.

## 🚀 Features

* **Proactive Notifications:** Sends reminders to users starting X days before expiry.
* **Smart Expiry Calculation:** Automatically handles both Default Domain Password Policies and **Fine-Grained Password Policies** (FGPP).
* **Personalized Messaging:** Emails adapt the language based on urgency (e.g., "today", "tomorrow", or "in X days").
* **Admin Summary:** Generates an HTML report sent to Sysadmins containing a list of all users notified and their status.
* **Testing & Logging:** Includes a `-testing` mode to redirect all emails to a specific mailbox and a `-logging` feature to export results to CSV.

## 🛠 Prerequisites

* **Active Directory Module:** Required to fetch user attributes and password policies.
* **SMTP Relay:** An open or authenticated relay to send automated emails.
* **Network:** The execution host must be able to reach the domain controller and the SMTP server.

## 📖 Usage

### Basic Production Run
To notify users whose passwords expire within the next 21 days:
```powershell
.\PasswordChangeNotification.ps1 -smtpServer "mail.domain.com" -expireInDays 21 -from "IT Support <support@domain.com>"
```

### Testing Mode (Safe Run)
To test the script logic without emailing actual users (redirects all mail to you):
```powershell
.\PasswordChangeNotification.ps1 -smtpServer "mail.domain.com" -expireInDays 14 -from "IT <support@domain.com>" -testing -testRecipient "youradmin@domain.com" -status
```

### Complete Run with Logging
```powershell
.\PasswordChangeNotification.ps1 -smtpServer "mail.domain.com" -expireInDays 21 -from "IT <support@domain.com>" -logging -logPath "C:\Logs\PasswordReminders"
```

## ⚙️ Parameters

| Parameter | Description |
| :--- | :--- |
| **smtpServer** | The SMTP host IP or FQDN. |
| **expireInDays** | Threshold to start sending reminders (e.g., 14). |
| **from** | The "From" address for the emails. |
| **logging** | (Switch) Enables CSV logging of the operation. |
| **logPath** | Directory where the CSV logs will be saved. |
| **testing** | (Switch) Sends all emails to the `-testRecipient` instead of users. |
| **testRecipient**| Email address used for testing or as a fallback for users without an email. |
| **status** | (Switch) Displays real-time progress in the console. |

## 📝 Customization

Inside the script, you can modify the following variables to fit your company:
* **$smtptoSysadmin**: Set this to your team's mailbox to receive the daily summary.
* **$body**: The HTML template used for the user email (includes links to Webmail or Intranet).

{{ github_link() }}