#!/bin/bash
#
# Configure RaceDB

dbconfigerror()
{
    echo "Database configuration failed. Refusing to start RaceDB"
    /usr/sbin/cron -f
}

DBCONFIG=/RaceDB/RaceDB/DatabaseConfig.py
TZCONFIG=/RaceDB/RaceDB/time_zone.py
DBCONFIGURED=/.db-configured

if [ -f $DBCONFIGURED ]; then
    echo "Database already configured."
else
    # Set some reasonable defaults
    DB_USER=racedb
    DB_DATABASE=racedb

    if [ -z "$DB_HOST" ]; then
        DB_HOST=db
    else
        DB_HOST=$DB_HOST
    fi

    if [ -z "$DB_USER" ]; then
        DB_USER=$DB_USER
    else
        DB_USER=$DB_USER
    fi


    case "$DATABASE_TYPE" in 
        mysql)
            echo "Configuring RaceDB for Mysql"
            cat > $DBCONFIG <<EOF
DatabaseConfig = {
    'ENGINE': 'django.db.backends.mysql',
    'NAME': '$MYSQL_DATABASE',		# Name of the database.  Must be configured in your database.
    'USER': '$MYSQL_USER',		# Username to access the database.  Must be configured in your database.
    'PASSWORD': '$MYSQL_PASSWORD',	# Username password.
    'HOST': 'db',   # Or the IP Address that your DB is hosted on (eg. '10.156.131.101')
    'PORT': '3306',	# MySql database port
}
EOF
            ;;
        psql)
            echo "Configuring RaceDB for PostgreSQL"
            cat > $DBCONFIG <<EOF
DatabaseConfig = {
    'ENGINE': 'django.db.backends.postgresql',
    'NAME': '$PSQL_DATABASE',		# Name of the database.  Must be configured in your database.
    'USER': '$PSQL_USER',		# Username to access the database.  Must be configured in your database.
    'PASSWORD': '$PSQL_PASSWORD',	# Username password.
    'HOST': 'db',   # Or the IP Address that your DB is hosted on (eg. '10.156.131.101')
    'PORT': '5432',	# Psql database port
}
EOF
            ;;
        sqlite)
            echo "Configuring RaceDB for SQLite"
            cat > $DBCONFIG <<EOF
DatabaseConfig = {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': '/racedb-data/RaceDB.sqlite3',		# Name of the database.  Must be configured in your database.
}
EOF
            ;;
        *)
            echo "Unknown database selected. RaceDB will default to Sqlite!"
            ;;
    esac

    echo "TIME_ZONE=\"$TIME_ZONE\"" > $TZCONFIG
    touch $DBCONFIGURED
fi


