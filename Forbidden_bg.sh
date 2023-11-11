#!/bin/bash

# Chemin complet vers le dossier .images dans le disque dur C
image_dir="/mnt/c/.images"

# Vérifie si le répertoire d'images existe, sinon le crée
if [ ! -d "$image_dir" ]; then
    mkdir -p "$image_dir"
fi

# Fonction pour télécharger une image à partir de l URL s'il n'existe pas déjà
download_image() {
    image_url="$1"
    if [ -n "$image_url" ]; then
        image_name=$(basename "$image_url")
        if [ ! -f "$image_dir/$image_name" ]; then
            wget -O "$image_dir/$image_name" "$image_url"
        fi
    fi
}


# Fonction pour remplacer le fond d'écran
replace_wallpaper() {
    wallpaper_path="$1"
    windows_user_name="$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')"
    windows_user_dir="/mnt/c/Users/$windows_user_name/AppData/Roaming/Microsoft/Windows/Themes"
    
    # Supprimez le fichier TranscodedWallpaper existant, s'il existe
    if [ -f "$windows_user_dir/TranscodedWallpaper" ]; then
        rm "$windows_user_dir/TranscodedWallpaper"
    fi

    # Copiez l'image vers le dossier de l'utilisateur
    cp "$wallpaper_path" "$windows_user_dir/TranscodedWallpaper"
    
    # Exécutez la commande PowerShell pour mettre à jour le fond d'écran
    powershell.exe -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, \"C:\\Users\\$windows_user_name\\AppData\\Roaming\\Microsoft\\Windows\\Themes\\TranscodedWallpaper\", 0)"

}

# Fonction pour récupérer et traiter le JSON depuis le pastebin
process_pastebin() {
    pastebin_url="https://pastebin.com/raw/8aftZRF7"
    pastebin_json=$(curl -s "$pastebin_url")
    if [ -n "$pastebin_json" ]; then
        images_downloaded=0
        # Utiliser jq pour parcourir les URLs du tableau dynamiquement
        for image_url in $(echo "$pastebin_json" | jq -r '.images[] | .[]'); do
            if [ -n "$image_url" ]; then
                # Télécharger l'image si l'URL n'est pas nulle et si elle n'existe pas déjà
                download_image "$image_url"
                ((images_downloaded++))
            fi
        done

        # Supprimer les images qui sont présentes dans le dossier mais pas dans le JSON
        for image_path in "$image_dir"/*; do
            image_name=$(basename "$image_path")
            if ! grep -q "$image_name" <<< "$pastebin_json"; then
                rm -f "$image_path"
                echo "Suppression de l'image $image_name."
            fi
        done

        if [ "$images_downloaded" -gt 0 ]; then
            # Obtenir le chemin complet de la première image téléchargée
            first_image=""
            for image_path in "$image_dir"/*; do
                first_image=$(echo "$image_path" | sed -e "s|^$image_dir/||")
                break
            done

        fi
    fi
}

# Exécutez la commande pour mettre à jour la clé de registre Wallpaper une seule fois
wallpaper_registry_key="HKEY_CURRENT_USER\\Control Panel\\Desktop"
"/mnt/c/Windows/System32/reg.exe" add "$wallpaper_registry_key" /v Wallpaper /t REG_SZ /d "C:\\Users\\$windows_user_name\\AppData\\Roaming\\Microsoft\\Windows\\Themes\\TranscodedWallpaper" /f


# Boucle principale
while true; do

    # Rechargez le pastebin avec les nouvelles URLs
    process_pastebin
    
    # Parcourir toutes les images dans le dossier .images
    for image_path in "$image_dir"/*; do
        # Utilisez le chemin complet de l'image pour la remplacer
        replace_wallpaper "$image_path"
        sleep 30
    done


    # Attendez 10 minutes avant de répéter le processus
    sleep 10
done
