#!/bin/bash
. .wharf
docker build -t $IMAGE:$TAG --no-cache .
