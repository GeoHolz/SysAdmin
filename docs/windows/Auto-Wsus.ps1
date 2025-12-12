<#
.SYNOPSIS 
Decline and delete unnecessary updates for Windows 11 in Windows Server Update Services (WSUS).

.DESCRIPTION 
Decline several types of WSUS updates, such as preview, beta, superseded, language packs, and drivers. 
It specifically targets and declines updates for architectures other than x64 (ARM and x86), and focuses 
on keeping only updates relevant to Windows 11 (21H2, 22H2, 23H2).
The script also offers the option to clean up and delete already declined updates.

.PARAMETER AutoDecline 
Decline WSUS updates that are preview, beta, superseded, language packs, or drivers. Decline all updates 
for ARM and x86 architectures. Any update not targeted for an approved Windows 11 version (21H2, 22H2, 23H2) 
will also be declined.

.PARAMETER DeleteDeclined
Delete from WSUS all updates that are marked as declined.

.PARAMETER WsusCleanup
Start the cleanup process on the WSUS server. This parameter takes precedence over all others. If both WsusCleanup and WsusSync are selected, the script will first perform a cleanup and then sync.
The script will wait until the cleanup is completed, then process the other operations, if any.

.PARAMETER Server
The WSUS server. Deafult is localhost.

.PARAMETER UseSSL
If SSL is needed to connect to the WSUS server. Default is False.

.PARAMETER PortNumber
The port number used by WSUS. Default is 8530.

.EXAMPLE 
.\Auto-WSUSUpdates.ps1 -AutoDecline -DeleteDeclined 
Decline all unnecessary updates (preview, superseded, x86/ARM, non-Win11) and then delete all updates marked as declined from the server.

.EXAMPLE 
.\Auto-WSUSUpdates.ps1 -WsusCleanup -AutoDecline
Start the WSUS cleanup process, then decline all updates that are not needed for the target Windows 11 versions.

#>
[cmdletbinding()]
Param(
    [Parameter(Position = 1)]
    [string]$Server = ([system.net.dns]::GetHostByName('localhost')).hostname,
    [Parameter(Position = 2)]
    [bool]$UseSSL = $False,
    [Parameter(Position = 3)]
    [int]$PortNumber = 8530,    
    [switch]$AutoDecline,
    [switch]$DeleteDeclined,
    [switch]$WsusCleanup
)

$versions = @(
    'Windows 11 Version 21H2',
    'Windows 11 Version 22H2',
    'Windows 11 Version 23H2'
)
try {
    [reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | out-null    
}
catch {
    Write-Host 'Could not load the Microsoft.UpdateServices.Administration assembly.'
    exit
}

try {
    $WsusServer = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($Server, $UseSSL, $PortNumber)
}
catch {
    Write-Host 'Could not connect to the WSUS server.'
    exit
}

if ($WsusCleanup) {
    Write-Host 'Starting the cleanup process. This will take a while.'
    $cleanupScope = new-object Microsoft.UpdateServices.Administration.CleanupScope
    $cleanupScope.CleanupLocalPublishedContentFiles = $true
    $cleanupScope.CleanupObsoleteComputers = $true
    $cleanupScope.CleanupObsoleteUpdates = $true
    $cleanupScope.CleanupUnneededContentFiles = $true
    $cleanupScope.CompressUpdates = $true
    $cleanupScope.DeclineExpiredUpdates = $true
    $cleanupScope.DeclineSupersededUpdates = $true
    $cleanupManager = $wsusServer.getCleanupManager()
    $res = $cleanupManager.PerformCleanup($cleanupScope)
    Write-Host 'Cleanup results'
    Write-Host ('Disk space freed: ' + ($res.DiskSpaceFreed/1MB) + ' MB')
    Write-Host ('Expired updates declined: ' + $res.ExpiredUpdatesDeclined)
    Write-Host ('Obsolete computers deleted: ' + $res.ObsoleteComputersDeleted)
    Write-Host ('Obsolete updates deleted: ' + $res.ObsoleteUpdatesDeleted) 	    
    Write-Host ('Superseded updates declined: ' + $res.SupersededUpdatesDeclined)
    Write-Host ('Updates with old revisions removed: ' + $res.UpdatesCompressed)
    Write-Host ''    
}




if ($AutoDecline) {
    $allUpdates = $WsusServer.GetUpdates()
    $totalCount = $allUpdates.count
    $declinedCount = 0
    foreach ($update in $allUpdates) {            
        # Skip updates that are already declined
        if ($update.IsDeclined) {
            continue
        }


        # Decline all updates in Preview or Beta
        if (($update.Title -match "preview|beta|dev channel") -or ($update.IsBeta -eq $true)) {
            $update.Decline()
            $declinedCount = $declinedCount + 1
            continue
        }
    
        # Decline superseeded updates
        if ($update.IsSuperseded -eq $true) {
            $update.Decline()
            $declinedCount = $declinedCount + 1
            continue
        }
    
        # Decline updates for Arm64
        if ($update.Title -match "ARM64") {
            $update.Decline()
            $declinedCount = $declinedCount + 1
            continue
        }
    
        # Decline updates for x86
        # The title can contain either 'x86-based' or 'x86 based' text
        if ($update.Title -like "*x86?based*") {
            $update.Decline()
            $declinedCount = $declinedCount + 1
            continue
        }
    
        # Decline updates for old versions of Windows 10    
        $declined = $false
        foreach ($v in $versions) {
            if ($update.Title -match $v) {
                $update.Decline()
                $declinedCount = $declinedCount + 1
                $declined = $true
                break
            }
        }
        if ($declined) {
            continue
        }

        # Decline Language packs
        if ($update.Title -match "LanguageFeatureOnDemand|Lang Pack (Language Feature) Feature On Demand|LanguageInterfacePack") {
            $update.Decline()
            $declinedCount = $declinedCount + 1
            continue
        }

        # Decline driver updates
        if ($update.Classification -match "Drivers") {
            $update.Decline()
            $declinedCount = $declinedCount + 1
            continue
        }   
    }
    Write-Host "Declined $declinedCount updates out of $totalCount."
}

# Delete all declined updates
if ($DeleteDeclined) {
    # get all declined updates
    $allDeclined = $WsusServer.GetUpdates([Microsoft.UpdateServices.Administration.ApprovedStates]::Declined, [DateTime]::MinValue, [DateTime]::MaxValue, $null, $null)
    Write-Host ('' + $allDeclined.count + ' declined updates found')
    $count = 0
    foreach ($update in $allDeclined) {
        $WsusServer.DeleteUpdate($update.Id.UpdateId.ToString())
        $count++
    }
    Write-Host "$count updates deleted."
}



