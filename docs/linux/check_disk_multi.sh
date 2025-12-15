#!/bin/bash
echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
echo "<prtg>"

# MODIFICATION : Ajout de filtres pour Kubernetes/k0s/Containerd
# On exclut les lignes contenant : k0s, containerd, docker, kubelet, overlay, shm
df -P -h -x nfs -x nfs4 -x cifs | grep -vE '^Filesystem|tmpfs|cdrom|overlay|run|devtmpfs|k0s|containerd|docker|kubelet|shm' | while read line
do
    MOUNT=$(echo $line | awk '{print $6}')
    USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
    
    NAME=$(echo $MOUNT | sed 's/\//_/g')
    [ "$NAME" == "_" ] && NAME="_root"
    
    echo "<result>"
    echo "<channel>$MOUNT</channel>"
    echo "<value>$USAGE</value>"
    echo "<unit>Percent</unit>"
    echo "<limitmode>1</limitmode>" 
    echo "<limitmaxerror>95</limitmaxerror>"
    echo "<limitmaxwarning>90</limitmaxwarning>"
    echo "</result>"
done
echo "</prtg>"