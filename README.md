# Keyloak Deployment

[Keycloak](https://www.keycloak.org/) is the Identity and Access Management system used by the UC Davis Library. It primarily acts as an identity broker for the UC Davis Central Authentication System (CAS), and is hosted at `auth.library` and `sandbox.auth.library`.

Configuration instructions and best practices can be found in this [Google Doc](https://docs.google.com/document/d/1Zd_Vv-hYuo-DX6bbNImLkH3DDAjCC3I-0ISgYZZ5lEs/edit?tab=t.0#heading=h.xxf2clu5zodi).

## Local Dev
- `./cmds/get-reader-key.sh` to get Google Cloud (GC) key for data hydration service
- `./cmds/get-env.sh local-dev` to download the env file.
- Edit env file and remove any production-level credentials. For local host, most env variables are automatically set via the docker compose file.
- `./build-local-dev.sh` to build local docker images
- `cd compose/ucdlib-keycloak-local-dev` and `docker compose up -d`

The keycloak instance will become available after the init container completes (`docker compose logs init -f`). Go to [https://localhost:8443](https://localhost:8443). You will have to accept the self-signed certificate in your browser. (https is required to use UCD CAS as an IDP).

Since your permission level will be the same as the data environment set in the init container, you might need to elevate yourself to an admin. You can do this with `./cmds/promote-local-kc-user.sh <your kc username>`.

If you need to test out auth flows or inspect tokens, you can use the application in `tools/test-app`.

## Deployment
