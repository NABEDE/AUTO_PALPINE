#!/bin/bash

# Source common functions
# shellcheck source=../common/script.sh
if [[ -f "$(dirname "$0")/../common/script.sh" ]]; then
    . "$(dirname "$0")/../common/script.sh"
fi

LOG_FILE="/var/log/update_ubuntu.log"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "\e[31m❌ Ce script doit être exécuté en tant que root ou via sudo.\e[0m"
        exit 1
    fi
}

update_system() {
    echo -e "\e[33m🔄 Mise à jour du système en cours...\e[0m"
    log_action "Début de mise à jour apt"
    apt update -y > /dev/null 2>&1
    check_success "Vérification des mises à jour (apt update)"
    apt upgrade -y > /dev/null 2>&1
    check_success "Mise à jour du système (apt upgrade)"
    log_action "Fin de mise à jour apt"
}

install_security_packages() {
    echo -e "\e[33m🔐 Installation des paquets de sécurité...\e[0m"
    log_action "Installation des paquets de sécurité"
    apt install -y fail2ban clamav clamav-daemon ufw unattended-upgrades > /dev/null 2>&1
    check_success "Installation des paquets de sécurité"
}

configure_fail2ban() {
    echo -e "\e[33m⚙️ Configuration de fail2ban...\e[0m"
    systemctl enable fail2ban > /dev/null 2>&1
    systemctl start fail2ban > /dev/null 2>&1
    check_success "Activation de fail2ban"
    log_action "Fail2ban configuré"
}

configure_clamav() {
    echo -e "\e[33m⚙️ Configuration de ClamAV...\e[0m"
    freshclam > /dev/null 2>&1
    check_success "Mise à jour des signatures ClamAV (freshclam)"
    systemctl enable clamav-daemon > /dev/null 2>&1
    systemctl start clamav-daemon > /dev/null 2>&1
    check_success "Activation du démon ClamAV"
    log_action "ClamAV configuré"
}

configure_unattended_upgrades() {
    echo -e "\e[33m🔧 Activation des mises à jour automatiques...\e[0m"
    dpkg-reconfigure -plow unattended-upgrades > /dev/null 2>&1
    check_success "Configuration de unattended-upgrades"
    log_action "Unattended-upgrades configuré"
}

configure_ufw() {
    echo -e "\e[33m🔒 Activation du pare-feu UFW...\e[0m"
    ufw allow 22 > /dev/null 2>&1
    log_action "UFW : SSH autorisé"
    echo "y" | ufw enable > /dev/null 2>&1
    check_success "Activation du pare-feu UFW"
    log_action "UFW activé"
}

update_ubuntu() {
    check_sudo
    echo -e "\e[32mUbuntu update process started.\e[0m"
    log_action "Process update_ubuntu démarré"

    if prompt_yes_no "Voulez-vous mettre à jour le système ?"; then
        update_system

        if prompt_yes_no "Voulez-vous installer les paquets de sécurité ?"; then
            install_security_packages
            configure_fail2ban
            configure_clamav
            configure_unattended_upgrades
            configure_ufw
            echo -e "\e[32m✅ Installation et configuration des paquets de sécurité terminées.\e[0m"
            log_action "Paquets de sécurité installés et configurés"
        else
            echo -e "\e[33mℹ️ Installation des paquets de sécurité annulée.\e[0m"
            log_action "Installation des paquets de sécurité annulée"
        fi
    else
        echo -e "\e[33mℹ️ Mise à jour du système annulée.\e[0m"
        log_action "Mise à jour système annulée"
    fi
    echo -e "\e[32mUbuntu update process terminé.\e[0m"
    log_action "Process update_ubuntu terminé"
}