##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

ANSIBLE_REQUIREMENTS ?= requirements.yml
ANSIBLE_ROLES_PATH   ?= roles.d/

ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE_CONFIG    = $(VENV_DIR)/bin/ansible-config
ANSIBLE_GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE_INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE_PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_VAULT     = $(VENV_DIR)/bin/ansible-vault

## Here be dragons ;)

$(ANSIBLE): | virtualenv
	@test -f $@ || (echo "Cannot find Ansible. Try running 'make ansible-install' or fix PIP_REQUIREMENTS." && false)

.PHONY: ansible-install
ansible-install: | $(PIP)
	$(PIP) install ansible

.PHONY: galaxy-install
galaxy-install: $(ANSIBLE_REQUIREMENTS) | $(ANSIBLE)
	$(ANSIBLE_GALAXY) install --role-file=$(ANSIBLE_REQUIREMENTS) --roles-path=$(ANSIBLE_ROLES_PATH)

.PHONY: show-inventory
show-inventory: | $(ANSIBLE)
	$(ANSIBLE_INVENTORY) $(ANSIBLE_INVENTORY_FLAGS) --graph

.PHONY: run-playbook
run-playbook: $(PLAYBOOK) | $(ANSIBLE)
	$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PLAYBOOK_FLAGS) $^

%: %.yml FORCE-PHONY | $(ANSIBLE)
	$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PLAYBOOK_FLAGS) $<

%: %.vault | $(ANSIBLE)
	$(ANSIBLE_VAULT) $(ANSIBLE_VAULT_FLAGS) decrypt --output=$@ $<

.PHONY: FORCE-PHONY
FORCE-PHONY:
	@
