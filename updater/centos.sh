#!/bin/bash

#=============================================================
# Script de mise à jour et sécurisation de CentOS
# -----------------------------------------------------------
# - Met à jour le système
# - Installe et configure fail2ban, clamav, firewalld, yum-cron
# - Utilise des confirmations interactives
#=============================================================

set -e

# Source des fonctions communes
# shellcheck source=../common/script.sh
. "$(dirname "$0")/../common/script.sh"

SECURITY_PACKAGES=("fail2ban" "clamav" "clamav-update" "firewalld" "yum-cron")
EPEL_PACKAGE="epel-release"
SERVICES=("fail2ban" "clamav-freshclam" "clamd@scan" "firewalld" "yum-cron")

install_epel() {
    echo -e "\e[33m🔧 Installation du dépôt EPEL...\e[0m"
    sudo yum install -y "$EPEL_PACKAGE" > /dev/null 2>&1
    check_success "Installation du dépôt EPEL"
}

install_security_packages() {
    echo -e "\e[33m🔐 Installation des paquets de sécurité...\e[0m"
    sudo yum install -y "${SECURITY_PACKAGES[@]}" > /dev/null 2>&1
    check_success "Installation des paquets de sécurité"
}

enable_and_start_service() {
    local service=$1
    sudo systemctl enable "$service" > /dev/null 2>&1
    sudo systemctl start "$service" > /dev/null 2>&1
    check_success "Activation du service $service"
}

configure_fail2ban() {
    echo -e "\e[33m⚙️ Configuration de fail2ban...\e[0m"
    if [ ! -f /etc/fail2ban/jail.local ] && [ -f /etc/fail2ban/jail.conf ]; then
        sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    fi
    enable_and_start_service "fail2ban"
}

configure_clamav() {
    echo -e "\e[33m⚙️ Configuration de ClamAV...\e[0m"
    sudo sed -i -e 's/^Example/#Example/' /etc/freshclam.conf
    enable_and_start_service "clamav-freshclam"
    sudo freshclam > /dev/null 2>&1
    check_success "Mise à jour initiale des signatures ClamAV (freshclam)"
    enable_and_start_service "clamd@scan"
}

configure_firewalld() {
    echo -e "\e[33m🔒 Configuration du pare-feu firewalld...\e[0m"
    enable_and_start_service "firewalld"
    sudo firewall-cmd --permanent --add-service=ssh > /dev/null 2>&1
    sudo firewall-cmd --reload > /dev/null 2>&1
    check_success "Configuration du pare-feu firewalld"
    echo -e "\e[35m💡 Pensez à configurer vos règles firewalld pour vos services (ex. : sudo firewall-cmd --permanent --add-service=http)\e[0m"
}

configure_yum_cron() {
    echo -e "\e[33m🔧 Configuration des mises à jour automatiques (yum-cron)...\e[0m"
    sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
    enable_and_start_service "yum-cron"
}

update_centos() {
    echo -e "\e[32mCentOS update process started.\e[0m"

    if prompt_yes_no "Voulez-vous mettre à jour le système ?"; then
        echo -e "\e[33m🔄 Mise à jour du système en cours...\e[0m"
        sudo yum update -y > /dev/null 2>&1
        check_success "Mise à jour du système"

        if prompt_yes_no "Voulez-vous installer les paquets de sécurité ?"; then
            install_epel
            install_security_packages
            configure_fail2ban
            configure_clamav
            configure_firewalld
            configure_yum_cron
            echo -e "\e[32m✅ Installation et configuration des paquets de sécurité terminées.\e[0m"
        else
            echo -e "\e[33mℹ️ Installation des paquets de sécurité annulée.\e[0m"
        fi
    else
        echo -e "\e[33mℹ️ Mise à jour du système annulée.\e[0m"
    fi
    echo -e "\e[32mCentOS update process terminé.\e[0m"
}

# Appel de la fonction principale
# update_centos