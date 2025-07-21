#! /bin/bash

###
# download the writer key from the secret manager
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

mkdir -p secrets
cd secrets

gcloud --project=digital-ucdavis-edu secrets versions access latest --secret=itis-iam-support-writer-key > gc-writer-key.json
