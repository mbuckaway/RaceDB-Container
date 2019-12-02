# RaceDB-Container

## Welcome to RaceDB

RaceDB is a database system for for Cross Manager. It allows registration of riders via web browser, and allows the timing person to refer to the race data in RaceDB from Cross Manager.

## Installation

There are two method to get RaceDB working
    - The hard way using lots of command line "code" as per the original install instructions (Install-Readme.txt) from the Cross Manager website.
    - The easy way using Docker and the RaceDB-Container

If you are a seasoned RaceDB enthusist or a seasoned python programmer, feel free to run though the old install instructions. Otherwise, go download and install Docker ([http://www.docker.com]). Docker Desktop is available for Mac and Windows and Docker Community edition is available for Linux. Once Docker is installed, the installation procedure for all platforms is the same.

## Why Use the Docker Container?

Docker is a lightweight virtual machine environment. Unlike VMware, Docker does not virtual the entire machine, but only parts of the operating system needed to spin up a container. As such, it is more effiencent. Further, we have packaged all the software require to run RaceDB inside the container. This is no need to install Python, Mysql, or do any database configuraion or to update Python, Mysql, etc. as you might normally do. This container takes care of that for you. By default, the we also spin up MySQL in another container without any work required from you. We use Mysql for the database for best performance. This is all done for you when you start the container for the first time.

Upgrades are a matter of pulling the latest container image. This is a one command affair. Once the latest container is pulled, you just start it as usual. Any updates are taken care of for you. See Updating below.

## Running the Container

The RaceDB container comes preconfigured for the most used options. However, if you use a RFID reader at registration to "burn" tags, you will want to add the IP number of your reader to the racedb.env file (see below).

Steps:

- Unzip/untar the release file into a directory (ie. $HOME/RaceDB (Mac/Linux) or C:\RaceDB (Windows))

- If you have RFID tag reader for registration or wish to change the TimeZone used by RaceDB, open the racedb.env file with a text editor, and set RFID_READER_HOST and TIMEZONE respectively. This configuration file is each time the container is started. You can stop the container, change these settings, and restart it to get the new settings if so required.

- For this step, you require internet access. On Linux and MacOSX, from the terminal prompt run: "bash racedb.sh run" from the racedb container directory to start the container. On Windows, open a Powershell prompt, and run "racedb.ps run" from the start the container. The first time this command run, docker will download the container images from the internet and then spin up the containers, configure the database and racedb, and start racedb. The download only happens the first time. Any other time you start the container, it will start from disk.

- Make sure docker is setup to start when your computer starts or you login. The default for Docker is to start any containers. So, RaceDB will start when you login.
  
Once the container is running, point your webbrowser to [http://localhost:8000]. From another computer on the network, use the IP number of your name. For example, [http://192.168.30.23].

We recommend configuring Docker to start with your system. If you do so, RaceDB will automatically start with Docker starts. Additionally, you can use the Docker control panel to control RaceDB.

## Commands Available

The racedb.sh/ps command line tool supports the follow commands:

run - start the racedb container
stop - stop the racedb container
restart - stop and restart the container
bash - run bash shell in running container
manage - run manage.py in running container (passes additional args to manage)
logs - show the racedb container log
update - update the RaceDB and MySQL containers from the current versions

To run the development version, pass -d as the first parameter and any command. This will start phpmyadmin on [http://localhost:8080] and allow for database administration. You will need the Mysql root password from dbconfig.env to use phpmyadmin.

## Updating RaceDB

From time to time, RaceDB will be updated to a newer version. Generally speaking, unless there is a new feature you need or a bug fixed, we recommended upgrading no more than 1-2/times per year. To update the container, making sure you have an internet connection, and run the following command:

```bash
./racedb.sh update (linux/mac)
```

```bash
./racedb.ps update (windows)
```

Once the command has complete, start the container as normal.

## Database Support

We have selected MySQL as the database backend for RaceDB. While Sqlite, Postgress and Oracle are also supported, we have not tested these configrations.

The Mysql configuration is stored in the dbconfig.env file that is created when the container is first started. The passwords in this file may be required to administrate the database.

## Upgrading from a Non-Container RaceDB

By default, the old installation of RaceDB will configure itself to use the Sqlite database driver and it will create a file RaceDB.sqlite3 in the RaceDB directory. If you were using the older non-containerized RaceDB, to migrate your old data into the containerized version, simple copy your RaceDB.sqlite3 file into the same directory as the docker-compose.yml file. When the container is started with "./racedb.sh run", it will detect the existance of the file, and mount it inside the container. The startup scripts in the container will detect this file, and import the data into the MySQL database. Please keep this in mind, this is a destructive import and any existing data will be removed. This import will only happen once. We recommend removing the RaceDB.sqlite3 file from the directory after the import has been completed.

## Using the Development Version

The developer version of the container set can be enabled with the -d option to racedb.sh. This is only supported on Linux and MacOSX. This changes the docker compose file to the dev version which mounts the docker-entrypoint-init.d and RaceDB directories outside the container. It will further install the phpmyadmin container to enable database administraton. This is intended for development only and the fill source tree from git will be required.

## Building the container

THe container is self contained. Building the container requires either MacOSX or Linux. We do not support building the container on Windows. Run "./racedb.sh build" to build the container. This will replace the container pulled from the Docker repo. This is only for users that understand howt use docker. The container uses scripts from docker-entrypoint-init.d to container the database setup, migrate data from an old RaceDB, configure racedb, and start it up. The 99-zdontstart.sh is used to stop the container from exiting on error. Additionally, renaming it to start will 00 will stop the startup scripts from running. This is useful for debugging an issue.


