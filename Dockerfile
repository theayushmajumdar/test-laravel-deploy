FROM php:8.2-fpm
    
    # Install system dependencies
    RUN apt-get update && apt-get install -y \
        git \
        curl \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        zip \
        unzip \
        nginx
    
    # Clear cache
    RUN apt-get clean && rm -rf /var/lib/apt/lists/*
    
    # Install PHP extensions
    RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
    
    # Get Composer
    COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
    
    # Set working directory
    WORKDIR /var/www
    
    # Copy existing application directory
    COPY . .
    
    # Install dependencies
    RUN composer install
    
    # Copy nginx configuration
    RUN rm /etc/nginx/sites-enabled/default
    COPY docker/nginx.conf /etc/nginx/conf.d/
    
    # Set permissions
    RUN chown -R www-data:www-data /var/www
    
    EXPOSE 80
    
    # Start Nginx & PHP-FPM
    CMD sh -c "service nginx start && php-fpm"