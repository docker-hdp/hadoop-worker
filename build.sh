#!/bin/bash

if [[ ${#1} < 1 ]]; then
	echo "build: Config path cannot be empty"
	exit 1;
fi

if [ ! -d $1 ]; then
	echo "build: Config path must be a valid directory"
	exit 1;
fi


# Build steps
mkdir -p ./tmp && \
cp -rp $1/hadoop/ ./tmp/conf/ && \
docker build -t docker-hdp/hadoop-worker:1.0 . && \
rm -rf ./tmp/conf