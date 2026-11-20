#!/usr/bin/env bash
set -euo pipefail

cd /vagrant

KEY_DIR="${HOME}/.ssh"
install -d -m 0700 "$KEY_DIR"

for ENV in preprod prod; do
  VAULT_SOURCE="/mnt/nova-secrets/.vault_pass_${ENV}"
  VAULT_DEST="${HOME}/.vault_pass_${ENV}"
  VAULT_TEMP="${VAULT_DEST}.new"
  VAULT_FILE="ansible/inventories/group_vars/${ENV}/vault.yml"

  if [ ! -r "$VAULT_SOURCE" ]; then
    echo "Missing secure Vault password backup: ${VAULT_SOURCE}" >&2
    exit 1
  fi

  install -m 0600 "$VAULT_SOURCE" "$VAULT_TEMP"
  if ! ansible-vault view --vault-id "${ENV}@${VAULT_TEMP}" "$VAULT_FILE" >/dev/null; then
    rm -f "$VAULT_TEMP"
    echo "Vault password backup is invalid for ${ENV}." >&2
    exit 1
  fi
  mv -f "$VAULT_TEMP" "$VAULT_DEST"
done

for USER_NAME in alice bob; do
  PRIVATE_KEY="${KEY_DIR}/${USER_NAME}"
  PUBLIC_KEY="${PRIVATE_KEY}.pub"

  if [ -f "$PRIVATE_KEY" ] && [ -f "$PUBLIC_KEY" ]; then
    continue
  fi

  if [ -e "$PRIVATE_KEY" ] || [ -e "$PUBLIC_KEY" ]; then
    echo "Incomplete SSH key pair for ${USER_NAME} in ${KEY_DIR}" >&2
    exit 1
  fi

  ssh-keygen -q -t ed25519 -N "" -C "${USER_NAME}@nova" -f "$PRIVATE_KEY"
  chmod 0600 "$PRIVATE_KEY"
  chmod 0644 "$PUBLIC_KEY"
done

echo "Vault credentials restored and access keys are ready."
