# MariaDB (https://mariadb.org/)

FROM ubuntu:precise
MAINTAINER Ryan Seto <ryanseto@yak.net>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
        apt-get update && \
        apt-get upgrade

# Ensure UTF-8
RUN apt-get update
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive

RUN echo "mariadb-server-mariadb mysql-server/root_password password docker" | debconf-set-selections
RUN echo "mariadb-server mysql-server/root_password_again password docker" | debconf-set-selections

# Install MariaDB from repository.
RUN apt-get -y install python-software-properties && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu precise main' && \
    apt-get update && \
    apt-get install -y mariadb-server

# Decouple our data from our container.
VOLUME ["/data"]

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/mysql/my.cnf

# Configure MariaDB to listen on any address.
RUN sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf

RUN service mysql start && \
    mysql -v -uroot -pdocker -e'UPDATE user SET host = "%" WHERE user = "root" LIMIT 1; DELETE FROM user WHERE user = "root" AND host != "%"' && \
    service mysql stop

EXPOSE 3306
ADD start.sh /start.sh

RUN chmod +x /start.sh
