# ecs-ec2-config-files
* some config files i use when setting up ec2 instances in an aws ecs cluster
* We are using AWS linux
* it may still work in AWS linux 2 and centos6/7, and redhat6/7 but not actually tested on those


### docker: daemon config options
* backup existing file (cp -a /etc/sysconfig/docker /etc/sysconfig/dockeri.original)
* replace it with this file at location /etc/sysconfig/docker
* restart docker (service docker restart)


### awslogs.conf: configuration of log files to ship to cloudwatch
* install awslogs package (yum install -y awslogs)
* backup existing file (cp -a /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.original)
* place it /etc/awslogs/awslogs.conf 
* set awslogs to start on boot and restart it 
** chkconfig awslogs on
** service awslogs restart


### ecsMonitor.sh: a script to send cpu and memory statistics for each container to cloudwatch. I was using this until the customer started using datadog so i am not currently updating or maintaining this script. It used to work pretty good tho.We have to set the region in the aws cli config but outside of that the authentication is handled via an IAM role assigned at provisioning with cloudwatch write permissions
          yum install -y jq bc aws-cli perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https python27-pip
          mkdir -p /etc/ecsMonitor
          mkdir -p /root/.aws
          touch /root/.aws/config
          grep -q -F 'default'  /root/.aws/config || echo '[default]' >> /root/.aws/config
          grep -q -F 'region'  /root/.aws/config || echo 'region = us-west-2' >> /root/.aws/config
          ### wget -O  /etc/ecsMonitor  URL_to_script
          chmod 744 /etc/ecsMonitor/ecsMonitor.sh
          touch /var/spool/cron/root
          grep -q -F 'ecsMonitor'  /var/spool/cron/root || echo '* * * * * /etc/ecsMonitor/ecsMonitor.sh' >> /var/spool/cron/root


### awscli.conf: TBH I dont remember why i did this or if its actually needed... The context is
          cp -a /etc/awslogs/awscli.conf /etc/awslogs/awscli.conf.original
          copy file to /etc/awslogs/awscli.conf
