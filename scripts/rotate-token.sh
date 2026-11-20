#!/usr/bin/env bash
# Generate and encrypt a new application token for one environment.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 preprod|prod" >&2
  exit 2
fi

ENV="$1"
case "$ENV" in
  preprod|prod) ;;
  *)
    echo "Usage: $0 preprod|prod" >&2
    exit 2
    ;;
esac

cd /vagrant/ansible

VAULT_FILE="inventories/group_vars/${ENV}/vault.yml"
NEW_TOKEN="tok-${ENV}-$(openssl rand -hex 16)"
TMP="$(mktemp)"
trap 'shred -u "$TMP" 2>/dev/null || rm -f "$TMP"' EXIT

printf 'vault_nova_api_token: "%s"\n' "$NEW_TOKEN" > "$TMP"
ansible-vault encrypt --encrypt-vault-id "$ENV" --output "$VAULT_FILE" "$TMP"

echo "Nouveau jeton chiffré dans ${VAULT_FILE}."
echo "Étape suivante : ansible-playbook playbooks/deploy.yml --limit ${ENV} -e nova_require_approval=false"
