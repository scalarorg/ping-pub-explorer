#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"

explorer() {
    echo "Building evmos ping-pub explorer"
    cd $REPO_ROOT
    docker build -t ping-pub-explorer:latest .
    "$@"
}

$@
