$logFile = "C:\IdleShutdownScript\idle-check.log"
Add-Content $logFile "$(Get-Date) - Script started"
Import-Module BurntToast -ErrorAction SilentlyContinue

function Get-IdleTimeInSeconds {
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class IdleTimeHelper {
    [DllImport("user32.dll")]
    static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public static uint GetIdleTime() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
        GetLastInputInfo(ref lii);
        return ((uint)Environment.TickCount - lii.dwTime) / 1000;
    }
}
"@

    return [IdleTimeHelper]::GetIdleTime()
}

# Idle thresholds (in seconds)
$notify1Threshold = 15 * 60     # 15 minutes
$notify2Threshold = 25 * 60     # 25 minutes
$shutdownThreshold = 30 * 60    # 30 minutes

# State flags
$notified15m = $false
$notified25m = $false
$shutdownInitiated = $false

while ($true) {
    $idleTime = Get-IdleTimeInSeconds

    if ($idleTime -ge $notify1Threshold -and -not $notified15m) {
        New-BurntToastNotification -Text "Idle Warning", "You've been idle for 15 minutes."
        $notified15m = $true
    }

    if ($idleTime -ge $notify2Threshold -and -not $notified25m) {
        New-BurntToastNotification -Text "Final Warning", "Idle for 25 minutes. Shutdown in 5 minutes..."
        $notified25m = $true
    }

    if ($idleTime -ge $shutdownThreshold -and -not $shutdownInitiated) {
        New-BurntToastNotification -Text "Shutting Down", "Idle for 30 minutes. Shutting down now."
        Start-Sleep -Seconds 1
        Stop-Computer -Force
        $shutdownInitiated = $true
    }

    # Reset if user becomes active again
    if ($idleTime -lt $notify1Threshold) {
        $notified15m = $false
        $notified25m = $false
        $shutdownInitiated = $false
    }

    Start-Sleep -Seconds 5
}