#!/bin/bash
cd /opt
sudo su
yum update -y
curl https://d3g5vo6xdbdb9a.cloudfront.net/yum/opendistroforelasticsearch-artifacts.repo -o /etc/yum.repos.d/opendistroforelasticsearch-artifacts.repo
yum install opendistroforelasticsearch-kibana -y 
sed  -i 's/kibanaserver/admin/g'  /etc/kibana/kibana.yml
echo "LANG=en_US.utf-8
LC_ALL=en_US.utf-8" >> /etc/environment
systemctl start kibana.service
systemctl daemon-reload
systemctl enable kibana.service