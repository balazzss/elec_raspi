#! /usr/bin/env python
# coding: utf-8 -*-

import socket
import fcntl
import struct
import smtplib,os,sys
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

from_adrs = "ADRESSE@gmail.com"
to_ards = "ADRESSE@gmail.com"
login_mail = "ADRESSE@gmail.com"

def mon_ip(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,
        struct.pack('256s', ifname[:15])
    )[20:24])

osts = ""
try:
    sts1 = "Connecté en Wifi: interface wlan: " + mon_ip('wlan0')
#   print sts
except:
    sts1 = "Aucune connexion sur l'interface wlan0 (Wifi)"
#   print sts 

osts = sts1 + "\n"

try:
    sts2 = "Connecté en Ethrnet: interface eth0: " + mon_ip('eth0')
#   print sts2
except:
    sts2 = "Aucune connexion sur l'interface eth0 (Ehternet)"
#   print sts2


osts = osts + sts2

msg = MIMEMultipart()
msg['From'] =from_adrs
msg['To'] = to_ards
msg['Subject'] = 'adresse IP du RaspberryPi'
msg.attach(MIMEText(osts))


mailserver = smtplib.SMTP('smtp.gmail.com', 587)
mailserver.ehlo()
mailserver.starttls()
mailserver.ehlo()
mailserver.login(from_adrs, "password")
mailserver.sendmail(from_adrs, to_ards, msg.as_string())
mailserver.quit()
