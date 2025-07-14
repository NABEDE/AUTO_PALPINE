# AUTO_PALPINE : Script d'Automatisation Système Linux

Ce projet propose un script Bash complet pour automatiser les tâches de maintenance et de sécurisation sur plusieurs distributions Linux (Alpine, Debian, Ubuntu, CentOS).

---

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Prérequis](#prérequis)
  - [Exécution directe](#prérequis-exécution-directe)
  - [Avec Docker](#prérequis-docker)
- [Installation et Utilisation](#installation-et-utilisation)
  - [Exécution directe](#exécution-directe)
  - [Avec Docker](#avec-docker)
- [Structure du projet](#structure-du-projet)
- [Support & Contribution](#support--contribution)

---

## Fonctionnalités

- **Mise à jour automatisée** des systèmes Linux (Alpine, Debian, Ubuntu, CentOS)
- **Installation optionnelle de paquets de sécurité** (fail2ban, clamav, ufw, unattended-upgrades)
- **Vérification de la connectivité Internet**
- **Détection automatique** du système d'exploitation
- **Menu interactif** pour choisir les actions à effectuer
- **Exécution dans un conteneur Docker** pour une sécurité et une portabilité accrues

---

## Prérequis

### Exécution directe

- Un système Linux compatible (Alpine, Debian, Ubuntu, CentOS)
- Accès à Internet
- `bash` installé
- Droits administrateur (`sudo` ou root) pour l'installation et la configuration des paquets

### Avec Docker

- Docker Desktop ou Docker Engine + Docker Compose installés et en cours d'exécution
- Accès au terminal

---

## Installation et Utilisation

### Exécution directe

1. **Clonez le dépôt depuis GitHub :**
    ```bash
    git clone https://github.com/NABEDE/AUTO_PALPINE.git
    cd AUTO_PALPINE
    ```
2. **Rendez le script principal exécutable :**
    ```bash
    chmod +x autopalpine-v1.sh
    ```
3. **Lancez le script :**
    ```bash
    sudo ./autopalpine-v1.sh
    # Ou
    sudo bash autopalpine-v1.sh
    # En tant que root :
    ./autopalpine-v1.sh
    ```
4. **Suivez les instructions interactives affichées dans le terminal.**

---

### Avec Docker

1. **Assurez-vous que les fichiers `autopalpine-v1.sh`, `Dockerfile`, et `docker-compose.yml` sont présents dans le répertoire du projet.**
2. **Ouvrez un terminal dans ce répertoire.**
3. **Construisez et démarrez le conteneur :**
    ```bash
    docker-compose up --build -d
    ```
4. **Accédez au shell du conteneur :**
    ```bash
    docker-compose exec alpine-test /bin/sh
    ```
5. **Donnez les droits d’exécution au script si nécessaire :**
    ```bash
    chmod +x autopalpine-v1.sh
    ```
6. **Lancez le script dans le conteneur :**
    ```bash
    ./autopalpine-v1.sh
    ```
7. **Interagissez avec le menu du script dans le terminal.**

---

## Structure du projet

```
AUTO_PALPINE/
├── autopalpine-v1.sh         # Script principal d'automatisation
├── updater/                  # Scripts spécifiques par distribution (Alpine, Ubuntu, Debian, CentOS)
│   ├── alpine.sh
│   ├── ubuntu.sh
│   ├── debian.sh
│   └── centos.sh
├── common/                   # Fonctions communes utilisées par les scripts
│   └── script.sh
├── Dockerfile                # Image Docker pour l'exécution du script
├── docker-compose.yml        # Orchestration multi-conteneurs
└── README.md                 # Documentation
```

---

## Support & Contribution

- **Signalez un bug ou proposez une amélioration** via [Issues GitHub](https://github.com/NABEDE/AUTO_PALPINE/issues).
- **Contributions** (pull requests, suggestions, corrections, nouvelles distributions) sont les bienvenues !
- Pour toute question, contactez le mainteneur du projet.

---

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**Bon usage ! Ce script vous aide à automatiser l'administration de vos serveurs Linux de façon simple et efficace.**