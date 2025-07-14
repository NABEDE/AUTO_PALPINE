#!/bin/bash
#=============================================================
# Script de mise à jour et sécurisation de Debian
# -----------------------------------------------------------
# - Met à jour le système
# - Installe et configure fail2ban, clamav, ufw, OpenRC
# - Utilise des confirmations interactives
#=============================================================


# Chemin vers le fichier de log
LOG_FILE="/var/log/update_debian.log"

# Paquets de sécurité par défaut
SECURITY_PACKAGES=(fail2ban clamav clamav-daemon ufw unattended-upgrades)

# Ports à autoriser via UFW (par défaut SSH)
UFW_ALLOW_PORTS=(22)

# Import des fonctions communes si disponibles
COMMON_SCRIPT="$(dirname "$0")/../common/script.sh"
if [[ -f "$COMMON_SCRIPT" ]]; then
    . "$COMMON_SCRIPT"
fi

# Log une action avec horodatage
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Vérifie que l'utilisateur a les droits sudo
check_sudo() {
    if [[ "$EUID" -ne 0 ]]; then
        log_action "Erreur : ce script doit être exécuté en tant que root ou avec sudo."
        exit 1
    fi
}

# Affiche un message en couleur
color_echo() {
    local color="$1"
    local message="$2"
    echo -e "$color$message\e[0m"
}

# Vérifie le succès d'une commande
check_success() {
    if [[ $? -eq 0 ]]; then
        log_action "Succès : $1"
    else
        log_action "Échec : $1"
        color_echo "\e[31m" "❌ Échec lors de : $1. Voir $LOG_FILE pour les détails."
        exit 1
    fi
}

# Mise à jour du système Debian
update_system() {
    color_echo "\e[32m" "🔄 Démarrage de la mise à jour du système Debian..."
    log_action "Début de la mise à jour du système"
    apt update -y >> "$LOG_FILE" 2>&1
    check_success "apt update"
    apt upgrade -y >> "$LOG_FILE" 2>&1
    check_success "apt upgrade"
}

# Installation des paquets de sécurité
install_security_packages() {
    color_echo "\e[33m" "🔐 Installation des paquets de sécurité : ${SECURITY_PACKAGES[*]}"
    log_action "Installation des paquets de sécurité"
    apt install -y "${SECURITY_PACKAGES[@]}" >> "$LOG_FILE" 2>&1
    check_success "installation des paquets de sécurité"
}

# Configuration de fail2ban
configure_fail2ban() {
    color_echo "\e[33m" "⚙️ Configuration de fail2ban..."
    log_action "Activation de fail2ban"
    systemctl enable fail2ban >> "$LOG_FILE" 2>&1
    systemctl start fail2ban >> "$LOG_FILE" 2>&1
    check_success "activation fail2ban"
}

# Configuration de ClamAV
configure_clamav() {
    color_echo "\e[33m" "⚙️ Configuration de ClamAV..."
    log_action "Mise à jour des signatures ClamAV"
    freshclam >> "$LOG_FILE" 2>&1
    check_success "mise à jour des signatures ClamAV"
    systemctl enable clamav-daemon >> "$LOG_FILE" 2>&1
    systemctl start clamav-daemon >> "$LOG_FILE" 2>&1
    check_success "activation clamav-daemon"
}

# Configuration des mises à jour automatiques
configure_unattended_upgrades() {
    color_echo "\e[33m" "🔧 Activation des mises à jour automatiques..."
    log_action "Configuration unattended-upgrades"
    dpkg-reconfigure -plow unattended-upgrades >> "$LOG_FILE" 2>&1
    check_success "configuration unattended-upgrades"
}

# Configuration du pare-feu UFW
configure_ufw() {
    color_echo "\e[33m" "🔒 Configuration du pare-feu UFW..."
    log_action "Configuration du pare-feu UFW"

    for port in "${UFW_ALLOW_PORTS[@]}"; do
        ufw allow "$port" >> "$LOG_FILE" 2>&1
        check_success "autorisation du port $port sur UFW"
    done

    echo "y" | ufw enable >> "$LOG_FILE" 2>&1
    check_success "activation du pare-feu UFW"
}

# Demande à l'utilisateur avec validation (oui/non)
prompt_yes_no() {
    local question="$1"
    local response
    while true; do
        read -rp "$question [o/n]: " response
        case "$response" in
            [oO]|[oO][uU][iI]) return 0 ;;
            [nN]|[nN][oO][nN]) return 1 ;;
            *) echo "Répondez par o(oui) ou n(non)." ;;
        esac
    done
}

main() {
    check_sudo

    color_echo "\e[32m" "====== Script de mise à jour et sécurisation Debian ======"
    log_action "Script lancé"

    if prompt_yes_no "Voulez-vous mettre à jour le système ?"; then
        update_system
    else
        color_echo "\e[33m" "ℹ️ Mise à jour du système annulée."
        log_action "Mise à jour du système annulée"
    fi

    if prompt_yes_no "Voulez-vous installer et configurer les paquets de sécurité ?"; then
        install_security_packages
        configure_fail2ban
        configure_clamav
        configure_unattended_upgrades
        configure_ufw
        color_echo "\e[32m" "✅ Installation et configuration des paquets de sécurité terminées."
        log_action "Sécurisation terminée"
    else
        color_echo "\e[33m" "ℹ️ Installation des paquets de sécurité annulée."
        log_action "Installation des paquets de sécurité annulée"
    fi

    color_echo "\e[32m" "====== Script terminé ======"
    log_action "Script terminé"
}

main "$@"