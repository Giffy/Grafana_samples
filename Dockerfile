FROM registry.access.redhat.com/ubi8/ubi:8.1

RUN yum --disableplugin=subscription-manager -y module enable php:7.3 \
  && yum --disableplugin=subscription-manager -y install httpd php \
  && yum --disableplugin=subscription-manager clean all

ADD index.php /var/www/html

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
  && sed -i 's/listen.acl_users = apache,nginx/listen.acl_users =/' /etc/php-fpm.d/www.conf \
  && mkdir /run/php-fpm \
  && chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm \
  && chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm

EXPOSE 8080

RUN useradd -rm -d /home/giffy -s /bin/bash -g giffy -G sudo -u 1000 giffy
RUN echo 'giffy:m1p4ss00' | chpasswd

RUN yum update
RUN yum upgrade -y
RUN yum install openssh-server vim-nox  dnsutils whois mtr-tiny wget  -y

USER 1001
ENTRYPOINT service ssh restart && bash
CMD php-fpm & httpd -D FOREGROUND