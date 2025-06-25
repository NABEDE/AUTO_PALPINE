#!/bin/bash

# Définir les variables globales
THRESHOLD_MEMORY=80  # Seuil critique de la mémoire (en pourcentage)
THRESHOLD_SPACE=80  # Seuil critique d'espace disque (en pourcentage)

# Arrêter à la moindre erreur
# set -e # This will be in the main script or individual updater scripts if needed per function

# Fonction pour vérifier la connectivité Internet
check_internet() {
    echo -e "\e[34m🌐 Vérification de la connexion Internet...\e[0m"
    if wget -q --spider http://google.com; then
        echo -e "\e[32m✅ Connexion Internet détectée.\e[0m"
        return 0
    else
        echo -e "\e[31m❌ Aucune connexion Internet détectée. Veuillez vérifier votre réseau.\e[0m"
        return 1
    fi
}

check_success() {
    local status=$?
    local message="$1"
    local tolerate_failure="$2"  # peut être "true" ou vide

    if [ $status -eq 0 ]; then
        echo -e "\e[32m✅ $message réussi.\e[0m"
    else
        if [ "$tolerate_failure" = "true" ]; then
            echo -e "\e[33m⚠️ $message partiellement échoué, mais on continue...\e[0m"
        else
            echo -e "\e[31m❌ $message échoué. Vérifiez les erreurs et votre connexion internet.\e[0m"
            exit 1
        fi
    fi
}


# Fonction pour détecter le système d'exploitation
detect_os() {
    if [ -f /etc/os-release ]; then
        # Lecture du fichier os-release pour identifier le système
        grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]'
    elif type lsb_release >/dev/null 2>&1; then
        lsb_release -is | tr '[:upper:]' '[:lower:]'
    else
        # Si os-release n'existe pas, fallback sur uname
        uname -s | tr '[:upper:]' '[:lower:]'
    fi
}

# Fonction pour les prompts Oui/Non
prompt_yes_no() {
    while true; do
        read -p "$1 (O/N): " response
        case "$response" in
            [Oo]* ) return 0;; # Success (Yes)
            [Nn]* ) return 1;; # Failure (No)
            * ) echo -e "\e[31m❌ Réponse non valide. Veuillez taper O ou N.\e[0m";;
        esac
    done
}

# Common functions and variables will go here 
