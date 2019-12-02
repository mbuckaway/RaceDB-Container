#!/bin/bash
#
# Script to import old version of RaceDB data from Sqlite database
#

DATAIMPORTED=/racedb-data/.sqlite3imported

if [ ! -f $DATAIMPORTED -a -f /RaceDB.sqlite3 ];
then
    export PYTHONPATH=/RaceDB
    export sqlite3_database_fname=/RaceDB.sqlite3
    cd /RaceDB
    python3 ./SqliteToDB.py
    touch $DATAIMPORTED
else
    echo "No data to import"
fi

