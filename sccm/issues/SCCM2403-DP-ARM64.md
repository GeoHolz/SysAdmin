# Issue with SCCM 2403 Update: Distribution Points Not Working

## Problem Description

After updating SCCM to version 2403, all remote distribution points (DPs) stopped working, while the local DP continued to work. The following errors were found in the `SMSPXE.log` file located on DP:

```
RegQueryValueExW failed for Software\Microsoft\SMS\DP, UnknownARM64GUID
RegReadString failed; 0x80070002
PXE::CPolicyProviderSettings::LoadPXEDBSettings failed; 0x80070002  
Failed to initialize PXE Provider. Unknown error (Error: 80070002;Source: Unknown) 
PXE::CPolicyProvider::Initialize failed; 0x80070002  
Failed to initialize PXE provider. Unknown error (Error: 80070002; Source: Unknown) 
```

## Root Cause

The issue was traced back to missing registry keys for ARM64 boot images on the remote distribution points. These keys were present on the local DP but missing on the remote DPs.

- HKEY_LOCAL_MACHINE\Software\Microsoft\SMS\DP\UnknownARM64GUID REG_SZ
- HKEY_LOCAL_MACHINE\Software\Microsoft\SMS\DP\UnknownARM64ItemKey REG_DWORD

## Solution

To resolve the issue, the missing registry keys were copied from the functioning local DP to the remote DPs. Here are the steps taken:

1. **Export Registry Keys from Local DP**:
    - Open `Registry Editor` on the local DP.
    - Navigate to `HKEY_LOCAL_MACHINE\Software\Microsoft\SMS\DP`.
    - Export the relevant keys related to ARM64 boot images.

2. **Import Registry Keys to Remote DPs**:
    - Transfer the exported `.reg` file to the remote DPs.
    - Open `Registry Editor` on each remote DP.
    - Import the `.reg` file to add the missing keys.


## Verification

After applying the above steps, the remote DPs started functioning correctly, and the errors in the `SMSPXE.log` file were resolved.