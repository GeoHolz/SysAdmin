#!/usr/bin/env python3
from ipaddress import ip_address
import subprocess
import tempfile

# --- Configuration ---
# IMPORTANT : Retire les paramètres dans l'URL (id et token doivent faire partie du chemin si possible,
# sinon garde la query string mais c'est moins recommandé)

PRTG_URL = "http://192.168.1.5:5050/YOUR_TOKEN"

pools = {
    "Pool1": [
        ("192.168.1.10", "192.168.1.250")
    ],
    "Pool2": [
        ("172.17.1.20", "172.17.1.254")

    ]
}

# --- Fonctions ---
def ip_range(start, end):
    start_ip = ip_address(start)
    end_ip = ip_address(end)
    return {str(ip_address(int(start_ip) + i)) for i in range(int(end_ip) - int(start_ip) + 1)}

# --- Génération des IP par pool ---
pool_ranges = {}
for pool_name, ranges in pools.items():
    all_ips = set()
    for start, end in ranges:
        all_ips |= ip_range(start, end)
    pool_ranges[pool_name] = all_ips

# --- Lecture du fichier leases ---
used_ips = set()
with open('/var/lib/dhcp/dhcpd.leases', 'r') as f:
    lease_block = []
    in_lease = False
    for line in f:
        line = line.strip()
        if line.startswith('lease '):
            lease_block = [line]
            in_lease = True
        elif in_lease:
            lease_block.append(line)
            if line == '}':
                lease_text = '\n'.join(lease_block)
                if 'binding state active;' in lease_text:
                    ip = lease_block[0].split()[1]
                    used_ips.add(ip)
                in_lease = False

# --- Construction de l'XML ---
xml = "<prtg>"
for pool_name, ip_set in pool_ranges.items():
    used = sum(1 for ip in used_ips if ip in ip_set)
    total = len(ip_set)
    percent = int((used / total * 100)) if total else 0

    # Limites dynamiques pour IPs utilisées (valeurs brutes)
    warning_limit = int(total * 0.85)
    error_limit = int(total * 0.95)

    # Canal brut
    xml += (
        f"<result><channel>{pool_name} Used IPs</channel>"
        f"<value>{used}</value>"
        f"<limitmode>1</limitmode>"
        f"<limitmaxwarning>{warning_limit}</limitmaxwarning>"
        f"<limitmaxerror>{error_limit}</limitmaxerror>"
        f"</result>"
    )

    # Canal pourcentage — limites fixes
    xml += (
        f"<result><channel>{pool_name} Usage %</channel>"
        f"<value>{percent}</value><unit>Percent</unit>"
        f"<limitmode>1</limitmode>"
        f"<limitmaxwarning>85</limitmaxwarning>"
        f"<limitmaxerror>95</limitmaxerror>"
        f"</result>"
    )
xml += "</prtg>"


print("=== XML envoyé à PRTG ===")
print(xml)
print("="*40)

# --- Envoi via wget en POST, avec Content-Type application/xml ---
with tempfile.NamedTemporaryFile("w", delete=False) as tmp:
    tmp.write(xml)
    tmp.flush()
    subprocess.run([
        "wget",
        "--quiet",
        "--method=POST",
        "--header=Content-Type: application/xml",
        "--body-file", tmp.name,
        "--no-proxy",
        "-O", "/dev/null",
        PRTG_URL
    ])
