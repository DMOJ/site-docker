FROM debian:jessie
RUN apt-get update && apt-get install -y debconf-utils mysql-client libmysqlclient-dev gnupg wget git gcc g++ make python-dev libxml2-dev libxslt1-dev zlib1g-dev gettext curl wget openssl ruby ruby-dev gem 
RUN git clone https://github.com/sass/sass.git
WORKDIR /sass
RUN gem build sass.gemspec
RUN gem install sass-*.gem
WORKDIR /
RUN wget -q --no-check-certificate -O- https://bootstrap.pypa.io/get-pip.py | python
RUN wget -O- https://deb.nodesource.com/setup_4.x | bash -
RUN apt install -y nodejs
RUN npm install -g pleeease-cli

RUN git clone https://github.com/DMOJ/site.git
WORKDIR /site
RUN git submodule init
RUN git submodule update
RUN pip install -r requirements.txt
RUN pip install mysqlclient
RUN pip install django_select2
RUN npm install qu ws simplesets
RUN pip install websocket-client
WORKDIR /site/dmoj
COPY local_settings.py /site/dmoj
WORKDIR /site

RUN sh make_style.sh
RUN echo yes | python manage.py collectstatic
RUN python manage.py compilemessages
RUN python manage.py compilejsi18n

RUN mkdir /uwsgi
WORKDIR /uwsgi
COPY uwsgi.ini /uwsgi
RUN curl http://uwsgi.it/install | bash -s default $PWD/uwsgi
RUN apt install -y supervisor
COPY site.conf /etc/supervisor/conf.d/site.conf
COPY bridged.conf /etc/supervisor/conf.d/bridged.conf
COPY wsevent.conf /etc/supervisor/conf.d/wsevent.conf
COPY config.js /site/websocket
#RUN supervisord
#RUN supervisorctl update
RUN apt install -y nginx
RUN rm /etc/nginx/sites-enabled/*
ADD nginx.conf /etc/nginx/sites-enabled
RUN service nginx reload

#ENV DEBIAN_FRONTEND noninteractive
#RUN echo mysql-apt-config mysql-apt-config/enable-repo select mysql-5.7 | debconf-set-selections
#RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.3-1_all.deb
#RUN dpkg -i mysql-apt-config_0.8.3-1_all.deb
#RUN apt update
#RUN apt install -y mysql-community-server

#RUN service mysql start

#RUN mysql --execute="CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
#RUN mysql --execute="GRANT ALL PRIVILEGES ON dmoj.* to 'dmoj'@'localhost' IDENTIFIED BY '<password>';"

#RUN python manage.py migrate

COPY loaddata.sh /site

RUN service supervisor start
RUN service nginx start

WORKDIR /site

EXPOSE 80
EXPOSE 9999
EXPOSE 9998
EXPOSE 15100
EXPOSE 15101
EXPOSE 15102

