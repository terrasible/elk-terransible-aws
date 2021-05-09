#!/bin/bash

########################################
##### USE THIS WITH AMAZON LINUX 2 #####
########################################
sudo yum update -y 
sudo curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/opendistroforelasticsearch-artifacts.repo -o /etc/yum.repos.d/opendistroforelasticsearch-artifacts.repo

sudo amazon-linux-extras install java-openjdk11 -y 

sudo yum list opendistroforelasticsearch --showduplicates

sudo yum install opendistroforelasticsearch-1.13.2 -y 

sudo systemctl start elasticsearch.service

#sudo vim /etc/elasticsearch/jvm.options

sudo sed  -i -e 's/Xms1g/Xms256m/' -e's/Xmx1g/Xmx256m/'  /etc/elasticsearch/jvm.options

sudo systemctl start elasticsearch.service

sudo systemctl status elasticsearch.service

sudo /bin/systemctl daemon-reload

sudo /bin/systemctl enable elasticsearch.service

# get admin privileges
sudo su

# install httpd (Linux 2 version)
yum update -y
echo "LANG=en_US.utf-8
LC_ALL=en_US.utf-8" >> /etc/environment
