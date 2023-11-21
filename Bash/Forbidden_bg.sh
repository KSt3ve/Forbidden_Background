#!/bin/bash

# Url of the pastebin to store my image urls
pastebin_url="https://pastebin.com/raw/Your_Pastebin_ID"

# Full path to the folder where you want to put your images - Modfied it

image_dir="/mnt/c/Your/Path"

# Function to create the image_dir directory
create_image_dir() {
    # Extract the parent directory path
    parent_dir=$(dirname "$image_dir")

    # Checks if the parent directory exists, if not creates it
    if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
    fi

    # Checks if the image directory exists, if not creates it
    if [ ! -d "$image_dir" ]; then
        mkdir -p "$image_dir"
    fi
}


# Function to download an image from the URL if it does not already exist
download_image() {
    image_url="$1"
    if [ -n "$image_url" ]; then
        image_name=$(basename "$image_url")
        if [ ! -f "$image_dir/$image_name" ]; then
            wget -O "$image_dir/$image_name" "$image_url"
        fi
    fi
}


# Function to replace the wallpaper
replace_wallpaper() {
    wallpaper_path="$1"
    windows_user_name="$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')"
    windows_user_dir="/mnt/c/Users/$windows_user_name/AppData/Roaming/Microsoft/Windows/Themes"
    
    # Delete the existing TranscodedWallpaper file, if it exists
    if [ -f "$windows_user_dir/TranscodedWallpaper" ]; then
        rm "$windows_user_dir/TranscodedWallpaper"
    fi

    # Copy the image to the user's folder
    cp "$wallpaper_path" "$windows_user_dir/TranscodedWallpaper"
    
    # Run the PowerShell command to update the wallpaper
    powershell.exe -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, \"C:\\Users\\$windows_user_name\\AppData\\Roaming\\Microsoft\\Windows\\Themes\\TranscodedWallpaper\", 0)"

}

# Function for retrieving and processing JSON from pastebin
process_pastebin() {
    pastebin_json=$(curl -s "$pastebin_url")
    if [ -n "$pastebin_json" ]; then
        images_downloaded=0
        # Use jq to browse table URLs dynamically
        for image_url in $(echo "$pastebin_json" | jq -r '.images[] | .[]'); do
            if [ -n "$image_url" ]; then
                # Download the image if the URL is not null and if it does not already exist
                download_image "$image_url"
                ((images_downloaded++))
            fi
        done

        # Delete images that are present in the folder but not in the JSON
        for image_path in "$image_dir"/*; do
            image_name=$(basename "$image_path")
            if ! grep -q "$image_name" <<< "$pastebin_json"; then
                rm -f "$image_path"
            fi
        done

        if [ "$images_downloaded" -gt 0 ]; then
            # Obtain the full path of the first image downloaded
            first_image=""
            for image_path in "$image_dir"/*; do
                first_image=$(echo "$image_path" | sed -e "s|^$image_dir/||")
                break
            done

        fi
    fi
}

# Run the command to update the Wallpaper registry key once only
wallpaper_registry_key="HKEY_CURRENT_USER\\Control Panel\\Desktop"
"/mnt/c/Windows/System32/reg.exe" add "$wallpaper_registry_key" /v Wallpaper /t REG_SZ /d "C:\\Users\\$windows_user_name\\AppData\\Roaming\\Microsoft\\Windows\\Themes\\TranscodedWallpaper" /f


# Création du dossier
create_image_dir

# Main loop
while true; do

    # Reload the pastebin with the new URLs
    process_pastebin
    
    # Browse all images in the .images folder
    for image_path in "$image_dir"/*; do
        # Use the full path of the image to replace it
        replace_wallpaper "$image_path"
        sleep 30
    done

    # Wait 10 minutes before repeating the process
    sleep 10
done

# Run your program in the background with nohup
nohup ./Forbidden_bg.sh > /dev/null 2>&1 &