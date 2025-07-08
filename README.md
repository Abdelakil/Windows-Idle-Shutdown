# Idle Shutdown Script

This PowerShell script monitors user idle time and automatically shuts down the computer after a specified period of inactivity, providing warnings before shutdown.

## Features

* Monitors system idle time.
* Provides a notification at 15 minutes of idle time.
* Provides a final warning notification at 25 minutes of idle time.
* Initiates a forced computer shutdown after 30 minutes of continuous idle time.
* Resets idle warnings if the user becomes active again.
* Logs script start time to a specified file.

## Requirements

* **PowerShell 5.1 or newer** (comes pre-installed on Windows 10/11).
* **BurntToast Module**: This script uses the `BurntToast` PowerShell module for sending toast notifications to the Windows Action Center.

### Installing BurntToast

If you don't have BurntToast installed, open PowerShell as an Administrator and run:

```powershell
Install-Module -Name BurntToast -Scope CurrentUser
```

If you encounter issues with script execution policy, you might need to set it. **Use caution when changing execution policies.** For more information, refer to Microsoft's documentation on `Set-ExecutionPolicy`. A common approach for running signed scripts is:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## How to Use

1.  **Save the Script**:
    Save the provided PowerShell code into a file named `idle-shutdown.ps1` (or any `.ps1` extension) in a location like `C:\IdleShutdownScript\`.

2.  **Configure Log File (Optional but Recommended)**:
    The script logs its start time to `C:\IdleShutdownScript\idle-check.log`. Ensure the directory `C:\IdleShutdownScript\` exists, or change the `$logFile` variable in the script to a path of your choice.

    ```powershell
    # In the script, modify this line if needed:
    $logFile = "C:\IdleShutdownScript\idle-check.log"
    ```

3.  **Run the Script**:
    You can run the script manually by navigating to its directory in PowerShell and executing:

    ```powershell
    .\idle-shutdown.ps1
    ```

    **Note**: For continuous monitoring, this script is designed to run indefinitely in a loop.

4.  **Automate with Task Scheduler (Recommended for continuous monitoring)**:
    For the script to run automatically when Windows starts and in the background, it's best to set it up using Windows Task Scheduler.

    * Open **Task Scheduler** (search for it in the Start Menu).
    * Click `Create Basic Task...` on the right-hand pane.
    * **Name**: `Idle Shutdown Monitor` (or similar)
    * **Trigger**: `When the computer starts`
    * **Action**: `Start a program`
    * **Program/script**: `powershell.exe`
    * **Add arguments (optional)**:
        ```
        -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\IdleShutdownScript\idle-shutdown.ps1"
        ```
        * `-NoProfile`: Prevents loading the PowerShell profile.
        * `-WindowStyle Hidden`: Runs the PowerShell window hidden in the background.
        * `-ExecutionPolicy Bypass`: Bypasses the execution policy for this script only.
        * `-File "C:\IdleShutdownScript\idle-shutdown.ps1"`: Specifies the path to your script. **Adjust this path to where you saved your script.**
    * Click `Next` and `Finish`.
    * After creation, find your task, right-click it, and select `Properties`.
    * On the `General` tab, select `Run whether user is logged on or not` and `Run with highest privileges`.
    * Click `OK` and enter your credentials if prompted.

## Customization

You can adjust the idle thresholds in the script:

```powershell
# Idle thresholds (in seconds)
$notify1Threshold = 15 * 60     # 15 minutes
$notify2Threshold = 25 * 60     # 25 minutes
$shutdownThreshold = 30 * 60    # 30 minutes
```

Change the `Start-Sleep -Seconds 5` value at the end of the `while` loop to adjust how frequently the script checks for idle time. A smaller number will check more often but use slightly more resources.

## Important Considerations

* **Forced Shutdown**: The script uses `Stop-Computer -Force`, which will immediately shut down the computer without saving open work. **Ensure users are aware of this behavior.**
* **Notifications**: Notifications rely on the BurntToast module and Windows Action Center. Ensure notifications are enabled for PowerShell if you don't see them.
* **Logging**: The log file will only contain the "Script started" entry each time the script begins. It does not log idle events or shutdowns.
* **Testing**: Thoroughly test the script in a non-critical environment before deploying it widely.

## Troubleshooting

* **Script doesn't run**: Check your PowerShell execution policy.
* **No notifications**: Ensure the BurntToast module is installed correctly and that Windows notifications are enabled.
* **Script doesn't shut down**: Verify the idle thresholds and ensure the script is running continuously (e.g., via Task Scheduler). Check the log file for "Script started" entries to confirm it's being initiated.
