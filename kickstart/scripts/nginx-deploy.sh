#!/bin/bash

dst=/opt/posm-www

deploy_nginx_ubuntu() {
  apt-get install --no-install-recommends -y nginx
  expand etc/nginx-posm.conf /etc/nginx/sites-available/posm
  rm -f /etc/nginx/sites-enabled/default
  ln -s -f ../sites-available/posm /etc/nginx/sites-enabled/00posm
  service nginx restart

  mkdir -p /opt/posm-www
  chmod 755 /opt/posm-www

  from_github "https://github.com/AmericanRedCross/posm-local-home" "$dst"
}

deploy nginx
