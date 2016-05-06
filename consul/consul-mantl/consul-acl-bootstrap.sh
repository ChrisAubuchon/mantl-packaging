#!/bin/bash

set -x

consulConfigPath=${1:-/etc/consul/static.json}

# Extract tokens from $consulConfigPath
root=$(jq -r .acl_master_token ${consulConfigPath})
if [ -z "${root}" ]; then
	echo "No Consul master token"
	exit 1
fi

agent=$(jq -r .acl_token ${consulConfigPath})
if [ -z "${root}" ]; then
	echo "No Consul agent token"
	exit 1
fi

if [ "$(consul-cli acl info --token=${root} ${agent})" != "null" ]; then
	echo "Consul agent ACL defined"
	exit 0

fi

consul-cli acl update --token=${root} --name=agent_policy \
	--rule='key::write' \
	--rule='key:secure:deny' \
	--rule='service::write' \
	${agent}

exit 0
