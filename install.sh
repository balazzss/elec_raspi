#!/bin/bash
#ajout d'une interface graphique
whiptail --title "Bienvenue" --msgbox "Bienvenue dans l'installation des outils pour votre machine, cliquez sur OK pour continuier" 8 78

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
whiptail --title "Mise à jour des paquets" --msgbox "Mises à jour des paquets." 8 78
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
        sudo apt install vim -y
        sudo apt install tmux -y
        sudo apt install curl wget -y
        sudo timedatectl set-timezone Europe/Brussels
}

function_mail () {
        wget https://raw.githubusercontent.com/balazzss/elec_raspi/main/mail_auto.py
}

function_changeSSHport () {
SSHPORT=$(whiptail --inputbox "Change SSH port" 8 78  --title "Entrer le numéro du port que vous souhaitez utiliser pour vous connecter en SSH." 3>&1 1>&2 2>&3)
echo $SSHPORT
sudo sed -i "s/#Port 22/Port "$SSHPORT"/g" /etc/ssh/sshd_config

if (whiptail --title "Public Key" --yesno "Voulez-vous utiliser une clé publique pour vous authentifier avec SSH?" 8 78); then
        sudo sed -i 's/#PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
else
        sudo sed -i 's/#PubkeyAuthentication no/PubkeyAuthentication no/g' /etc/ssh/sshd_config
fi
        
}


end () {
whiptail --title "Configuration completed" --msgbox "La configuration de votre machine est terminé." 8 78
}
main () {
        network || error "User exited."
        update_upgrade || error "User exited."
        programms_install || error "User exited."
        function_changeSSHport || error "User exited."

        end
        clear
}
main
