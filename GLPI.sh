#!/bin/bash

# La première ligne indique que le script doit être exécuté avec bash

# Mise à jour du système
echo "Mise à jour du système..."
# Mise à jour de la liste des paquets disponibles
sudo apt update
# Mise à jour des paquets installés
sudo apt upgrade -y

# Installation des dépendances
echo "Installation des dépendances..."
# Installation des paquets nécessaires pour GLPI
sudo apt install -y apache2 mariadb-server php php-mysql libapache2-mod-php php-xml php-mbstring php-gd php-curl php-intl php-json php-ldap php-cas php-apcu php-imagick php-zip

# Configuration de MariaDB
echo "Configuration de la base de données..."
# Connexion à MariaDB et exécution des commandes SQL pour créer la base de données et l'utilisateur
sudo mysql -u root <<-EOF
CREATE DATABASE glpi;
CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Téléchargement de GLPI
echo "Téléchargement de GLPI..."
# Téléchargement de GLPI à partir de l'URL spécifiée
wget -P /tmp https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz

# Extraction et déplacement des fichiers de GLPI
echo "Installation de GLPI..."
# Extraction de l'archive téléchargée
tar xzf /tmp/glpi-10.0.7.tgz -C /tmp
# Déplacement des fichiers extraits vers le répertoire du serveur web
sudo mv /tmp/glpi /var/www/html/

# Configuration d'Apache
echo "Configuration d'Apache..."
# Modification des permissions du répertoire de GLPI pour que le serveur web puisse y accéder
sudo chown -R www-data:www-data /var/www/html/glpi
# Activation du module 'rewrite' d'Apache, nécessaire pour GLPI
sudo a2enmod rewrite
# Redémarrage du serveur web pour prendre en compte les modifications
sudo systemctl restart apache2

# Message final indiquant que l'installation est terminée
echo "Installation terminée. Vous pouvez maintenant accéder à GLPI à l'adresse http://<votre_adresse_ip>/glpi"
