FROM php:8.3.0-fpm-alpine

# Configure PHP-FPM
ADD ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Create laravel user and group
RUN addgroup -g 1000 -S laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apk add --no-cache curl git unzip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql \
    && apk --no-cache add libzip-dev zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd zip

# Install Redis extension
RUN apk --no-cache add --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Set permissions
RUN chown -R laravel:laravel /var/www/html

# Create storage and bootstrap/cache directories
RUN mkdir -p /var/www/html/storage /var/www/html/storage/framework/views \
    /var/www/html/storage/framework/cache /var/www/html/storage/logs \
    /var/www/html/bootstrap/cache \
    && chown -R laravel:laravel  \
    /var/www/html/storage  \
    /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage/framework/views /var/www/html/bootstrap/cache \
    /var/www/html/storage/framework/views

# Set permissions for storage and bootstrap/cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Ensure storage and bootstrap/cache have correct permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache



# Switch to laravel user
USER laravel

# Expose port 9000 for PHP-FPM
EXPOSE 9000
