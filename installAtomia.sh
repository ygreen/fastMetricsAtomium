#!/bin/bash
repo="$(wget -q -O - http://public.apt.atomia.com/setup.sh.shtml | sed s/%distcode/`lsb_release -c | awk '{ print $2 }'`/g)"; echo "$repo";
echo "$repo" | sh;
apt-get install -y atomiadns-masterserver;
apt-get install -y atomiadns-client;

apt-get install -y rng-tools;
echo "HRNGDEVICE = /dev/urandom" >> /etc/default/rng-tools

#/etc/atomiadns.conf
echo "servername = neo" >> /etc/atomiadns.conf;
echo "webapp_nameservers = localhost" >> /etc/atomiadns.conf;
echo "require_auth = 1" >> /etc/atomiadns.conf;
echo "auth_admin_user = yurigreen@gmail.com" >> /etc/atomiadns.conf;
echo "auth_admin_pass = d0ntl00k" >> /etc/atomiadns.conf;
echo "soap_uri = http://localhost/atomiadns" >> /etc/atomiadns.conf;
echo "soap_cacert = /etc/ssl/certs/server.crt" >> /etc/atomiadns.conf;
echo "soap_username = yurigreen@gmail.com" >> /etc/atomiadns.conf;
echo "soap_password = d0ntl00k" >> /etc/atomiadns.conf;
echo "rndc_path = /usr/sbin/rndc" >> /etc/atomiadns.conf;

apt-get install -y atomiadns-powerdns-database;
apt-get install -y atomiadns-powerdnssync;
apt-get install -y atomiadns-webapp;

service apache2 start;

atomiadnsclient --method AddNameserverGroup --arg default;

start atomiadns-webapp;

atomiapowerdnssync add_server default;
/etc/init.d/atomiadns-powerdnssync start;
atomiapowerdnssync full_reload_online;

echo "deb [arch=amd64] http://repo.powerdns.com/ubuntu trusty-auth-40 main" >> /etc/apt/sources.list.d/pdns.list;
echo "Package: pdns-*" >> /etc/apt/preferences.d/pdns;
echo "Pin: origin repo.powerdns.com" >> /etc/apt/preferences.d/pdns;
echo "Pin-Priority: 600" >> /etc/apt/preferences.d/pdns;
curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo apt-key add - &&
sudo apt-get update &&
sudo apt-get -y install pdns-server;

curl -i -X POST -d '[ "yurigreen@gmail.com", "d0ntl00k" ]' -H 'X-Auth-Username: yurigreen@gmail.com' -H 'X-Auth-Password: d0ntl00k' 'http://localhost/pretty/atomiadns.json/AddAccount';
curl -i -X POST -d '[ "test@fastmetrics.com", "1234" ]' -H 'X-Auth-Username: yurigreen@gmail.com' -H 'X-Auth-Password: d0ntl00k' 'http://localhost/pretty/atomiadns.json/AddAccount'
service apache2 restart;
