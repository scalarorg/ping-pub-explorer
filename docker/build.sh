#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"
source ${REPO_ROOT}/.env
echo "Building evmos ping-pub explorer"
docker build  $REPO_ROOT \
    -t evmos/explorer:latest

