#!/bin/bash
if [ ! -f /vagrant/archives/logstash_1.5.6-1_all.deb ]; then
  curl -o /vagrant/archives/logstash_1.5.6-1_all.deb https://download.elastic.co/logstash/logstash/packages/debian/logstash_1.5.6-1_all.deb
fi

cd /vagrant/archives/
apt-get update
apt-get install default-jdk -y
dpkg -i logstash_1.5.6-1_all.deb