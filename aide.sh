#!/bin/bash
/usr/sbin/aide --check | /bin/mail -s "$HOSTNAME - Daily AIDE integrity check" brian.cotton@technologyspa.com
/usr/sbin/aide --update 
rm -f /var/lib/aide/aide.db.gz
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

