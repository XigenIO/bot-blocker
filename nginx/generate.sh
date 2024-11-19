#!/bin/bash
# ------------------------ ADD ANY EXCLUDES TO THIS ARRAY ------------------------ #
# Syntax should be as follows: ("item1" "item2" "item3")
excludes=("Semrush" "SemrushBot" "AhrefsBot" "Screaming")

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
 userAgents=$(echo "$userAgents" | grep -v $i)
done  
fi

userAgents=($userAgents)

for i in "${userAgents[@]}"
do
  :
  echo "if (\$http_user_agent ~ ('$i')) {
       return 403;
}"

done  > /etc/nginx/bad-bots-tmp.conf

sed "s/'//g" /etc/nginx/bad-bots-tmp.conf > /etc/nginx/bad-bots.conf

rm /etc/nginx/bad-bots-tmp.conf

nginx -t >/dev/null 2>&1
if [ $? -eq 0 ]; then
    systemctl restart nginx
else
  echo 'Failed'
    exit 1;
fi