#!/bin/bash

# Source common functions
# shellcheck source=../common/script.sh
# . "$(dirname "$0")/../common/script.sh"

update_debian() {
    echo -e "\e[32mDebian update process started.\e[0m"

    if prompt_yes_no "Voulez-vous mettre à jour le système ?"; then
        echo -e "\e[33m🔄 Mise à jour du système en cours...\e[0m"
        sudo apt update -y > /dev/null 2>&1
        check_success "Vérification des mises à jour (apt update)"
        sudo apt upgrade -y > /dev/null 2>&1
        check_success "Mise à jour du système (apt upgrade)"
        
        if prompt_yes_no "Voulez-vous installer les paquets de sécurité ?"; then
            echo -e "\e[33m🔐 Installation des paquets de sécurité...\e[0m"
            
            # For Debian, clamav-freshclam is often a separate package or handled by clamav-daemon service
            sudo apt install -y fail2ban clamav clamav-daemon ufw unattended-upgrades > /dev/null 2>&1
            check_success "Installation des paquets de sécurité (fail2ban, clamav, ufw, unattended-upgrades)"
            
            echo -e "\e[33m⚙️ Configuration de fail2ban...\e[0m"
            sudo systemctl enable fail2ban > /dev/null 2>&1
            sudo systemctl start fail2ban > /dev/null 2>&1
            check_success "Activation de fail2ban"

            echo -e "\e[33m⚙️ Configuration de ClamAV...\e[0m"
            sudo freshclam > /dev/null 2>&1
            check_success "Mise à jour des signatures ClamAV (freshclam)"
            sudo systemctl enable clamav-daemon > /dev/null 2>&1 # Ensure daemon is enabled for scans and updates
            sudo systemctl start clamav-daemon > /dev/null 2>&1
            check_success "Activation du démon ClamAV"

            echo -e "\e[33m🔧 Activation des mises à jour automatiques (unattended-upgrades)...\e[0m"
            # The -plow should make it non-interactive, but good to be aware
            sudo dpkg-reconfigure -plow unattended-upgrades > /dev/null 2>&1 
            check_success "Configuration de unattended-upgrades"

            echo -e "\e[33m🔒 Activation du pare-feu UFW...\e[0m"
            # Non-interactive ufw enable
            echo "y" | sudo ufw enable > /dev/null 2>&1
            check_success "Activation du pare-feu UFW"
            echo -e "\e[32m✅ Installation et configuration des paquets de sécurité terminées.\e[0m"
        else
            echo -e "\e[33mℹ️ Installation des paquets de sécurité annulée.\e[0m"
        fi
    else
        echo -e "\e[33mℹ️ Mise à jour du système annulée.\e[0m"
    fi
    echo -e "\e[32mDebian update process terminé.\e[0m"
} 