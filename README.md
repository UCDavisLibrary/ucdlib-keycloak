# Keyloak Deployment

[Keycloak](https://www.keycloak.org/) is the Identity and Access Management system used by the UC Davis Library. It primarily acts as an identity broker for the UC Davis Central Authentication System (CAS), and is hosted at `auth.library` and `sandbox.auth.library`.

Configuration instructions and best practices can be found in this [Google Doc](https://docs.google.com/document/d/1Zd_Vv-hYuo-DX6bbNImLkH3DDAjCC3I-0ISgYZZ5lEs/edit?tab=t.0#heading=h.xxf2clu5zodi).

## Local Dev
- `./cmds/get-reader-key.sh` to get Google Cloud (GC) key for data hydration service
- `./cmds/get-env.sh local-dev` to download the env file.
- Edit env file and remove any production-level credentials. For local host, most env variables are automatically set via the docker compose file.
- `./build-local-dev.sh` to build local docker images
- `cd compose/ucdlib-keycloak-local-dev` and `docker compose up -d`

The keycloak instance will become available after the init container completes (`docker compose logs init -f`). Go to [https://localhost:8443](https://localhost:8443). You will have to accept the self-signed certificate in your browser (https is required to use UCD CAS as an IDP).

Since your permission level will be the same as the data environment retrieved by the init container, you might need to elevate yourself to an admin. You can do this with `./cmds/promote-local-kc-user.sh <your kc username>`.

If you need to test out auth flows or inspect tokens, you can use the application in `tools/test-app`.

## Deployment

### On Your Machine
- Push all changes to sandbox branch, create a PR to main, and merge
  - Make sure the relevant compose file in the `compose` directory has the new image tags
- Checkout main, pull, and create a new tag - `git tag vx.y.z` `git push origin --tags`
- Update [cork-build-registry](https://github.com/ucd-library/cork-build-registry)
- Build images with `cmds/build.sh <tag>`

### On Server
- ssh into `auth.library`
- Like other ucd library deployments, there are two alternating production versions: blue and gold
  - If we are currently running blue, the new version will be gold and vice-versa
  - To determine which cluster is currently running, run `docker ps` and look in the `NAMES` column
- `cd /opt/ucdlib-keycloak/compose/ucdlib-keycloak-<new-color>` and run `git pull` then `docker compose pull` to retrieve the newly  built images
- run `docker compose down -v` and then `docker compose up -d`
- Follow along with logs to make sure keycloak starts successfully and hydrates its volume: `docker compose logs init keycloak -f`
- Navigate to the apache config directory: `cd /etc/httpd/conf.d`
- Remove `disabled` suffix from new config, and add to old config
  - `sudo mv old-color.conf old-color.conf.disabled`
  - `sudo mv new-color.conf.disabled new-color.conf`
- Reload apache `sudo systemctl reload httpd`
- Shut down old cluster `cd /opt/ucdlib-keycloak/compose/ucdlib-keycloak-<old-color>` and `docker compose down`
- Verify `auth.library` is up and running
