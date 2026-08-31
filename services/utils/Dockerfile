FROM node:22

RUN mkdir /kc-utils
WORKDIR /kc-utils

RUN apt-get update && apt-get install -y \
apt-transport-https \
ca-certificates \
gnupg \
curl \
cron \
vim \
lsb-release \
procps

# Prep work for gsutil
RUN install -d -m 0755 /etc/apt/keyrings \
 && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | gpg --dearmor -o /etc/apt/keyrings/cloud.google.gpg \
 && chmod 0644 /etc/apt/keyrings/cloud.google.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  > /etc/apt/sources.list.d/google-cloud-cli.list

# prep for postgres
RUN install -d -m 0755 /etc/apt/keyrings \
 && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg \
 && chmod 0644 /etc/apt/keyrings/postgresql.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] \
  http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y postgresql-client \
  wait-for-it google-cloud-cli
RUN mkdir data
COPY tail.sh tail.sh

# Backup
RUN mkdir data/backup
COPY backup backup
COPY backup/cron /etc/cron.d/backup
RUN chmod 0644 /etc/cron.d/backup

# Init
RUN mkdir data/init
COPY init init

WORKDIR /kc-utils
ENTRYPOINT [ "bash", "-c" ]
CMD ["echo 'Use command arg to specify a script to run.'"]
