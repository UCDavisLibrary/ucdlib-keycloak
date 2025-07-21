#! /bin/bash

###
# Promotes a user to realm admin in local development Keycloak instance
# docker compose cluster must be running
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/../compose/ucdlib-keycloak-local-dev

USERNAME="$1"
if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

KC_PG_SERVICE="db"
KC_PG_DB="postgres"
KC_PG_USER="postgres"
KC_PG_PASSWORD="password"

docker compose exec -T "$KC_PG_SERVICE" psql -U "$KC_PG_USER" -d "$KC_PG_DB" <<EOF
DO \$\$
DECLARE
  master_realm_id UUID;
  user_id UUID;
  role_id UUID;
BEGIN
  -- Get master realm ID
  SELECT r.id INTO master_realm_id
  FROM realm r
  WHERE r.name = 'master';

  -- Get user ID in the master realm
  SELECT u.id INTO user_id
  FROM user_entity u
  WHERE u.username = '$USERNAME' AND u.realm_id = master_realm_id::text;

  IF user_id IS NULL THEN
    RAISE NOTICE 'User "$USERNAME" not found in realm "master"';
    RETURN;
  END IF;

  -- Get realm-level 'admin' role ID
  SELECT kr.id INTO role_id
  FROM keycloak_role kr
  WHERE kr.name = 'admin' AND kr.realm_id = master_realm_id::text AND kr.client IS NULL;

  IF role_id IS NULL THEN
    RAISE NOTICE 'Role "admin" not found in realm "master"';
    RETURN;
  END IF;

  -- Assign the role
  INSERT INTO user_role_mapping (user_id, role_id)
  VALUES (user_id, role_id)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Assigned role "admin" to user "$USERNAME" in realm "master"';
END
\$\$;
EOF
