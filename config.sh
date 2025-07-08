#! /bin/bash

######### DEPLOYMENT CONFIG ############
# Setup your application deployment here
########################################

APP_SLUG=auth-kc

# Grab build number is mounted in CI system
if [[ -f /config/.buildenv ]]; then
  source /config/.buildenv
else
  BUILD_NUM=-1
fi

# Main version number we are tagging the app with. Always update
# this when you cut a new version of the app!
APP_VERSION=v1.2.1.${BUILD_NUM}
REPO_TAG=v1.2.1

# Keycloak
KC_TAG=23.0.4

# Production Instance
# KC_HOSTNAME=auth.library.ucdavis.edu
# KC_HOST_PORT=3122

# Sandbox Instance
KC_HOSTNAME=sandbox.auth.library.ucdavis.edu
KC_HOST_PORT=3123

# Hot Spare Configuration (Legacy single-VM)
ENABLE_HOT_SPARE=false
KC_SPARE_HOST_PORT=3124

# Distributed HA Configuration
ENABLE_DISTRIBUTED_HA=true
REPLICA_KC_PORT=3124
REPLICA_DB_PORT=5433

# Postgres
POSTGRES_TAG=15.3

# Utils
NODE_TAG=20
UTILS_TAG=v1.0.1
BACKUP_FILE_NAME="db.sql.gz"
GC_BACKUP_BUCKET="itis-iam/keycloak"

# Custom images
CONTAINER_REG_ORG=gcr.io/ucdlib-pubreg
if [[ ! -z $LOCAL_BUILD ]]; then
  CONTAINER_REG_ORG='localhost/local-dev'
fi
if [[ -z $UTILS_TAG ]]; then
 CONTAINER_CACHE_TAG=$(git rev-parse --abbrev-ref HEAD)
else
 CONTAINER_CACHE_TAG=$UTILS_TAG
fi
UTILS_IMAGE_NAME=$CONTAINER_REG_ORG/$APP_SLUG-utils
UTILS_IMAGE_NAME_TAG=$UTILS_IMAGE_NAME:$UTILS_TAG

# local dev settings
LOCAL_DEV_DIRECTORY=keycloak-local-dev
KC_LOCAL_DEV_HOST_PORT=3000
KC_ADMIN_USERNAME=admin
KC_ADMIN_PASSWORD=admin
ADMINER_TAG=4.8.1
ADMINER_HOST_PORT=8080
