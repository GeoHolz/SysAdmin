# Print Service Activity Reporter

This script monitors and reports daily printing activity from a Windows Print Server. It queries the Windows Event Logs to extract details about every document printed and sends a formatted HTML summary via email.

## 🚀 Features

* **Event Log Analysis:** Scans the `Microsoft-Windows-PrintService/Operational` log for Event ID 307 (Document Printed).
* **Detailed Tracking:** Captures essential metadata for each print job:
    * **User:** Who printed the document.
    * **Machine:** The source computer name.
    * **Document Name:** The title of the printed file.
    * **Page Count:** Exact number of pages printed.
    * **Printer:** The specific printer queue used.
    * **Timestamp:** When the job was processed.
* **Automated HTML Reporting:** Constructs a clean, easy-to-read HTML table for the email body.
* **Secure Delivery:** Configured to use SMTP with SSL and credentials (specifically set up for Gmail/App Passwords).

## 🛠 Prerequisites

* **Print Service Logging:** The "Operational" log must be enabled on the print server (it is often disabled by default).
* **Permissions:** Must run with administrative privileges to read Event Logs from the target server.
* **SMTP Access:** Requires an SMTP account (the script is pre-configured for Gmail on port 587).

## 📖 Usage

The script is designed to be run as a daily scheduled task (e.g., at the end of the day or early morning).

1.  Update the `$From`, `$To`, and `$Password` variables with your credentials.
2.  Specify the target print server name in the `Get-WinEvent` command.
3.  Execute the script:
```powershell
.\Get-PrintJobsReport.ps1
```

## ⚙️ Configuration

Inside the script, you can adjust the time window by modifying:
* **$StartTime:** Default is set to 03:00 AM of the current day.
* **$EndTime:** Default is set to 11:00 PM of the current day.

## 📊 Output Columns

| Column | Description |
| :--- | :--- |
| **PageCount** | Total pages for the specific job. |
| **MachineName** | The client computer that sent the job. |
| **DocName** | Name of the file/document. |
| **TimeCreated** | Precise date and time of printing. |
| **UserName** | The AD user who initiated the print. |
| **PrinterName** | The name of the printer used. |

{{ github_link() }}