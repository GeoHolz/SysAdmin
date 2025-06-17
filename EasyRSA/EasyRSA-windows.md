# 🛡️ Using EasyRSA Certificates in a Windows Domain

This guide explains how to generate a server certificate with **EasyRSA**, including a **Subject Alternative Name (SAN)**, and how to convert it into a format compatible with **Windows systems**, particularly for use with Active Directory, IIS, RDP, or LDAPS.

---

## ✅ Overview

- Use EasyRSA to generate a server certificate with private key and SAN entries.  
- Convert the certificate to PFX format with OpenSSL for Windows compatibility.  
- Import the certificate in Windows for use in services.

---

## 🏗️ Step-by-Step Instructions

### 1. Generate a Server Certificate with SAN

Use the following command to create a server certificate that includes SANs (Subject Alternative Names):

`easyrsa --subject-alt-name="DNS=serv.example.com,DNS=serv" build-server-full serv.example.com nopass`

📌 This generates:
- A private key: `pki/private/serv.example.com.key`  
- A signed certificate: `pki/issued/serv.example.com.crt`  


---

### 2. Convert Certificate and Key to PFX (PKCS#12 format)

Use OpenSSL to combine the certificate, its private key, and the CA certificate into a `.pfx` file, which can be imported into Windows:

```
openssl pkcs12 -export \
  -out cert.pfx \
  -inkey serv.example.com.key \
  -in serv.example.com.crt \
  -certfile ca.crt
```

🔐 You’ll be prompted to set a password to protect the `.pfx` file.

---

### 3. Import the PFX in Windows

- Double-click the `cert.pfx` file in Windows.  
- Follow the Certificate Import Wizard:
  - Store it in the **Personal** certificate store.  
  - Enable **“Mark this key as exportable”** if needed.
- The certificate is now usable in:
  - IIS (HTTPS binding)  
  - RDP (secure login)  
  - LDAPS (Active Directory)

---

## 🧠 Notes

- The `build-server-full` command automates key generation, CSR creation, and certificate signing.
- The `--subject-alt-name` flag is essential for compliance with modern TLS clients.
- Ideal for environments without a Microsoft CA, using a custom CA (like EasyRSA).

---

## 🔐 Security Tips

- Protect the `.pfx` file with a strong password.
- Restrict file system access to private keys and certificates.
- Use secure transfer methods (HTTPS, SCP, etc.) to move certificates between systems.
