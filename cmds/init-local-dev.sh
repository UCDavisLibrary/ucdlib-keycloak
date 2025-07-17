#! /bin/bash

###
# Do the basic setup for local development
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

./cmds/get-reader-key.sh
./cmds/get-env.sh local-dev
