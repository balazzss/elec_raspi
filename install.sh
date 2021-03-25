#!/bin/bash
#ajout d'une interface graphique
whiptail --title "Bienvenue" --msgbox "Bienvenue dans l'installation du raspberry pour le cours de systèmes embarqués" 8 78

#Vérifier la connexion à internet, si aucune alors quitte le programme
network () {
whiptail --title "Internet" --msgbox "Virification si nous avons bien accès à internet" 8 78
nc -z 8.8.8.8 53  >/dev/null 2>&1
online=$?
if [ $online -eq 0 ]; then
        whiptail --title "Connecté" --msgbox "Vous êtes bien connecté à internet!" 8 78
else
        whiptail --title "Non connecté" --msgbox "Vérifier la connexion à internet pour pouvoir continuer." 8 78
        clear
fi
}

update_upgrade () {
whiptail --title "Mise à jour des paquets" --msgbox "Mises à jour des paquets. Cela peut prendre un certain temps." 8 78
        clear
        if ! { sudo apt update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::apt update success
        else
            echo :::apt update failure
        fi
        if ! { sudo apt upgrade -y 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::apt upgrade success
        else
            echo :::apt upgrade failure
        fi
whiptail --title "Mise à jour des paquets" --msgbox "Mises à jour des paquets terminé" 8 78  
}

programms_install () {
whiptail --title "Installation des programmes" --msgbox "Installation des programmes nécessaire" 8 78
        if ! { sudo apt install vim -y 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::vim installation success
        else
            echo :::vim installation failure
        fi
        if ! { sudo apt install tmux -y 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::tmux installation success
        else
            echo :::tmux installation failure
        fi
        if ! { sudo apt install curl wget -y 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::curl and wget installation success
        else
            echo :::curl and wget installation failure
        fi
        if ! { sudo apt install wireless-tools wpasupplicant -y 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::wireless-tools wpasupplicant installation success
        else
            echo :::wireless-tools wpasupplicant installation failure
        fi
        if ! { sudo apt install arduino -y 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::arduino installation success
        else
            echo :::arduino installation failure
        fi
        if ! { sudo timedatectl set-timezone Europe/Brussels 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
            echo :::set-timezone Europe/Brussels success
        else
            echo :::set-timezone Europe/Brussels failure
        fi
}

function_mail () {
        wget https://raw.githubusercontent.com/balazzss/elec_raspi/main/mail_auto.py
        whiptail --title "Mail automatiques" --msgbox "Le fichier python pour la configuration des mails au démarrage est téléchargé (mail_auto.py)" 8 78
}

wpa_supplicant () {
        WIFISSID=$(whiptail --inputbox "SSID" 8 78  --title "Entrer le SSID" 3>&1 1>&2 2>&3)
        WIFIPASSWD=$(whiptail --inputbox "WIFISSID" 8 78  --title "Entrer le mot de passe" 3>&1 1>&2 2>&3)
        sudo chown $USER:$USER /etc/wpa_supplicant/wpa_supplicant.conf
        sudo wpa_passphrase "$WIFISSID" "$WIFIPASSWD" >> /etc/wpa_supplicant/wpa_supplicant.conf
}

function_SSH () {
        SSHPORT=$(whiptail --inputbox "Change SSH port" 8 78  --title "Entrer le numéro du port que vous souhaitez utiliser pour vous connecter en SSH." 3>&1 1>&2 2>&3)
        echo $SSHPORT
        sudo sed -i "s/#Port 22/Port "$SSHPORT"/g" /etc/ssh/sshd_config
        whiptail --title "Création d'une paire clé SSH" --msgbox "Création d'une paire de clé pour SSH. Veuillez cliquer sur entrer jusqu'à la fin de la création." 8 78
        ssh-keygen -t rsa -b 4096
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        cp ~/.ssh/id_rsa ~ && mv id_rsa cle_prive_a_mettre_dans_putty
        #Activation des clés pour SSH
        sudo sed -i 's/#PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
        sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
        #préciser que les clés sont dans le dossier ~/.ssh et qu'il faut tester manuellement la configuration de la clé avant de désactiver le mot de passe.
 
}


end () {
whiptail --title "Configuration terminé" --msgbox "La configuration du raspberry est terminée :-)." 8 78
}
main () {
        network || error "User exited."
        update_upgrade || error "User exited."
        programms_install || error "User exited."
        function_mail || error "User exited."
        wpa_supplicant || error "User exited."
        function_SSH || error "User exited."
        end
        #clear
}
main
