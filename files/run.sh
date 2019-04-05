#!/bin/zsh

cd /app

rm app/package.json
ln -s /mounted/package.json /app/package.json

cp /mounted/webpack.mix.js /app/webpack.mix.js

ln -s /mounted/.env /app/.env
ln -s /mounted/app /app/app
ln -s /mounted/artisan /app/artisan
ln -s /mounted/bootstrap /app/bootstrap
ln -s /mounted/composer.json /app/composer.json
ln -s /mounted/composer.lock /app/composer.lock
ln -s /mounted/config /app/config
ln -s /mounted/database /app/database
ln -s /mounted/other /app/other
ln -s /mounted/phpunit.xml /app/phpunit.xml
ln -s /mounted/public /app/public
ln -s /mounted/readme.md /app/readme.md
ln -s /mounted/routes /app/routes
ln -s /mounted/server.php /app/server.php
ln -s /mounted/storage /app/storage
ln -s /mounted/tests /app/tests
ln -s /mounted/vendor /app/vendor

chmod -R 777 /app/storage/logs/
chmod -R 777 /app/storage/framework/views

/app/rebuild_nodejs.sh

# Start SSH
service ssh start

# Start MySQL
service mysql start

# Regrant access to debian user
mysql -s -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY 'X0dRgHfyx3OyAL5h';"

# Create database and user if not exists
if ! mysql -s -u root -e 'use laravel' 2>/dev/null; then
	mysql -u root -e "create database laravel; grant usage on *.* to laravel@localhost identified by 'laravel'; grant all privileges on laravel.* to laravel@localhost;";
fi

# Start Redis
service redis-server start

# Start Supervisord
service supervisor start
chmod 755 /var/log/supervisor

# Start Apache
service apache2 start
chmod -R 755 /var/log/apache2

# Start Maildev
maildev > /dev/null 2>&1 &

npm update

# Gime gime gime a shell after midnight
zsh