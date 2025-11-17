# DHCP Pool Usage to PRTG

This Python script reads your ISC DHCP server's `dhcpd.leases` file and pushes per-pool usage statistics to PRTG using the HTTP Push Data Advanced Sensor.

## 🌟 Purpose

Monitor DHCP pool usage in PRTG by sending:

- 📊 The number of IPs in use per pool
- 📈 The percentage of pool usage
- ⚠️ Automatic warning (85%) and critical (95%) thresholds

---

## ⚙️ How It Works

1. You manually define your DHCP IP pools in the script.
2. The script parses `/var/lib/dhcp/dhcpd.leases`, collecting all leases in `binding state active`.
3. For each pool, it calculates:
   - Number of used IPs
   - Pool usage in percent
   - Dynamic thresholds (raw count) and fixed thresholds (percentage)
4. An XML compatible with PRTG's Push Sensor is built.
5. It is sent via `POST` to the HTTP Push Data Advanced Sensor.

---

## 💡 Configuration

### 1. Define your DHCP pools

Edit this section in the script:

```python
pools = {
    "Pool1": [
        ("192.168.1.10", "192.168.1.250")
    ],
    "Pool2": [
        ("172.17.1.20", "172.17.1.254")
    ]
}
```

Each pool name maps to one or more (start IP, end IP) ranges.

### 2. Set your PRTG URL

Replace the following line with your actual sensor URL:

```python
PRTG_URL = "http://192.168.1.5:5050/YOUR_TOKEN"
```

You get this URL from your PRTG HTTP Push Data Advanced sensor.

---

## 📤 Data Sent to PRTG

For each pool, the script sends **two channels**:

- `Pool1 Used IPs` → Number of active IPs (with dynamic limits)
- `Pool1 Usage %` → Percent usage (with static limits: 85/95)

---

## 📁 File Location

[Script on GitHub](https://github.com/GeoHolz/SysAdmin/blob/master/docs/linux/dhcp-to-prtg.py)

## ⏰ Crontab Example

To run the script every 5 minutes:

```bash
*/5 * * * * /usr/bin/python3 /opt/scripts/dhcp-to-prtg.py
```

Ensure:

- The path to Python is correct (`which python3`)
- The script is executable (`chmod +x`)
- It has permission to read `/var/lib/dhcp/dhcpd.leases`

---

## 🔢 Example XML Sent

```xml
<prtg>
  <result>
    <channel>Pool1 Used IPs</channel>
    <value>183</value>
    <limitmode>1</limitmode>
    <limitmaxwarning>204</limitmaxwarning>
    <limitmaxerror>228</limitmaxerror>
  </result>
  <result>
    <channel>Pool1 Usage %</channel>
    <value>91</value>
    <unit>Percent</unit>
    <limitmode>1</limitmode>
    <limitmaxwarning>85</limitmaxwarning>
    <limitmaxerror>95</limitmaxerror>
  </result>
</prtg>
```

---

## 📆 Requirements

- Python 3 (standard library only)
- `wget` installed
- A configured PRTG HTTP Push Data Advanced sensor

---

## 🔐 Security

- The script uses the sensor's secure URL/token combo.
- For added security:
  - Restrict access to the PRTG push port
  - Use HTTPS if available
  - Run the script as a limited user

