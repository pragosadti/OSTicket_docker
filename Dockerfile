FROM ubuntu:22.04
# ENVIROMENT FOR OSTICKET (CHANGE VERSION CHECK https://github.com/osTicket/osTicket.git TO SEE AVAIABLE VERSIONS )
ENV OSTICKET_VERSION=1.17

# ENVIROMENT TO INSTALL PHP (WITHOUT ANY INPUT FROM THE KEYBOARD)
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#INSTALL ALL DEPENDENCIES AND UTILS
RUN apt-get update && apt-get upgrade -y \
&& apt-get install apt-utils -y \
&& apt-get install cron -y \
&& apt-get install supervisor -y \
&& echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
echo "tzdata tzdata/Zones/Europe select Lisbon" >> /tmp/preseed.txt; \
debconf-set-selections /tmp/preseed.txt \
&& apt-get install -y tzdata \
&& apt-get install -y git 

# APACHE2 + PHP AND ALL PACKAGES NEEDED
RUN apt-get install -y apache2 \
&& apt-get install -y php8.1 php8.1 php8.1-fpm php8.1-imap php8.1-apcu php8.1-intl php8.1-cgi php8.1-common php8.1-zip php8.1-mbstring php8.1-gd php8.1-mysql php8.1-bcmath php8.1-xml \
&& apt-get install -y libapache2-mod-php8.1

# INSTALL OSTICKET
RUN git clone -b v${OSTICKET_VERSION} --depth 1 https://github.com/osTicket/osTicket.git \
&& cd osTicket \
&& php manage.php deploy -sv /var/www/html \
&& mv /var/www/html/setup /var/www/html/setup_hidden \
&& mkdir /attachments \
&& rm -r /var/www/html/index.html

# COPY Conf to /etc/apache2/sites-enabled/
COPY files/ /

# RELOAD FILES AND RESTART SERVICE
RUN ln -s /usr/bin/local/etc/php/php-apache2.ini /etc/php/8.1/apache2/conf.d/99-osticket.ini \
&& chown -R www-data:www-data /var/www/ \
&& chown www-data:www-data /var/www/ && chmod g+rx /var/www/ \
&& chmod -R 777 /usr/bin/ \
&& chmod -R 777 /attachments

VOLUME ["/attachments"]
EXPOSE 80
CMD ["/usr/bin/start.sh"]