#!/bin/bash
#
# Initialize or Update the RaceDB Database
# 
# Migrate runs each time in case there is a software update
# initdata only runs once

INITDATACONFIGURED=/racedb-data/.initdata-configured

export PYTHONPATH=/RaceDB
# Make sure the sqlitedb gets started on the data volume in case something screws up
export sqlite3_database_fname=/racedb-data/racedb.db3

chmod 755 /RaceDB/manage.py
echo "Initializing/Updating RaceDB Database..."
sleep 5
while true
do
    /RaceDB/manage.py migrate
    if [ $? -eq 0 ]; then
        break
    fi
    echo "Unable to connect to database...pausing"
    sleep 10
done

if [ ! -f $INITDATACONFIGURED ]; then
    /RaceDB/manage.py init_data
    touch $INITDATACONFIGURED
fi
