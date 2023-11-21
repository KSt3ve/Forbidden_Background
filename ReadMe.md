# Forbidden_Background

## Overview

Forbidden_Background is a collection of bash and powershell scripts designed to remotely take control of a computer's background.

## Version and Status
- Version: 1.0
- Update: 21/11/2023
- Status: stable

## Features

- Bash scipt for quick background pc control (disapear after reboot pc) - The bash script will allow you to take control of a computer background only one time (the script will not re-run after )
- Powershell script to change and maintains control  (even after reboot) - The Powershell 
- Remote computer background control
- Update of wallpapers displayed on computer via poastebin

## Installation

### 1. Download the script on the computer

To Take control of a computer background, you need to close the repo with the files on the computer
```
git clone https://github.com/KSt3ve/Forbidden_Background
```

### 2. Create the pastebin

You need to create a pastebin account on ```https://pastebin.com/``` and set ```Paste Expiration:``` to Never

Next, fill the pastebin like this : 
```
{
    "images":[
            {
		"image_1": "https://images4.alphacoders.com/201/20198.jpg",
        "image_2": "..."
        }
    ]
}
```

### 3. Change the different informations in the code

Change the pastebin id in Forbidden_bg.ps1 and Forbidden_bg.sh
```
pastebin_url="https://pastebin.com/raw/Your_Pastebin_ID"
```

Chaneg the directory where you want your images to be : 

#### For Bash Script:

Forbidden_bg.sh : ```image_dir="/mnt/c/Your/Path"```


#### For PowerShell Script:

Forbidden_bg.ps1 : ```$imageDir = "C:\Your\Path"```

CreateScheduledTask.ps1 : ```$powerShellScriptPath = "C:\Path_To_Ps1_File\Forbidden_bg.ps1"``` et ```$taskName = "Your_Task_Name"```

### 4.  Script Execution Instructions

#### For Bash Script:

1. Open a Linux terminal.
2. Navigate to the script directory.
3. Run the following command: `./Forbidden_bg.sh`

#### For PowerShell Script:

1. Place the `Forbidden_bg.ps1` file in the same path specified in the `CreateScheduledTask.ps1` file under `$powerShellScriptPath`.
2. Open a PowerShell terminal with administrative privileges.
3. Run the command: `./CreateScheduledTask.ps1`
4. The script will create a scheduled task in the Windows Task Scheduler, ensuring that the `Forbidden_bg.ps1` program is executed on every computer startup.


### project made by KSt3ve
