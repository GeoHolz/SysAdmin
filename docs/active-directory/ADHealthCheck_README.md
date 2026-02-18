# 🩺 Active Directory Offline Health Report

This PowerShell script generates an **HTML health report** for an **Active Directory domain that is disconnected from the internet**.

## 🎯 Purpose

In environments where email reporting is not possible (e.g., offline or air-gapped domains), this script provides a **local, browsable HTML report** of the Active Directory domain health. At the end of execution, the report is uploaded to a **shared FTP directory**, making it easily accessible via a web browser from a central location.

This script also helps in **tracking compliance** with best practices recommended by the **ORADAD audit script from ANSSI** (French National Cybersecurity Agency). It includes checks that reflect the guidelines for securing and monitoring Active Directory environments.

---

## 📄 Report Sections

The report is structured into multiple sections, each targeting a specific area of Active Directory:

### 🧪 Active Directory DCDiag
- Runs a full diagnostic (`dcdiag`) on domain controllers.
- Helps detect DNS issues, replication problems, configuration errors, etc.

### 👤 Active Directory Users Password Expiry
- Lists user accounts and the number of days remaining before their password expires.

### ⚙️ Managed Service Accounts
- Displays all Managed Service Accounts (gMSA).
- Shows how many days remain before each account's password expires.

### 🔐 Password Never Expires
- Lists accounts with the `PasswordNeverExpires` flag enabled.
- Highlights these in **red** for visibility (except the default `Administrator` account).

### 🛡️ Privileged Accounts Not in Protected Users Group
- Shows privileged accounts (like Domain Admins) that are **not** members of the `Protected Users` group.
- Ensures security policies are enforced for high-privilege accounts.

### 🧑‍💻 Broken Owner on Computer Objects
- Detects computer objects in AD whose **owner** is **not** a member of the `Domain Admins` group.

### 💻 Inactive Computers (45+ days)
- Lists computer accounts that haven’t logged in or been seen on the domain in over **45 days**.

---

## 🧾 Output

- The script generates an `ADHealthCheck.html` file.
- This file is automatically uploaded to a **remote FTP share** at the end of the script.
- Reports can be viewed from any browser by accessing the central FTP location.

---

## ⚠️ Notes

- The script is designed to **run locally** on a domain controller or management workstation.
- It assumes **no internet connectivity** and relies solely on internal AD data and services.
- It does **not send email notifications** – reporting is handled via HTML output.
- Helps meet several security checks recommended by **ANSSI's ORADAD** script.

---

## 📁 File Location

[Script on GitHub](https://github.com/GeoHolz/SysAdmin/blob/master/docs/active-directory/ADHealthCheck.ps1)

---

> Maintained by: [GeoHolz](https://github.com/GeoHolz)
