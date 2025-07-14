#!/bin/bash

#=============================================================
# Script de mise à jour et sécurisation d'Alpine Linux
# -----------------------------------------------------------
# - Met à jour le système
# - Installe et configure fail2ban, clamav, ufw, OpenRC
# - Utilise des confirmations interactives
#=============================================================

set -e

# Source common functions
# shellcheck source=../common/script.sh
. "$(dirname "$0")/../common/script.sh"

# Variables
SECURITY_PACKAGES=("fail2ban" "openrc" "clamav" "clamav-libunrar" "ufw")

install_security_packages() {
    echo -e "\e[33m🔐 Installation des paquets de sécurité...\e[0m"
    for pkg in "${SECURITY_PACKAGES[@]}"; do
        echo -e "\e[33m Installation de $pkg ...\e[0m"
        if apk add "$pkg"; then
            check_success "Installation de $pkg"
        else
            echo -e "\e[31m❌ Échec de l'installation de $pkg.\e[0m"
        fi
    done
}

configure_fail2ban() {
    echo -e "\e[33m⚙️ Configuration et activation de fail2ban...\e[0m"
    rc-update add fail2ban default
    rc-service fail2ban start
    check_success "Activation de fail2ban"
}

configure_clamav() {
    echo -e "\e[33m📥 Mise à jour des signatures de clamav...\e[0m"
    freshclam
    check_success "Mise à jour des signatures ClamAV"
}

configure_ufw() {
    echo -e "\e[33m Installation et activation du firewall ufw...\e[0m"
    if ufw enable <<EOF
y
EOF
    then
        echo -e "\e[32m✅ Activation du firewall ufw réussie.\e[0m"
        echo -e "\e[35m💡 Pensez à configurer les règles ufw avant de fermer votre session SSH :\n  Exemple : ufw allow ssh\e[0m"
    else
        echo -e "\e[31m❌ Échec de l'activation du firewall ufw.\e[0m"
        echo -e "\e[35m💡 Vous pouvez activer manuellement le firewall ufw avec la commande suivante : sudo ufw enable\e[0m"
    fi
}

update_alpine() {
    echo -e "\e[32mAlpine Linux update process started.\e[0m"

    if prompt_yes_no "𝐕𝐨𝐮𝐬 voulez que l'installation 𝐝𝐞𝐬 𝐦𝐢𝐬𝐞𝐬 𝐚̀ 𝐣𝐨𝐮𝐫 𝐜𝐨𝐦𝐦𝐞𝐧𝐜𝐞 ?"; then
        echo -e "\e[33m✅ 𝐌𝐢𝐬𝐞 𝐚̀ 𝐣𝐨𝐮𝐫 𝐝𝐮 𝐬𝐲𝐬𝐭𝐞̀𝐦𝐞 𝐞𝐧 𝐜𝐨𝐮𝐫𝐬...\e[0m"
        apk update && apk upgrade
        check_success "Mise à jour du système"

        if prompt_yes_no "Est ce que vous voulez que j'installe les paquets de sécurité sur le système ?"; then
            install_security_packages
            configure_fail2ban
            configure_clamav
            configure_ufw
            echo -e "\e[32m✅ Installation et configuration des paquets de sécurité terminées.\e[0m"
        else
            echo -e "\e[33mℹ️ Installation des paquets de sécurité annulée.\e[0m"
        fi
    else
        echo -e "\e[31m❌ Mise à jour 𝐚𝐧𝐧𝐮𝐥𝐞́𝐞.\e[0m"
    fi
    echo -e "\e[32mAlpine Linux update process terminé.\e[0m"
}

# Appel de la fonction principale
# update_alpine