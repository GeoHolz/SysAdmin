#!/bin/bash

# Configuration Gotify
GOTIFY_URL="http://URL_TO_GOTIFY/message?token=XXXXXXXXX"
TITLE="Alerte RAID"
MD_DEVICE="/dev/md127"

# Récupération des détails
DETAIL=$(mdadm --detail "$MD_DEVICE")
# On récupère l'état et on nettoie les espaces/virgules
STATE=$(echo "$DETAIL" | grep "State :" | awk -F': ' '{print $2}' | xargs)

# --- FILTRE DES ÉTATS NORMAUX ---
# On ignore si l'état est purement "clean" ou "active"
if [[ "$STATE" == "clean" ]] || [[ "$STATE" == "active" ]]; then
  exit 0
fi

# Récupération des compteurs
ACTIVE=$(echo "$DETAIL" | grep "Active Devices" | awk '{print $4}')
FAILED=$(echo "$DETAIL" | grep "Failed Devices" | awk '{print $4}')
WORKING=$(echo "$DETAIL" | grep "Working Devices" | awk '{print $4}')

# Construction du message
MESSAGE="⚠️ Problème détecté sur $MD_DEVICE
État actuel : $STATE

Statistiques :
- Actifs : $ACTIVE
- En panne : $FAILED
- Fonctionnels : $WORKING"

# Ajout des disques fautifs
DISKS_IN_FAULT=$(echo "$DETAIL" | grep -E "faulty|removed")
if [ -n "$DISKS_IN_FAULT" ]; then
  MESSAGE="$MESSAGE

Disques concernés :
$DISKS_IN_FAULT"
fi

# Envoi Gotify (Priorité 8 pour resync, 10 pour panne réelle)
PRIORITY=10
[[ "$STATE" == *"resync"* ]] && PRIORITY=8

curl -s -S -X POST "$GOTIFY_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"$TITLE\",
    \"message\": \"$MESSAGE\",
    \"priority\": $PRIORITY
  }"
