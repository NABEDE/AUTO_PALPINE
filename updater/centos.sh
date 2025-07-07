#!/bin/bash

# Source common functions
# shellcheck source=../common/script.sh
# . "$(dirname "$0")/../common/script.sh"

update_centos() {
    echo -e "\e[32mCentOS update process started.\e[0m"

    if prompt_yes_no "Voulez-vous mettre à jour le système ?"; then
        echo -e "\e[33m🔄 Mise à jour du système en cours...\e[0m"
        sudo yum update -y > /dev/null 2>&1
        check_success "Mise à jour du système (yum update)"
        
        if prompt_yes_no "Voulez-vous installer les paquets de sécurité ?"; then
            echo -e "\e[33m🔐 Installation des paquets de sécurité...\e[0m"
            
            echo -e "\e[33m🔧 Installation du dépôt EPEL (Extra Packages for Enterprise Linux)...\e[0m"
            sudo yum install -y epel-release > /dev/null 2>&1
            check_success "Installation du dépôt EPEL"
            
            # CentOS uses firewalld by default, clamav-update for freshclam daemon
            sudo yum install -y fail2ban clamav clamav-update firewalld yum-cron > /dev/null 2>&1
            check_success "Installation des paquets de sécurité (fail2ban, clamav, firewalld, yum-cron)"
            
            echo -e "\e[33m⚙️ Configuration de fail2ban...\e[0m"
            if [ ! -f /etc/fail2ban/jail.local ] && [ -f /etc/fail2ban/jail.conf ]; then
                sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
            fi
            sudo systemctl enable fail2ban > /dev/null 2>&1
            sudo systemctl start fail2ban > /dev/null 2>&1
            check_success "Configuration et activation de fail2ban"

            echo -e "\e[33m⚙️ Configuration de ClamAV...\e[0m"
            # clamav-update service handles freshclam on CentOS/RHEL
            # Need to remove/comment out 'Example' line in freshclam.conf for it to work
            sudo sed -i -e 's/^Example/#Example/' /etc/freshclam.conf
            sudo systemctl enable clamav-freshclam > /dev/null 2>&1 # systemd service for freshclam
            sudo systemctl start clamav-freshclam > /dev/null 2>&1
            check_success "Activation de clamav-freshclam pour les mises à jour des signatures"
            # Run freshclam manually once to ensure it works and for immediate update
            sudo freshclam > /dev/null 2>&1
            check_success "Mise à jour initiale des signatures ClamAV (freshclam)"
            # Enable and start clamd service for on-demand/on-access scanning if desired (clamd@scan.service)
            # For simplicity, we are focusing on freshclam here as per original script
            sudo systemctl enable clamd@scan > /dev/null 2>&1 # Using clamd@scan for modern CentOS
            sudo systemctl start clamd@scan > /dev/null 2>&1
            check_success "Activation du service ClamAV (clamd@scan)"

            echo -e "\e[33m🔒 Configuration du pare-feu firewalld...\e[0m"
            sudo systemctl enable firewalld > /dev/null 2>&1
            sudo systemctl start firewalld > /dev/null 2>&1
            sudo firewall-cmd --permanent --add-service=ssh > /dev/null 2>&1 # Ensure SSH is allowed
            sudo firewall-cmd --reload > /dev/null 2>&1
            check_success "Configuration du pare-feu firewalld"

            echo -e "\e[33m🔧 Configuration des mises à jour automatiques (yum-cron)...\e[0m"
            # Configure yum-cron to apply updates
            sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
            sudo systemctl enable yum-cron > /dev/null 2>&1
            sudo systemctl start yum-cron > /dev/null 2>&1
            check_success "Configuration des mises à jour automatiques (yum-cron)"

            echo -e "\e[32m✅ Installation et configuration des paquets de sécurité terminées.\e[0m"
        else
            echo -e "\e[33mℹ️ Installation des paquets de sécurité annulée.\e[0m"
        fi
    else
        echo -e "\e[33mℹ️ Mise à jour du système annulée.\e[0m"
    fi
    echo -e "\e[32mCentOS update process terminé.\e[0m"
} 