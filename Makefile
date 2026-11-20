SHELL := /bin/bash
export ANSIBLE_CONFIG := $(CURDIR)/ansible/ansible.cfg

.DEFAULT_GOAL := all
.NOTPARALLEL:
.PHONY: all deps lint keys baseline clusters harden deploy audit

all: deps keys lint baseline clusters harden deploy audit

deps:
	ansible-galaxy collection install -r ansible/requirements.yml

lint:
	ansible-lint ansible/playbooks ansible/roles
	yamllint ansible/inventories ansible/playbooks ansible/roles
	helm lint charts/nova-hello

keys:
	bash scripts/make-keys.sh

baseline:
	ansible-playbook ansible/playbooks/baseline.yml --forks 1

clusters:
	ansible-playbook ansible/playbooks/clusters.yml --forks 1

harden:
	ansible-playbook ansible/playbooks/harden.yml --forks 1

deploy:
	ansible-playbook ansible/playbooks/deploy.yml --forks 1 -e nova_require_approval=false

audit:
	ansible-playbook ansible/playbooks/audit.yml --forks 1
