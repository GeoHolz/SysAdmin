# 🛠️ Extend C: Drive on Windows Server When Recovery Partition Blocks Resize

On Windows Server (e.g., 2022) hosted on ESXi, it's common to extend the virtual disk from vSphere, but **Disk Management** won't allow extension of C: if a small **recovery partition** exists after it.

This guide explains how to temporarily remove, then recreate, the recovery partition to free up space for extending C:.

---
![Disk layout before extension](images/diskmgmt.png)

## ✅ Steps Summary

### 1. Disable Recovery Environment
```
reagentc /disable
```

---

### 2. Remove Recovery Partition with Diskpart
```
diskpart
list disk
select disk <#>
list partition
select partition <#>   ← identify the Recovery partition
delete partition override
exit
```

---

### 3. Extend C: Drive

- Open **Disk Management**
- Extend the C: partition **leaving ~1024 MB** of unallocated space at the end  
  (this is needed for re-creating the recovery partition)

---

### 4. Recreate Recovery Partition

- In Disk Management:  
  - Create a **New Simple Volume** in unallocated space  
  - Format as **NTFS**, **no drive letter**

---

### 5. Mark the New Partition as Recovery (Diskpart)
```
diskpart
list disk
select disk <#>
list partition
select partition <#>   ← the new 1024 MB partition
```

#### For GPT Disks:
```
set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
gpt attributes=0x8000000000000001
```

#### For MBR Disks:
```
set id=27
```

```
exit
```

---

### 6. Re-enable Recovery Environment
```
reagentc /enable
```

---

## 🧠 Notes

- Always **back up** before modifying partitions.
- Do **not** assign a drive letter to the new recovery partition.
- Works on Windows Server 2016, 2019, 2022 and Windows 10/11.
