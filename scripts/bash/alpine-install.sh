#!/bin/sh
set -eu

PG_MAJ_VER=18

BLUE='\033[0;34m'
RESET='\033[0m'

info() {
    printf "${BLUE}*** %s ***${RESET}\n" "$*"
}

# Check running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Relaunch under bash if necessary
if [ -z "${BASH_VERSION:-}" ]; then
    info "Not running in bash"

    if ! apk info -e bash >/dev/null 2>&1; then
        echo "Bash is not installed"
        apk update
        apk add bash
    fi

    info "Relaunching in bash"
    exec bash "$0" "$@"
fi



info "Running in bash"

info "Updating packages"
apk update
apk upgrade

info "Installing required packages"
apk add \
  postgresql${PG_MAJ_VER} \
  postgresql${PG_MAJ_VER}-contrib \
  sudo \
  wget

info "Granting sudo to wheel group"
sed -i -E 's/^[[:space:]]*#[[:space:]]*(%wheel ALL=\(ALL:ALL\) ALL)$/\1/' /etc/sudoers
visudo -c

info "Enabling and starting PostgreSQL"
rc-update add postgresql
rc-service postgresql start

sleep 10
if ! rc-service postgresql status; then
    echo "PostgreSQL failed to start" >&2
    exit 1
fi

info "Updating postgresql.conf"
sed -i -E \
  "s/^#?[[:space:]]*listen_addresses[[:space:]]*=.*/listen_addresses = '*'/" \
  /etc/postgresql${PG_MAJ_VER}/postgresql.conf
sed -i -E \
  "s|^[[:space:]]*#?[[:space:]]*shared_preload_libraries[[:space:]]*=.*|shared_preload_libraries = 'age,pg_cron,pg_tle'|" \
  /etc/postgresql${PG_MAJ_VER}/postgresql.conf

sed -i -E \
  "s|^[[:space:]]*#?[[:space:]]*session_preload_libraries[[:space:]]*=.*|session_preload_libraries = 'age'|" \
  /etc/postgresql${PG_MAJ_VER}/postgresql.conf

if grep -qE '^[[:space:]]*#?[[:space:]]*cron\.database_name[[:space:]]*=' /etc/postgresql${PG_MAJ_VER}/postgresql.conf; then
    sed -i -E \
      "s|^[[:space:]]*#?[[:space:]]*cron\.database_name[[:space:]]*=.*|cron.database_name = 'postgres'|" \
      /etc/postgresql${PG_MAJ_VER}/postgresql.conf
else
    echo "cron.database_name = 'postgres'" >> /etc/postgresql${PG_MAJ_VER}/postgresql.conf
fi

info "Updating pg_hba.conf"
sed -i -E \
  "s@^[[:space:]]*host[[:space:]]+all[[:space:]]+all[[:space:]]+(127[.]0[.]0[.]1/32|0[.]0[.]0[.]0/0)[[:space:]]+(trust|scram-sha-256)[[:space:]]*\$@host all all 0.0.0.0/0 scram-sha-256@" \
  /etc/postgresql${PG_MAJ_VER}/pg_hba.conf

info "Adding personal repository"
alpine_branch="$(
    awk -F/ '
        $0 !~ /^[[:space:]]*#/ && NF >= 5 {
            print $5
            exit
        }
    ' /etc/apk/repositories
)"
if [ -z "$alpine_branch" ]; then
    echo "Unable to determine Alpine branch from /etc/apk/repositories" >&2
    exit 1
fi
wget -O /etc/apk/keys/jamesdkelly88.rsa.pub \
  https://jamesdkelly88.github.io/alpine-apks/jamesdkelly88.rsa.pub

repo_url="https://jamesdkelly88.github.io/alpine-apks/${alpine_branch}/postgresql"
if ! grep -Fqx "$repo_url" /etc/apk/repositories; then
    echo "$repo_url" >> /etc/apk/repositories
fi

info "Adding extensions"
apk update
apk add \
  postgresql${PG_MAJ_VER}-age \
  postgresql-pg_cron \
  postgresql-pg_tle

info "Restarting postgresql service"
rc-service postgresql restart

sleep 5
if ! rc-service postgresql status; then
    echo "PostgreSQL failed after extension installation" >&2
    exit 1
fi
info "Setting postgres user password"
sudo -u postgres psql -d postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"




