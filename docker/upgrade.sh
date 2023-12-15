#!/bin/bash

docker-compose down
docker-compose rm
docker volume rm $(docker volume ls --format {{.Name}})
docker rmi -f $(docker images -aq)

docker-compose up -d
echo "Sleep for a few Sec"
sleep 10
curl -X "POST" \
 -H "Content-Type: application/x-www-form-urlencoded"  \
 -d 'agreement=on&error_reporting=on&database_hostname=mysql&database_port=3306&database_name=fossbilling&database_username=fossbilling&database_password=fossbilling&admin_name=Demo&admin_email=demo@fossbilling.org&admin_password=Demo123!&currency_code=USD&currency_title=US Dollar&currency_format=${{price}}' \
"https://demo.fossbilling.org/install/install.php?a=install"

#Fix untill #1977  is merged
sed -i "s/https:\/\/localhost:8080\//https:\/\/demo.fossbilling.org/\//g" /var/lib/docker/volumes/docker_fossbilling/_data/config.php

#Install Demo  module
if [ ! -d "https://github.com/FOSSBilling/Demo/" ]; then
rm -fr ./Demo
fi

git clone "https://github.com/FOSSBilling/Demo.git"
cp -r ./Demo /var/lib/docker/volumes/docker_fossbilling/_data/modules

cat ./update.sql | docker exec -i docker_mysql_1 mysql -proot fossbilling >/dev/null 2>&1

# Update HTML pages
cp ./html/mod_page_login.html.twig /var/lib/docker/volumes/docker_fossbilling/_data/modules/Page/html_client/

cp ./html/mod_staff_login.html.twig /var/lib/docker/volumes/docker_fossbilling/_data/modules/Staff/html_admin/

# Create Dump Existing database
docker exec -i docker_mysql_1 mysqldump -uroot -proot fossbilling > ./demo.sql

rm /var/spool/cron/crontabs/root
echo "*/5 * * * * docker exec docker_fossbilling_1 php /var/www/html/cron.php >/dev/null 2>&1" > /var/spool/cron/crontabs/root
echo "0 * * * * cat /root/demo.sql | docker exec -i docker_mysql_1 mysql -uroot -proot fossbilling >/dev/null 2>&1" >> /var/spool/cron/crontabs/root