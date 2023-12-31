#!/bin/bash

domain="demo.fossbilling.org"

# Take Demo Down
docker-compose down
docker-compose rm
docker volume rm $(docker volume ls --format {{.Name}})
docker rmi -f $(docker images -aq)
# Disable cron for now 
rm /var/spool/cron/crontabs/root
# Bring Docker up
docker-compose up -d
# It takes a few seconds to be working for sure just wait 10 sec
echo "Sleep for 10 Seconds"
sleep 10

# Trigger installer
curl -X "POST" \
 -H "Content-Type: application/x-www-form-urlencoded"  \
 -d 'agreement=on&error_reporting=on&database_hostname=mysql&database_port=3306&database_name=fossbilling&database_username=fossbilling&database_password=fossbilling&admin_name=Demo&admin_email=demo@fossbilling.org&admin_password=Demo123!&currency_code=USD&currency_title=US Dollar&currency_format=${{price}}' \
"https://$domain/install/install.php?a=install"

# Delete Demo  module for checking of updates... 
if [ ! -d "https://github.com/FOSSBilling/Demo/" ]; then
rm -fr ./Demo
fi

rm -rf /var/lib/docker/volumes/docker_fossbilling/_data/install/
# Clone it again
git clone "https://github.com/FOSSBilling/Demo.git"

# Copy to Docker image 
cp -r ./Demo /var/lib/docker/volumes/docker_fossbilling/_data/modules

# Import new lines
cat ./update.sql | docker exec -i docker_mysql_1 mysql -proot fossbilling >/dev/null 2>&1

# Update Login pages
cp ./html/mod_page_login.html.twig /var/lib/docker/volumes/docker_fossbilling/_data/modules/Page/html_client/
cp ./html/mod_staff_login.html.twig /var/lib/docker/volumes/docker_fossbilling/_data/modules/Staff/html_admin/

# Run cronjob
/usr/bin/docker exec docker_fossbilling_1 su www-data -s /usr/local/bin/php /var/www/html/cron.php 



rm /root/demo.sql
# Create Dump Existing database
docker exec -i docker_mysql_1 mysqldump -uroot -proot fossbilling > /root/demo.sql

# Re state cronjobs
echo "*/5 * * * * /usr/bin/docker exec docker_fossbilling_1 su www-data -s /usr/local/bin/php /var/www/html/cron.php >/dev/null 2>&1" > /var/spool/cron/crontabs/root
echo "0 * * * * cat /root/demo.sql | /usr/bin/docker exec -i docker_mysql_1 mysql -uroot -proot fossbilling >/dev/null 2>&1" >> /var/spool/cron/crontabs/root
# Check daily hourly for release
echo "1 * * * * /root/fossbilling-demo/docker/check_release.sh" >> /var/spool/cron/crontabs/root