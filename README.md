
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
For this script to work, you need to have both curl and the web server you are running this for (apache or nginx) installed.  The below instructions presume you are running the commands as the root user.

## Installation (nginx)

1. Download the runner.sh script to a preferred working directory on the server using curl: `curl -o runner.sh "https://raw.githubusercontent.com/XigenIO/bot-blocker/refs/heads/master/nginx/runner.sh"`
2. Make the script executable by running `chmod +x runner.sh`
3. Run the script with `./runner.sh`

4. Edit your nginx server block to include /etc/nginx/bad-bots.conf like the below example:

    ```
    server {
		listen 80 default_server;
		listen [::]:80 default_server;
		include /etc/nginx/bad-bots.conf;
		root /var/www/html;
		index index.html index.htm index.nginx-debian.html;
		access_log /var/log/nginx/access.log json_analytics;	
		server_name _;
	}
	```
5. Add a new crontab to run the runner.sh script each night.  This will ensure that new excludes are picked up, and new user agents are added as well.  An example cron command is available below:

	```0 1 * * * /root/runner.sh > /dev/null 2>&1 ```

   
## Installation (cPanel Apache)
1. Download the runner.sh script to a preferred working directory on the server using curl: `curl -o runner.sh "https://raw.githubusercontent.com/XigenIO/bot-blocker/refs/heads/master/apache/cpanel/runner.sh"`
2. Make the script executable by running `chmod +x runner.sh`
3. Run the script with `./runner.sh`
4. In cPanel, navigate to Apache Configuration -> Include Editor -> Pre-Main Include -> (your version), and add the following line: ``` Include /etc/apache2/conf.d/includes/bad-bots.conf ```
5. Add a new crontab to run the runner.sh script each night.  This will ensure that new excludes are picked up, and new user agents are added as well.  An example cron command is available below:

        0 1 * * * /root/runner.sh > /dev/null 2>&1 

## Installation (Apache)

1. Download the runner.sh script to a preferred working directory on the server using curl: `curl -o runner.sh "https://raw.githubusercontent.com/XigenIO/bot-blocker/refs/heads/master/apache/manual/runner.sh"`
2. Make the script executable by running `chmod +x runner.sh`
3. Run the script with `./runner.sh`

4. Edit your Apache server block to include /etc/bad-bots.conf like the below example:

	``` 
	<VirtualHost *:80>

		ServerName www.example.com
		ServerAdmin webmaster@localhost
		DocumentRoot /var/www/html

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		Include /etc/bad-bots.conf

	</VirtualHost>
	```

5. Add a new crontab to run the runner.sh script each night.  This will ensure that new excludes are picked up, and new user agents are added as well.  An example cron command is available below:

	```0 1 * * * /root/runner.sh > /dev/null 2>&1 ```