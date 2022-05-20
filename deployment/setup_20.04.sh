#!/usr/bin/env bash

# Description: Chatwoot installation script
# OS: Ubuntu 20.04 LTS / Ubuntu 20.10
# Script Version: 1.0
# Run this script as root

function get_domain_info() {
  read -rp 'Enter your sub-domain to be used for Chatwoot (chatwoot.domain.com for example) : ' domain_name
  read -rp 'Enter the email LetsEncrypt can use to send reminders when your SSL certificate is up for renewal: ' le_email
  cat << EOF

This script will try to generate SSL certificates via LetsEncrypt and serve chatwoot at
https://$domain_name. Proceed further once you have pointed your DNS to the IP of the instance.

EOF
  read -rp 'Do you wish to proceed? (yes or no): ' exit_true
  if [ "$exit_true" == "no" ]
  then
    exit 1
  fi
}

function install_dependencies() {
  apt update && apt upgrade -y
  apt install -y curl
  curl -sL https://deb.nodesource.com/setup_12.x | bash -
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
  apt update

  apt install -y \
      git software-properties-common imagemagick libpq-dev \
      libxml2-dev libxslt1-dev file g++ gcc autoconf build-essential \
      libssl-dev libyaml-dev libreadline-dev gnupg2 \
      postgresql-client redis-tools \
      nodejs yarn patch ruby-dev zlib1g-dev liblzma-dev \
      libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev sudo

  echo "debug: installing dependencies"
  sleep 1
}

function install_databases() {
  apt install -y postgresql postgresql-contrib redis-server

  echo "debug: installing postgres"
  sleep 1
  echo "debug: installing redis"
}

function install_webserver() {
  apt install -y nginx nginx-full certbot python3-certbot-nginx
  echo "debug: installing nginx"
}

function configure_rvm() {
  adduser --disabled-login --gecos "" chatwoot

  gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
  adduser chatwoot rvm

  echo "debug: installing rvm"
  echo "debug: creating chatwoot user"
}

function configure_db() {
  pg_pass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 15 ; echo '')
  sudo -i -u postgres psql << EOF
  \set pass `echo $pg_pass`
  CREATE USER chatwoot CREATEDB;
  ALTER USER chatwoot PASSWORD :'pass';
  ALTER ROLE chatwoot SUPERUSER;
  UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';
  DROP DATABASE template1;
  CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';
  UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';
  \c template1
  VACUUM FREEZE;
  EOF

  systemctl enable redis-server.service
  systemctl enable postgresql

  echo "debug: setting up postgres"
  sleep 1
}

function setup_chatwoot() {
  secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 63 ; echo '')
  RAILS_ENV=production

  sudo -i -u chatwoot << EOF
  rvm --version
  rvm autolibs disable
  rvm install "ruby-3.0.2"
  rvm use 3.0.2 --default

  git clone https://github.com/chatwoot/chatwoot.git
  cd chatwoot
  if [[ -z "$1" ]]; then
  git checkout master;
  else
  git checkout $1;
  fi
  bundle
  yarn

  cp .env.example .env
  sed -i -e "/SECRET_KEY_BASE/ s/=.*/=$secret/" .env
  sed -i -e '/REDIS_URL/ s/=.*/=redis:\/\/localhost:6379/' .env
  sed -i -e '/POSTGRES_HOST/ s/=.*/=localhost/' .env
  sed -i -e '/POSTGRES_USERNAME/ s/=.*/=chatwoot/' .env
  sed -i -e "/POSTGRES_PASSWORD/ s/=.*/=$pg_pass/" .env
  sed -i -e '/RAILS_ENV/ s/=.*/=$RAILS_ENV/' .env
  echo -en "\nINSTALLATION_ENV=linux_script" >> ".env"

  rake assets:precompile RAILS_ENV=production
EOF

  echo "debug: cloning chatwoot repo"
  echo "debug: installing chatwoot..."
  echo "debug: compiling assets"
  sleep 5
}


function run_db_migrations(){
  sudo -i -u chatwoot << EOF
  cd chatwoot
  RAILS_ENV=production bundle exec rake db:create
  RAILS_ENV=production bundle exec rake db:reset
EOF

  echo "debug: running migrations"
}


function configure_systemd_services() {
  cp /home/chatwoot/chatwoot/deployment/chatwoot-web.1.service /etc/systemd/system/chatwoot-web.1.service
  cp /home/chatwoot/chatwoot/deployment/chatwoot-worker.1.service /etc/systemd/system/chatwoot-worker.1.service
  cp /home/chatwoot/chatwoot/deployment/chatwoot.target /etc/systemd/system/chatwoot.target

  systemctl enable chatwoot.target
  systemctl start chatwoot.target
  echo "debug: setting up systemd services"
}


function setup_ssl() {
  curl https://ssl-config.mozilla.org/ffdhe4096.txt >> /etc/ssl/dhparam
  wget https://raw.githubusercontent.com/chatwoot/chatwoot/develop/deployment/nginx_chatwoot.conf
  cp nginx_chatwoot.conf /etc/nginx/sites-available/nginx_chatwoot.conf
  certbot certonly --non-interactive --agree-tos --nginx -m $le_email -d $domain_name
  sed -i "s/chatwoot.domain.com/$domain_name/g" /etc/nginx/sites-available/nginx_chatwoot.conf
  ln -s /etc/nginx/sites-available/nginx_chatwoot.conf /etc/nginx/sites-enabled/nginx_chatwoot.conf
  systemctl restart nginx
  sudo -i -u chatwoot << EOF
  cd chatwoot
  sed -i "s/http:\/\/0.0.0.0:3000/https:\/\/$domain_name/g" .env
EOF
  systemctl restart chatwoot.target
  echo "debug: setting up ssl"
  echo "$domain_name"
  echo "$le_email"
}


function main() {

  cat << EOF

***************************************************************************
              Chatwoot Installation (latest)
***************************************************************************

EOF

  read -rp 'Would you like to configure a domain and SSL for Chatwoot?(yes or no): ' configure_webserver

  if [ "$configure_webserver" == "yes" ]
  then
    get_domain_info
  fi

  read -rp 'Would you like to install postgres and redis?(Answer no if you plan to use external services): ' install_pg_redis

  if [ "$install_pg_redis" == "no" ]
  then
    echo "***** Skipping pg and redis installation. ****"
  fi

  install_dependencies

  if [ "$install_pg_redis" != "no" ]
  then
    install_databases
  fi

  if [ "$configure_webserver" == "yes" ]
  then
    install_webserver
  fi

  configure_rvm

  if [ "$install_pg_redis" != "no" ]
  then
    configure_db
  fi

  setup_chatwoot

  if [ "$install_pg_redis" != "no" ]
  then
    run_db_migrations
  fi

  configure_systemd_services

  public_ip=$(curl http://checkip.amazonaws.com -s)
  
  if [ "$configure_webserver" != "yes" ]
  then
    cat << EOF

***************************************************************************
Woot! Woot!! Chatwoot server installation is complete
The server will be accessible at http://$public_ip:3000

To configure a domain and SSL certificate, follow the guide at 
https://www.chatwoot.com/docs/deployment/deploy-chatwoot-in-linux-vm

Join us at https://chatwoot.com/community
***************************************************************************
EOF
  else
    setup_ssl
    cat << EOF

***************************************************************************
Woot! Woot!! Chatwoot server installation is complete
The server will be accessible at https://$domain_name

Join us at https://chatwoot.com/community
***************************************************************************
EOF
  fi

  if [ "$install_pg_redis" == "no" ]
  then
cat <<EOF
***************************************************************************
DB migrations are not run as pg and redis is not installed.
After modifying .env with your external db creds, run db migrations !!!
***************************************************************************
EOF
  fi

}

main "$@"
