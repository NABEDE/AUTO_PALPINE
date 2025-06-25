#!/bin/bash

# Exit on any error not explicitly handled
set -e

# --- Configuration & Globals ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT_PATH="${SCRIPT_DIR}/common/script.sh"
UPDATER_DIR="${SCRIPT_DIR}/updater"

# --- Source Common Script ---
# shellcheck source=common/script.sh
if ! . "${COMMON_SCRIPT_PATH}"; then
    echo "ERROR: Failed to source ${COMMON_SCRIPT_PATH}. Ensure the file exists and is executable." >&2
    exit 1
fi

# --- Functions ---

display_welcome_message() {
    echo -e "\\e[35m=======================================================================\\e[0m"
    echo -e "\\e[35m🤖 𝐇𝐞𝐥𝐥𝐨 ! 𝐁𝐢𝐞𝐧𝐯𝐞𝐧𝐮𝐞 𝐬𝐮𝐫 𝐯𝐨𝐭𝐫𝐞 𝐚𝐬𝐬𝐢𝐬𝐭𝐚𝐧𝐭 𝐚𝐮𝐭𝐨𝐩𝐚𝐥𝐩𝐢𝐧𝐞 𝐕𝐞𝐫𝐬𝐢𝐨𝐧 𝟏.𝟎 (Refactored)\\e[0m"
    echo -e "\\e[35m𝐏𝐨𝐮𝐫 𝐥\\'𝐚𝐮𝐭𝐨𝐦𝐚𝐭𝐢𝐬𝐚𝐭𝐢𝐨𝐧 𝐝𝐞𝐬 𝐦𝐢𝐬𝐞𝐬 𝐚̀ 𝐣𝐨𝐮𝐫 𝐝𝐞 𝐯𝐨𝐭𝐫𝐞 𝐬𝐲𝐬𝐭𝐞̀𝐦𝐞 𝐋𝐢𝐧𝐮𝐱\\e[0m"
    echo -e "\\e[35m( 𝐀𝐥𝐩𝐢𝐧𝐞, 𝐔𝐛𝐮𝐧𝐭𝐮, 𝐃𝐞𝐛𝐢𝐚𝐧 𝐞𝐭 𝐂𝐞𝐧𝐭𝐎𝐒 )\\e[0m"
    echo -e "\\e[35m=======================================================================\\e[0m"
}

display_menu() {
    echo
    echo "Choisissez la distribution Linux pour laquelle exécuter les actions :"
    echo "1. Alpine"
    echo "2. Ubuntu"
    echo "3. Debian"
    echo "4. CentOS"
    echo "5. Quitter"
    # Store the choice in a global-like variable MENU_CHOICE for the main loop to access
    read -r -p "Choisissez un numéro entre 1 et 5 : " MENU_CHOICE
    echo
}

# Handles sourcing and executing the chosen updater script
# Arguments:
#   $1: Distribution display name (e.g., "Alpine Linux")
#   $2: Script file name in UPDATER_DIR (e.g., "alpine.sh")
#   $3: Function to call within the script (e.g., "update_alpine")
#   $4: Pattern to match against $SYSTEM_DETECTED (e.g., "alpine")
#   $5: Comma-separated list of additional patterns for RHEL-like distros (optional)
handle_distro_update() {
    local distro_display_name="$1"
    local script_name="$2"
    local function_to_call="$3"
    local primary_os_pattern="$4"
    local additional_patterns_csv="$5" # Renamed for clarity
    local script_path="${UPDATER_DIR}/${script_name}"

    local match_found=0
    # Primary OS pattern check (case-insensitive for $SYSTEM_DETECTED)
    if [[ "${SYSTEM_DETECTED,,}" == *"${primary_os_pattern,,}"* ]]; then
        match_found=1
    # Check additional patterns if provided (case-insensitive)
    elif [ -n "$additional_patterns_csv" ]; then
        IFS=',' read -ra patterns <<< "$additional_patterns_csv"
        for pattern in "${patterns[@]}"; do
            if [[ "${SYSTEM_DETECTED,,}" == *"${pattern,,}"* ]]; then
                match_found=1
                break
            fi
        done
    fi

    if [ "$match_found" -eq 1 ]; then
        echo -e "\\e[32m✅ Le système détecté ($SYSTEM_DETECTED) correspond à ${distro_display_name}.\\e[0m"
        # shellcheck source=/dev/null
        if . "${script_path}"; then # Source the script
            if type "$function_to_call" &>/dev/null; then # Check if function exists
                "$function_to_call" # Call the function
            else
                echo -e "\\e[31m❌ Erreur: La fonction ${function_to_call} n'est pas définie dans ${script_path}.\\e[0m"
            fi
        else
            echo -e "\\e[31m❌ Erreur: Impossible de sourcer ${script_path}.\\e[0m"
        fi
    else
        echo -e "\\e[31m❌ Le système détecté ($SYSTEM_DETECTED) n'est pas ${distro_display_name} ou une distribution compatible. Opération annulée pour cette option.\\e[0m"
    fi
}

# --- Main Logic ---
main() {
    # Initial checks
    if ! check_internet; then
        # check_internet already prints an error, so just exit
        exit 1
    fi

    # SYSTEM_DETECTED is made "global" by not declaring it local.
    # It's set here and used by handle_distro_update.
    # shellcheck disable=SC2034 # Used by handle_distro_update via indirection
    SYSTEM_DETECTED=$(detect_os)
    if [ -z "$SYSTEM_DETECTED" ]; then
        echo -e "\\e[31m❌ Impossible de détecter le système d'exploitation. Arrêt du script.\\e[0m"
        exit 1
    fi
    echo -e "\\e[36mℹ️ Système d'exploitation détecté : $SYSTEM_DETECTED\\e[0m"

    display_welcome_message

    # Main interaction loop
    while true; do
        display_menu # Sets MENU_CHOICE
        case "$MENU_CHOICE" in
            1) handle_distro_update "Alpine Linux" "alpine.sh" "update_alpine" "alpine" ;;
            2) handle_distro_update "Ubuntu" "ubuntu.sh" "update_ubuntu" "ubuntu" ;;
            3) handle_distro_update "Debian" "debian.sh" "update_debian" "debian" ;;
            4) handle_distro_update "CentOS/RHEL compatible" "centos.sh" "update_centos" "centos" "rhel,rocky,almalinux" ;;
            5) echo -e "\\e[32m✅ Vous avez choisi de quitter le script. Au revoir !\\e[0m"; exit 0 ;;
            *) echo -e "\\e[31m❌ Choix invalide. Veuillez entrer un numéro entre 1 et 5.\\e[0m" ;;
        esac
        echo -e "\\e[35m-----------------------------------------------------------------------\e[0m" # Separator
    done
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main
fi 