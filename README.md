# RaceDB-Container

## Welcome to RaceDB

RaceDB is a database system for for Cross Manager. It allows registration of riders via web browser, and allows the timing person to refer to the race data in RaceDB from Cross Manager.

## Installation

There are two method to get RaceDB working
    - The hard way using lots of command line "code" as per the original install instructions (Install-Readme.txt) from the Cross Manager website.
    - The easy way using Docker and the RaceDB-Container

If you are a seasoned RaceDB enthusist or a seasoned python programmer, feel free to run though the old install instructions. Otherwise, go install Docker ([http://www.docker.com]). Docker Desktop is available for Mac and Windows and Docker Community edition is available for Linux. Once Docker is installed, the installation procedure for all platforms is the same.

## Why Use the Docker Container?

Docker is a lightweight virtual machine environment. Unlike VMware, Docker does not virtual the entire machine, but only parts of the operating system to spin up a container. As such, it is more effiencent. Further, we have packaged all the software require to run RaceDB inside the container. This is no need to install Python, Mysql, or do any database configureion. This container takes care of that for you. By default, the we also spi up MySQL in another container for the database for best performance. This is all done for you when you start the container for the first time.

Upgrades are a matter of pulling the latest container image. Once the latest container is pulled, you just start it as usual. Any updates are taken care of for you.

## Running the Container

The RaceDB container comes preconfigured for the most used options. You are asked, however, to set the database root password and database password for security reasons. Select any random password (try randompassword.org) at least 16 characters long. However, if you use a RFID reader at registration to "burn" tags, you will want to add the IP number of your reader to the racedb.env file.

Steps:

- Select random password for root and for the racedb user
  
- Copy the dbconfig.env.tmpl file to dbconfig.env.
  
- Edit the dbconfig.env with notepad on Windows, Textedit on Mac, or your favourite editor on Linux. Set the MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD variables. Do not change anything else. Once these passwords have been setup, never change them. This file is only used the first time the container is started.
  
- If you have RFID tag reader for registration or wish to change the TimeZone used by RaceDB, open the racedb.env file, and set RFID_READER_HOST and TIMEZONE respectively. This configuration file is each time the container is started. You can stop the container, change these settings, and restart it to get the new settings.

- For this step, you require internet access. On Linux and MacOSX, from the terminal prompt run: "bash racedb.sh run" from the racedb container directory to start the container. On Windows, open a Powershell prompt, and run "racedb.ps run" from the start the container. The first time this command run, docker will download the container images from the internet and then spin up the containers, configure the database and racedb, and start racedb. The download only happens the first time. Any other time you start the container, it will start from disk.

- Make sure docker is setup to start when your computer starts or you login. The default for Docker is to start any containers. So, RaceDB will start when you login.
  
Once the container is running, point your webbrowser to [http://localhost:8000]

## Commands Available

The racedb.sh/ps command line tool supports the follow commands:

run - start the racedb container
stop - stop the racedb container
bash - run bash shell in running container
manage - run manage.py in running container (passes additional args to manage)
logs - show the racedb container log

To run the development version, pass -d as the first parameter and any command. This will start phpmyadmin on [http://localhost:8080] and allow for database administration. You will need the Mysql root password from dbconfig.env to use phpmyadmin.

## Database Support

RaceDB, by default, will support SQLite. It does also support Mysql, Postgress, and Oracle. We have installed the python drivers for Mysql and Postgress in the container. By default, we have selected Mysql, you can configure it for Postgress. The RaceDB container will configure RaceDB accordingly. We do not recommend the default SQLite database, however, if is it selected, the database file will be stored in it's own docker volumer racedb-data which is mounted on /racedb-data inside the container.

## Building the container

THe container is self contained. The build.sh will rebuild the container from scratch. This is only for advanced users. The container uses scripts from docker-entrypoint-init.d to container the database setup, configure racedb, and start it up. The 99-zdontstart.sh is used to stop the container from exiting on error. Additionally, renaming it to start will 00 will stop the startup scripts from running. This is useful for debugging an issue.

