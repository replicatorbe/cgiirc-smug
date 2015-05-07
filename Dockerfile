FROM debian:jessie
MAINTAINER Jérôme Fafchamps, smug@fafchamps.be

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y perl build-essential apache2 wget zip gcc
RUN wget http://cgiirc.org/releases/cgiirc-0.5.11.tar.gz
RUN tar zxvf cgiirc-0.5.11.tar.gz
RUN (mv cgiirc-0.5.11 cgiirc && cd cgiirc)
RUN cp -R cgiirc /var/www/
RUN cd /etc/apache2/sites-available
RUN sed -ri "s/^NameVirtualHost \*:80/NameVirtualHost *:7070/" /etc/apache2/ports.conf
RUN sed -ri "s/^Listen 80/Listen 7070/" /etc/apache2/ports.conf
RUN sed -ri "s/^default_server = irc.blitzed.org/default_server = irc.freenode.org/" /var/www/cgiirc/cgiirc.config
RUN sed -ri "s/^default_channel = #cgiirc/default_channel = #wolfplex/" /var/www/cgiirc/cgiirc.config
RUN echo '<VirtualHost *:7070>\n\
	ServerAdmin webmaster@localhost\n\
	DocumentRoot /var/www/\n\
	<Directory />\n\
		Options FollowSymLinks\n\
		AllowOverride None\n\
	</Directory>\n\
	<Directory /var/www/>\n\
		Options Indexes FollowSymLinks MultiViews\n\
		AllowOverride None\n\
		Order allow,deny\n\
		allow from all\n\
	</Directory>\n\

ScriptAlias /cgiirc/ /var/www/cgiirc/\n\
        <Directory "/var/www/cgiirc/">\n\
                AllowOverride None\n\
              	Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch\n\
                Order allow,deny\n\
                Allow from all\n\
        </Directory>\n\

	ErrorLog ${APACHE_LOG_DIR}/error.log\n\
	LogLevel warn\n\

	CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/default

RUN echo 'max_users = 40\n\
webirc_password = password\n\
realhost_as_password = 1\n\
allow_non_default = 1\n\
access_server = .*\n' >> /var/www/cgiirc/cgiirc.config
EXPOSE 7070
CMD /usr/sbin/apache2ctl -D FOREGROUND
