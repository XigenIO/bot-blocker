#!/bin/bash
# ------------------------ ADD ANY EXCLUDES TO THIS ARRAY ------------------------ #
# Syntax should be as follows: ("item1" "item2" "item3")
excludes=("Semrush" "SemrushBot" "AhrefsBot" "Screaming" "oBot" "SiteAuditBot")

#Fetch list of bad User-Agent strings
userAgents=$(curl -s https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/refs/heads/master/_generator_lists/bad-user-agents.list)

#Check to see if our fetch worked, die if not
if [ ${#userAgents} = 0 ]; then
  echo 'Failed to fetch User-Agent list, exiting...'
  exit 1
fi

userAgents=$(echo "$userAgents" | grep -v '\\' | grep -v '\/')

if [ ${#excludes} != 0 ]; then
  for i in "${excludes[@]}"
do
  :
 userAgents=$(echo "$userAgents" | grep -vw $i)
done  
fi

userAgents=($userAgents)
userAgentsFormatted=()

for i in "${userAgents[@]}"
do
  :
  userAgentsFormatted+="\tSetEnvIfNoCase User-Agent \""$i\"" bad_bots\n"

done 

printf "<Directory \""\/home\"">
   $userAgentsFormatted
 <RequireAll>
     Require all granted
     Require not env bad_bots
  </RequireAll>
</Directory>
<Directory ~ \""\/var/www\/.\*\"">
   $userAgentsFormatted
 <RequireAll>
     Require all granted
     Require not env bad_bots
  </RequireAll>
</Directory>
" > /etc/bad-bots.conf

sed -i '/^$/d' /etc/bad-bots.conf

/usr/sbin/apachectl configtest >/dev/null 2>&1
if [ $? -eq 0 ]; then
  systemctl is-active --quiet apache2
  if [ $? -eq 0 ]; then
    systemctl restart apache2
  else
    systemctl restart httpd
  fi
else
  echo 'Failed'
    exit 1;
fi
