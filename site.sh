#!/bin/bash


while getopts 'u:p:s:' option
do
        case "${option}" in
                u) user="$OPTARG";;
                p) password="$OPTARG";;
                s) site="$OPTARG";;
esac
done

echo "Nom d'utilisateur : "$user
echo "Mot de passe : "$password
echo "site : "$site

#chemin du site
Path="/var/www"
useradd $user --gid www-data --shell /bin/false --home-dir $Path/www/$user

#creation de la page web
mkdir $Path/$site
touch $Path/$site/index.html
echo "Votre site est bien créer"

#creation de vhost du site
touch /etc/apache2/sites-available/$site.conf
echo "<VirtualHost *:80>
ServerAdmin $site.ere71.lan
        ServerAlias www.$site.ere71.lan
        DocumentRoot $Path/$site
        #Errorlog /var/www/html/acc/err.log
</VirtualHost>" >> /etc/apache2/sites-available/$site.conf

a2ensite $site.conf


#ssh eleve@192.168.154.100 'echo www.$site cname www >> /etc/bind/db.ere71.lan'
#systemctl restart bind9


#creation database
mysql -u root -e "CREATE DATABASE $site;"
mysql -u root -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $site.*TO'$user@'192.168.154.110' IDENTIFIED BY $password;"
mysql -u root -e "FLUSH PRIVILEGES;"

systemctl reload apache2

