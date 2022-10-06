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
&& apt-get install -y git \
&& apt-get install lsb-release ca-certificates apt-transport-https software-properties-common -y \
&& add-apt-repository ppa:ondrej/php && add-apt-repository ppa:ondrej/apache2 && apt-get update

# APACHE2 + PHP AND ALL PACKAGES NEEDED
RUN apt-get install -y apache2 \
&& apt-get install -y php8.0 php8.0 php8.0-fpm php8.0-imap php8.0-apcu php8.0-intl php8.0-cgi php8.0-common php8.0-zip php8.0-mbstring php8.0-gd php8.0-mysql php8.0-bcmath php8.0-xml \
&& apt-get install -y libapache2-mod-php8.0

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
RUN ln -s /usr/bin/local/etc/php/php-apache2.ini /etc/php/8.0/apache2/conf.d/99-osticket.ini \
&& chown -R www-data:www-data /var/www/ \
&& chown www-data:www-data /var/www/ && chmod g+rx /var/www/ \
&& chmod -R 777 /usr/bin/ \
&& chmod -R 777 /attachments

VOLUME ["/attachments"]
EXPOSE 80
CMD ["/usr/bin/start.sh"]