#!/bin/bash 

version_ge() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

repo="fossbilling/fossbilling"
last_version=0.0.0
current_version=$(cat /var/lib/docker/volumes/docker_fossbilling/_data/library/FOSSBilling/Version.php | grep "VERSION" | head -n1 | cut -f2 -d "'")

for version in $(curl -s "https://hub.docker.com/v2/repositories/$repo/tags?page_size=100" | jq -r '.results|.[]|.name'); do
 if [[ "$version"  =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  if version_ge $version $current_version; then 
    ./upgrade.sh
  fi
 fi
done