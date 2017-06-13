#!/bin/bash

# Search in last lines poststfix log why some mails hasn't been sent and return a CSV
# usage: echo "mail@example.org mail2@example.org" | mail_error_as_csv.sh NB_LOG_LINE
read emails
for email in $emails; do
 if ! tail -n$1 /var/log/mail.log | grep $email | grep status=sent &> /dev/null; then 

if tail -n$1 /var/log/mail.log | grep $email | grep "Name service error" &> /dev/null; then 
			echo "$email,Nom de domaine inexistant ou pas configuré"; 
continue
 fi; 
domain=$(echo $email | cut -d@ -f2)
	if ! dig MX $domain | grep ^$domain &> /dev/null ; then 
		if ! dig A $domain | grep ^$domain &>/dev/null ; then 
			echo "$email,Nom de domaine pas configuré"; 
continue
		fi ; 
	fi ; 

if tail -n$1 /var/log/mail.log | grep $email | grep "User Unknown\|User unknown\|Recipient unknown\|Invalid Recipient\|is not a known user\|Address rejected\|550\|mailbox unavailable\|address does not exist" &> /dev/null; then 
			echo "$email,Utilisateur inconnu"; 
continue
 fi; 

if tail -n$1 /var/log/mail.log | grep $email | grep "451\|Greylist" &> /dev/null; then 
			echo "$email,En cours d'envoi";
continue 
 fi; 
if tail -n$1 /var/log/mail.log | grep $email | grep "Recipient address rejected" &> /dev/null; then 
			echo "$email,Recipient address rejected: Access denied";  
continue
 fi; 
if tail -n$1 /var/log/mail.log | grep $email | grep "queue is full\|421" &> /dev/null; then 
			echo "$email,Plus d'espace disque"; 
continue
 fi; 

if tail -n$1 /var/log/mail.log | grep $email | grep "Connection timed out\|Connection refused\|lost connection withYou are not allowed to connect\|" &> /dev/null; then 
			echo "$email,Connexion au serveur impossible"; 
continue
 fi; 
 
if tail -n$1 /var/log/mail.log | grep $email | grep "521\|No Redirect Entry for this address\|Unable to relay" &> /dev/null; then 
			echo "$email,Redirection impossible"; 
continue
 fi; 
if tail -n$1 /var/log/mail.log | grep $email | grep "Relay access denied" &> /dev/null; then 
			echo "$email,Relay access denied"; 
continue
 fi; 
		echo "$email,?";  	 
 fi; 
done
