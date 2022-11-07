# Sysadmin
Script for Sysadmin

## OldUserAndComputer.ps1

This script allows you to have the list of users with their expired passwords and computers that have not contacted the domain for X days

.EXAMPLE 
  PasswordChangeNotification.ps1 -smtpServer mail.domain.com -Days 21 -smtpfrom "IT Support <support@domain.com>" -smtpto support@domain.com -Email

## ListUserRightsFolder.ps1

Access.ps1 vous permet d'auditer vos répertoires afin d'obtenir la liste compléte des utilisateurs et leurs droits sur les répertoires.

Utilisation :

.\Get-FolderACL.ps1 -Path CheminLocal_OuReseau | ConvertTo-HTML | Out-File c:\resultat.html

La variable $ListExclusion à la ligne 9 vous permet d'exclure certains groupes du résultat ( ex: domain admins )

Script original : https://community.spiceworks.com/topic/367228-list-users-with-access-to-specific-folder?page=1

Ma version : simplement l'ajout des groupes à exclure du rapport.

## PasswordExpiryEmail.ps1

Ce script permet de donner la liste des utilisateurs dont le mot de passe expirera dans X days.

Il permet l'envoie d'un mail à chaque personne afin de les avertir.

Script original ici : https://gallery.technet.microsoft.com/scriptcenter/Password-Expiry-Email-177c3e27

Ma version : Ajout de l'envoie d'unun email avec un tableau récapitulatif de toutes les personnes dont le mot de passe va expirer. 

Options :

* -smtpServer IP du serveur
* -expireInDays Nombre de jours avant expiration du mot de passe
* -from adresse email de provenance
* -logging Permet de générer un fichier de log
* -logPath Chemin vers le répertoire qui contiendra les logs
* -testing Permet de simuler le script, tous les emails seront envoyés à testRecipient
* -testRecipient email pour le mode test

Paramètres du script :

A partir de la ligne 45

* smtpfromSysadmin email de provenance du mail
* smtptoSysadmin email pour le rapport
* messageSubjectSysadmin objet pour l'email

Exemple :
```powershell
PasswordChangeNotification.ps1 -smtpServer mail.domain.com -expireInDays 21 -from "IT Support <support@domain.com>" -Logging -LogPath "c:\logFiles" -testing -testRecipient support@domain.com 
```
