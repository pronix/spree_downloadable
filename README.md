SpreeDownloadable
=================

Introduction goes here.

For nginx config
    server {
      listen 80;
      root /home/dima/project/spree/sandbox/public;
      passenger_enabled on;
      rails_env development;
      location /downloadable/ {
        root /home/dima/project/spree/sandbox/public;
	internal;
      }
    }


Example
=======


TODO
========

* Разобраться в lib/download_app.rb там не меняется статус линка и не учитывается трафик - соответственно скачать можно много раз 
* Генерация ссылок на основе line_item


Copyright (c) 2010 [pronix.service@gmail.com], released under the New BSD License
