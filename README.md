
# bot-blocker
This project contains a script that will automatically create a web server include that contains directives to block malicious User-Agents from accessing the server.  The list of User-Agent strings comes from the mitchellkrogza/nginx-ultimate-bot-blocker generator list, located here:
https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/tree/master/_generator_lists

## Files
|File |What it does  |
|--|--|
| README.md | Documentation  |
| runner.sh| This file fetches (and then runs) the latest version of the generate.sh script.  This has been created primarily so that when the nightly cron runs, we fetch the latest list of hardcoded excludes and the latest version of the User-Agent list.  It can also be used as a one off to fetch the latest generate.sh file. |
| generate.sh| This is the script that parses the User Agent list and processes it into an include file for the web server.  This script also contains our excludes, which are User-Agent strings that appear in the mitchellkrogza list that we DON'T want to block. |

## Pre-Installation Requirements
For this script to work, you need to have both curl and the web server you are running this for (apache or nginx) installed.

## Installation (nginx)

1. Download the runner.sh script to a preferred working directory on the server, using either:

	cURL:


2. Make the script executable by running `chmod +x runner.sh`
3. Run the script with `./runner.sh`

4. Edit your nginx server block to include /etc/nginx/bad-bots.conf like the below example:

    server {
	listen 80 default_server;
	listen [::]:80 default_server;
	**include /etc/nginx/bad-bots.conf;**
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	access_log /var/log/nginx/access.log json_analytics;	
	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}
	
}
5. Restart nginx to begin blocking bots by running `systemctl restart nginx`.  Note that this will of course make the web server briefly inaccessible.
6. Add a new crontab to run the runner.sh script each night.  This will ensure that new excludes are picked up, and new user agents are added as well.  An example cron command is available below:

    0 1 * * * /root/runner.sh > /dev/null 2>&1 
## Install (Apache)
This script has not yet been created for Apache but this will hopefully be done in the future.