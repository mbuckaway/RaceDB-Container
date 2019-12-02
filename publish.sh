#!/bin/bash

#
# Script to build the release zip

. .wharf
if [ -f RaceBB-Container-$TAG.zip ]; then
    rm -f RaceBB-Container-$TAG.zip
fi
zip RaceBB-Container-$TAG.zip README.md dbconfig.env.tmpl docker-compose*.yml racedb.env racedb.sh
