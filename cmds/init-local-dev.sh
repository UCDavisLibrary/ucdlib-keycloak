#! /bin/bash

###
# Do the basic setup for local development
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

source ./config.sh

if [ ! -d "./$LOCAL_DEV_DIRECTORY" ]; then
  mkdir ./$LOCAL_DEV_DIRECTORY
  touch ./$LOCAL_DEV_DIRECTORY/.env
fi

touch ./gc-writer-key.json
touch ./gc-reader-key.json
