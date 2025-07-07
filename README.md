# Script d'Automatisation Système

Ce script bash automatise diverses tâches de maintenance notamment la mise à jour du système Linux Alpine.

## Table des Matières

- [Fonctionnalités](#fonctionnalités)
- [Prérequis (Exécution directe)](#prérequis-exécution-directe)
- [Utilisation (Exécution directe)](#utilisation-exécution-directe)
- [Utilisation (Avec Docker)](#utilisation-avec-docker)
  - [Prérequis (Docker)](#prérequis-docker)
  - [Étapes (Docker)](#étapes-docker)

## Fonctionnalités

- Automatisation des mises à jour des systèmes Linux ( Alpine, Debian, Ubuntu et CentOS)
- Installation optionnelle de paquets de sécurité (fail2ban, clamav, ufw)
- Vérification de la connectivité Internet
- Détection du système d'exploitation (actuellement focus sur Alpine)
- Menu interactif pour choisir l'action

## Prérequis (Exécution directe)

- Un système d'exploitation Linux
- Accès à Internet
- `bash` installé
- Privilèges `root` ou `sudo` pour l'installation des paquets et la gestion des services.

## Utilisation (Exécution directe)

1.  Cloner l'application dépuis GitHub.
    ```bash
    git clone git clone https://github.com/NABEDE/AUTO_PALPINE-1.0.git
    ```
2.  Rendez le script exécutable :
    ```bash
    chmod +x autopalpine-v1.sh
    ```
3.  Exécutez le script :
    ```bash
    sudo ./autopalpine-v1.sh
    #Ou
    sudo bash autopalpine-v1.sh
    #Ou avec le root
    ./autopalpine-v1.sh
    ```
4.  Suivez les instructions interactives.

## Utilisation (Avec Docker)

Vous pouvez également exécuter ce script dans un environnement conteneurisé en utilisant Docker et Docker Compose.
Cela est particulièrement utilise si vous développez sur un autre OS.

### Prérequis (Docker)

- Docker Desktop (ou Docker Engine + Docker Compose) installé et en cours d'exécution.

### Étapes (Docker)

1.  Clonez ce dépôt ou assurez-vous d'avoir les fichiers `autopalpine-v1.sh`, `Dockerfile`, et `docker-compose.yml` dans le même répertoire.
2.  Ouvrez un terminal dans ce répertoire.
3.  Construisez l'image Docker :
    ```bash
    docker-compose up --build -d
    ```
4.  Exécutez le script de manière interactive dans un conteneur :
    ```bash
    docker-compose exec alpine-test /bin/sh

    # S'il n'a pas de permission pour exécuter le fichier autopalpine-v1.sh
    chmod +x autopalpine-v1.sh
    
    # puis dans le conteneur :
    ./autopalpine-v1.sh

    ```
5.  Le script démarrera dans le terminal, et vous pourrez interagir avec lui.
