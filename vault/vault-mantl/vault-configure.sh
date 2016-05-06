#!/bin/bash
#
# vault-configure.sh
#
# Automatically configure vault for the Mantl environment
#

if [ -f /etc/vault/config.hcl ]; then
	exit 0
fi

addr=$(consul-cli agent self --template='{{ .Config.AdvertiseAddr }}')
token=$(jq -r .acl_master_token /etc/consul/static.json)

cat > /etc/vault/config.hcl << EOF
backend "consul" {
	address = "127.0.0.1:8500"
	path = "vault"
	scheme = "http"
	token = "${token}"
	advertise_addr = "https://${addr}:8200"
}

listener "tcp" {
	address = "0.0.0.0:8200"
	tls_cert_file = "/etc/pki/tls/certs/host.cert"
	tls_key_file = "/etc/pki/tls/private/host.key"
}
EOF
