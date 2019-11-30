#!/bin/bash

COMPOSEFILE=docker-compose.yml
DOCKERCMD="docker-compose -f $COMPOSEFILE"

checkconfig() {
    if [ ! -f dbconfig.env ]; then
        echo "Please copy the dbconfig.env.tmpl to dbconfig.env and edit the file"
        echo "and set the Database MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD variables"
        echo "to strong passwords. You may need them in the future."
        exit 1
    fi
}

run() {
    checkconfig
    echo "Starting RaceDB Container set..."
    $DOCKERCMD up -d
}

logs() {
    checkconfig
    $DOCKERCMD logs
}

bash() {
    checkconfig
    $DOCKERCMD racedb /bin/bash
}

manage() {
    checkconfig
    $DOCKERCMD racedb /RaceDB/manage.py $@
}

stop() {
    echo "Stopping RaceDB Container set..."
    $DOCKERCMD stop
}

ps() {
    $DOCKERCMD ps
}


usage() {
    echo "Commands:"
    echo "run - start the racedb container"
    echo "stop - stop the racedb container"
    echo "bash - run bash shell in running container"
    echo "ps   - list running containers"
    echo "manage - run manage.py in running container (passes additional args to manage)"
    echo "logs - show the racedb container log"
    echo
    echo "Use a webbrowser to login to RaceDB: http://localhost:8000"
    echo 
    echo "To run the development version, pass -d as the first parameter and any command."
    echo "This will start phpmyadmin on http://localhost:8080"
}
CMD=$1
if [ "$1" == "-d" ]; then
    COMPOSEFILE=docker-compose-dev.yml
    DOCKERCMD="docker-compose -f $COMPOSEFILE"
    CMD=$2
    shift    
fi
shift
case $CMD in
    "run") run
        ;;
    "bash") bash
        ;;
    "logs") logs
        ;;
    "stop") stop
        ;;
    "ps") ps
        ;;
    "manage") manage $@
        ;;
    *) echo "Unknown command."
       usage
       ;;
esac


        
