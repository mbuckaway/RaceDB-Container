#!/bin/bash
#set -x

COMPOSEFILE=docker-compose.yml
DOCKERCMD="docker-compose -f $COMPOSEFILE"
DBCONFIGENV=dbconfig.env

randompassword() {
    if [ -x /sbin/md5 ]; then
        # Works on MacOSX
        DBPASSWD=$(date | md5 -p | tail -1)
    elif [ -x /usr/bin/md5sum ]; then
        # Works on most Linux systems
        DBPASSWD=$(date | md5sum | awk '{print $1}')
    else
        # This is not secure, but we need a password
        DBPASSWD=40cae7ed19fec00a5e993543bc16a391
    fi
    echo $DBPASSWD
}

checkconfig() {
    if [ ! -f $COMPOSEFILE ]; then
        echo "Please run this command from the same directory as the $COMPOSEFILE"
        exit 1
    fi
    if [ ! -f $DBCONFIGENV ]; then
        echo "Configuring database setup..."
        MYSQL_ROOT_PASSWORD=$(randompassword)
        sleep 1
        MYSQL_PASSWORD=$(randompassword)
        cat > $DBCONFIGENV <<EOF
DATABASE_TYPE=mysql
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_USER=racedb
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_DATABASE=racedb
EOF
        echo "Database environment completed successfully"
    fi
}

restart() {
    stop
    sleep 2
    run
}

run() {
    if [ -f RaceDB.sqlite3 -a -z "$RACEDBDEV" ]; then
        echo "Migrating from old RaceDB sqlite3"
        COMPOSEFILE=docker-compose-migrate.yml
        DOCKERCMD="docker-compose -f $COMPOSEFILE"
    fi
    checkconfig
    echo "Starting RaceDB Container set..."
    $DOCKERCMD up -d
}

logs() {
    checkconfig
    $DOCKERCMD logs
}

flogs() {
    checkconfig
    $DOCKERCMD logs -f
}

bash() {
    checkconfig
    echo "You are now running commands inside the racedb container"
    echo
    $DOCKERCMD exec racedb /bin/bash
}

manage() {
    checkconfig
    $DOCKERCMD racedb /RaceDB/manage.py $@
}

stop() {
    echo "Stopping RaceDB Container set..."
    # dbconfig.env must exist for the stop command, and this makes sure it will run
    if [ ! -f $DBCONFIGENV ]; then
        touch $DBCONFIGENV
    fi
    $DOCKERCMD stop
}

ps() {
    $DOCKERCMD ps
}

update() {
    stop
    echo "Updating RaceDB and MySQL containers (if available)"
    $DOCKERCMD pull
}

build() {
    if [ ! -f "$COMPOSEFILE" ]; then
        echo "ERROR: Command must be run from same directory as the $COMPOSEFILE file."
        exit 1
    fi
    . .wharf
    if [ "$TAG" == "beta" ]; then
      docker build -t $IMAGE:$TAG -f Dockerfile.beta .
    else
      docker build -t $IMAGE:$TAG .
    fi
}

rebuild() {
    if [ ! -f "$COMPOSEFILE" ]; then
        echo "ERROR: Command must be run from same directory as the $COMPOSEFILE file."
        exit 1
    fi
    . .wharf

    if [ "$TAG" == "beta" ]; then
      docker build -t $IMAGE:$TAG -f Dockerfile.beta --no-cache .
    else
      docker build -t $IMAGE:$TAG --no-cache .
    fi
}

cleanall() {
    if [ ! -f "$COMPOSEFILE" ]; then
        echo "ERROR: Command must be run from same directory as the $COMPOSEFILE file."
        exit 1
    fi
    echo -n "About to wipe all the RaceDB data and configuration!! Are you sure? THIS CANNOT BE UNDONE! (type YES): "
    read ENTRY
    if [ "$ENTRY" = "YES" ]; then
        stop
        
        RACEDBCONTAINERS=$(docker container list -a | grep racedb_app | awk '{ print $1 }')
        for container in $RACEDBCONTAINERS
        do
            echo "Removing container: $container"
            docker container rm -f $container
        done

        RACEDBIMAGES=$(docker image list | grep racedb-mysql | awk '{print $3}')
        for image in $RACEDBIMAGES
        do
            echo "Removing image: $image"
            docker image rm -f $image
        done

        VOLUMES=$(docker volume list | grep racedb-container | awk '{print $2}')
        for volume in $VOLUMES
        do
            echo "Removing RaceDB volume: $volume"
            docker volume rm $volume
        done

        if [ -f RaceDB.sqlite3 ]; then
            echo "Removed old RaceDB.sqlite3"
            rm -f RaceDB.sqlite3
        fi
        if [ -f dbconfig.env ]; then
            echo "Removed old dbconfig.env file"
            rm -f dbconfig.env
        fi
    else
        echo "Clean cancelled"
    fi
}

usage() {
    echo "Commands:"
    echo "run - start the racedb container"
    echo "stop - stop the racedb container"
    echo "restart - stop and restart the racedb container"
    echo "bash - run bash shell in running container"
    echo "ps   - list running containers"
    echo "manage - run manage.py in running container (passes additional args to manage)"
    echo "logs - show the racedb container log"
    echo "flogs - show the racedb container log and display continuously"
    echo
    echo "Use a webbrowser to login to RaceDB: http://localhost:8000"
    echo 
    echo "To run the development version, pass -d as the first parameter and thenany command."
    echo "This will start phpmyadmin on http://localhost:8080"
}
CMD=$1
if [ "$1" == "-d" -o -n "$RACEDBDEV" ]; then
    echo "WARNING: Using development container..."
    COMPOSEFILE=docker-compose-dev.yml
    DOCKERCMD="docker-compose -f $COMPOSEFILE"
    RACEDBDEV=1
    if [ "$1" = '-d' ]; then
        CMD=$2
    fi
    shift    
fi
shift
case $CMD in
    "dbconfig") checkconfig
        ;;
    "run" | "start") run
        ;;
    "restart") restart
        ;;
    "bash") bash
        ;;
    "update") update
        ;;
    "logs" | "log") logs
        ;;
    "flogs" | "flog") logs
        ;;
    "stop") stop
        ;;
    "ps") ps
        ;;
    "manage") manage $@
        ;;
    "clean") cleanall
        ;;
    "build") build
        ;;
    "rebuild") build
        ;;
    *) echo "Unknown command."
       usage
       ;;
esac


        
