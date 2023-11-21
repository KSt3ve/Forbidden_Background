# Url of the pastebin to store my image urls
$pastebinUrl = "https://pastebin.com/raw/Your_Pastebin_ID"

# Full path to the .images folder on hard disk C
$imageDir = "C:\Your\Path"

# Function to create the imageDir
function Invoke-CreateImageDir {
    param (
        [string]$imageDir
    )

    $parentDir = Split-Path -Path $imageDir

    if (-not (Test-Path -Path $parentDir -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parentDir
    }

    if (-not (Test-Path -Path $imageDir -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $imageDir
    }
}

# Function to download an image from the URL if it does not already exist
function Invoke-ImageDownload {
    param (
        [string]$imageUrl
    )

    try {
        $uri = New-Object System.Uri($imageUrl)
    } catch {
        return
    }

    $imageName = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    $imagePath = Join-Path -Path $imageDir -ChildPath $imageName

    Write-Host "Image path: $imagePath"

    if (-not (Test-Path -Path $imagePath)) {
        try {
            powershell.exe -Command "Invoke-WebRequest -Uri $uri -OutFile $imagePath"
        } catch {
            return
        }
    } else {
        Write-Host "Image already exists at $imagePath"
    }
}

# Function to replace the wallpaper
function Invoke-ReplaceWallpaper {
    param (
        [string]$wallpaperPath
    )

    $windowsUserName = $env:USERNAME
    $windowsUserDir = "C:\Users\$windowsUserName\AppData\Roaming\Microsoft\Windows\Themes"

    $transcodedWallpaperPath = Join-Path -Path $windowsUserDir -ChildPath "TranscodedWallpaper"
    if (Test-Path -Path $transcodedWallpaperPath) {
        Remove-Item -Path $transcodedWallpaperPath
    }

    Copy-Item -Path $wallpaperPath -Destination $transcodedWallpaperPath

    # Run the PowerShell command to update the wallpaper
    Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@
    [Wallpaper]::SystemParametersInfo(20, 0, "$transcodedWallpaperPath", 0)
}

# Function for retrieving and processing JSON from pastebin
function Invoke-ProcessPastebin {
    $pastebinJson = Invoke-RestMethod -Uri $pastebinUrl

    if ($null -ne $pastebinJson -and $pastebinJson.images -is [array]) {
        $imagesToKeep = @()

        foreach ($imageObject in $pastebinJson.images) {
            foreach ($imageUrl in $imageObject.PSObject.Properties.Value) {
                Invoke-ImageDownload -imageUrl $imageUrl

                $imageName = [System.IO.Path]::GetFileName((New-Object System.Uri($imageUrl)).AbsolutePath)
                $imagesToKeep += $imageName
            }
        }

        Get-ChildItem -Path $imageDir | Where-Object { $_.Name -notin $imagesToKeep } | Remove-Item -Force
    }
}


# Run the command to update the Wallpaper registry key once only
$wallpaperRegistryKey = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $wallpaperRegistryKey -Name Wallpaper -Value "C:\Users\$windowsUserName\AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"

Invoke-CreateImageDir $imageDir

# Main loop
while ($true) {
    # Reload the pastebin with the new URLs
    Invoke-ProcessPastebin

    # Browse all images in the .images folder
    Get-ChildItem -Path $imageDir | ForEach-Object {
        Invoke-ReplaceWallpaper -wallpaperPath $_.FullName
        Start-Sleep -Seconds 600
    }
}
