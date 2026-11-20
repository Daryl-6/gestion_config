# NOVA — gestion de configuration

Projet de laboratoire pour provisionner des VM Vagrant, configurer K3s avec
Ansible et déployer `nova-hello` avec Helm.

## Utilisation

Depuis la racine du dépôt, démarrer les VM puis lancer l'automatisation depuis
le contrôleur :

```powershell
vagrant up
vagrant ssh ctrl
```

```bash
cd /vagrant
make all
```

`make all` restaure les accès, vérifie le lint, applique le socle commun,
installe K3s et Helm, durcit les nœuds, déploie l'application et lance l'audit
Goss.

## Secrets et fichiers locaux

Les fichiers Vault des environnements (`ansible/inventories/group_vars/*/vault.yml`)
et leurs mots de passe ne sont pas distribués ni versionnés. Ils doivent être
fournis depuis une source de confiance avant `make all`.

Sur Windows, Vagrant monte en lecture seule le dossier local
`%USERPROFILE%\.nova-lab\secrets` dans le contrôleur sous `/mnt/nova-secrets`.
Il doit contenir `.vault_pass_preprod` et `.vault_pass_prod`, correspondant aux
fichiers Vault fournis. `make keys` vérifie les identifiants avant de les
installer avec des permissions privées dans le contrôleur.

Ne placez jamais de jeton, mot de passe ou clé privée dans le dépôt. Les valeurs
publiques par défaut du chart sont des exemples et doivent être remplacées dans
les déploiements réels.
