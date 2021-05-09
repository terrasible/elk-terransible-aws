# Open Distro ElastciSearch Cluster and Kibana On AWS EC2

This repository contain the IAC code for seting up 3 Node Elasticsearch Cluster and a Kibana server using Terraform + Terragrunt And Ansible to provision on AWS EC2.

## Tools Requirements
- **Ansible**
- **Terraform** 
- **Terragrunt**

## Open Distro ElasticSearch and Kibana
Open Distro for Elasticsearch combines the OSS distributions of Elasticsearch and Kibana with a large number of open source plugins which is well maintened by AWS community. 100% open source distribution of Elasticsearch and kibana with advanced features like security, alerting, SQL support, automated index management, deep performance analysis, and many more.

## Solution Implementation 

I have used terragrunt to spun up the elasticsearch cluster and Ansible to setup the elasticsearch configrution. Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY.
The Implemented solution will setup the seprate vpc with 2 public and private subnets, internet gateway, NAT gateway configure the routing tables. Once the VPC is setup it will launch the 3 node elastic cluster and one kibana server with seprate security group. Security Group is used to hardened the ingress and egress of the traffic. After that we will use ansible playbook for the formation of elastic cluster and tls setup for node to node encryption. This Solution can be directly implemented in Production by providing the new certificates details in ```elasticsearch.yml``` file.

## Install and Setup 

To run the setup you need to install the terrafrom,terragrunt and ansible.
```
brew install terragrunt
brew install terraform
pip install ansible --user ****
```
Once all the tools is downloaded then just clone the repository and cd to the folder.

By default the code will create the s3 bucket to store the state file and dynamodb for state locking and consistency.If you want to change the default bucket name and region of the aws resources then modify ```region.hcl``` file.
```
locals {
  remote_bucket_name = "elk-poc-terraform-state"
  remote_bucket_key  = "terraform/state"
  region             = "ap-southeast-1"
  zones              = ["ap-southeast-1a", "ap-southeast-1b"]
}
```
By default the resources name is tagged with ```common_name_prefix``` variables and all the environment related config is mainted in ```env.hcl`` file.

```
locals {
  environment        = "dev"
  common_name_prefix = "elk-poc"
  ssh_machine_ip     = "******/32"
  key_name           = "elk-poc"
}
```

Before running the code Please proive the local machine IP from where you wanna ssh to the mavhine and also provide the key_name. you can create key pair using below command.

```aws ec2 create-key-pair --key-name elk-poc```

Once all the configuration is changed then we just need the access key and secret key for aws account authentication.
```
export AWS_ACCESS_KEY_ID="******************************"
export AWS_SECRET_ACCESS_KEY=***************************
```
Now Navigate to dirctory `cd terragrunt/ap-southeast-1/dev` and runt the below command. It will setup all the AWS resources which is explained above. It will take 15 min to spun all the aws resources till the you can take coffee break.

```
terragrunt run-all apply --terragrunt-non-interactive
```
## ElasticSearch Cluster Formation Setup 

Hence after the successfull execution of terragrunt you can use below command to get all the running ec2 instance details.This command will list the name, public Ip and Private Ip of the running ecw2 machine on aws. 
```
aws ec2 describe-instances \
  --filter "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], InstanceId, PrivateIpAddress, PublicIpAddress]" \
  --output table
```

We need this details to update the hosts configuration for running the ansible playbook. Bt default the code will setup 3 node cluster you can increse  the count of ec2 machine for 5 and 7 node cluster too and update the hosts confg file accordingly. Just replace the publici ip in ansible_host and private ip in ip field.

```
node-1 ansible_host=52.77.226.48      ansible_user=ec2-user ip=10.0.101.90 
node-2 ansible_host=54.254.67.122     ansible_user=ec2-user ip=10.0.102.116   
node-3 ansible_host=54.179.47.251     ansible_user=ec2-user ip=10.0.101.64   

# List all the nodes in the ES cluster
[es-cluster]
node-1
node-2
node-3

# List all the Master eligible nodes under this group
[master]
node-1
```
Then run the ansible play book with below command. It will setup the elasticsearch cluster and restart the service.
`ansible-playbook -i hosts playbook.yml`

# Kibana Setup 

For Kibana setup just need to add all the elasticsearch hosts and bind ip  `network.host=0.0.0.0` in `/etc/kibana/kibana.yml` file, Restart the server and the you can access kibana on publip ip 0n 5601 port.


## Verification 

```
curl -XGET https://<pvtip>:9200 -u 'admin:admin' --insecure
curl -XGET https://<pvtip>:9200/_cat/nodes?v -u 'admin:admin' --insecure
curl -XGET https://<pvtip>:9200/_cat/plugins?v -u 'admin:admin' --insecure
```