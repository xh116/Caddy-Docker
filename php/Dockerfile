FROM php:5.6-fpm-alpine 
RUN docker-php-ext-install pdo_mysql mysql mysqli

#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer

RUN mv composer /usr/local/bin/
COPY src/ /var/www/html/

EXPOSE 80 9000
