#!/bin/bash
grep '\[' ecs-ec2-config-files/awslogs.conf | grep -v general | sed /"\["/s/"\["/''/  |sed /"\]"/s/"\]"/''/ | while read LOG; do aws logs create-log-group --log-group-name  $LOG; done
