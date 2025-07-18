FROM quay.io/keycloak/keycloak:23.0.4 as keycloak

COPY themes/ucd-theme /opt/keycloak/themes/ucd-theme

# Generate a self-signed certificate for Localdev
# Otherwise, UCD CAS will not work as an IDP
RUN keytool -genkeypair \
    -storepass password \
    -storetype PKCS12 \
    -keyalg RSA -keysize 2048 \
    -dname "CN=server" -alias server \
    -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \
    -keystore /opt/keycloak/conf/server.keystore

RUN /opt/keycloak/bin/kc.sh build

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
