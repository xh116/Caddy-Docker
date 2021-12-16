FROM php:5.6-fpm-alpine 

RUN apk update && apk upgrade

RUN docker-php-ext-install pdo_mysql mysql mysqli

#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer

RUN mv composer /usr/local/bin/

EXPOSE 80 9000
