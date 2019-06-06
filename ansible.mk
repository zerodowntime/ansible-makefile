##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

ANSIBLE_REQUIREMENTS ?= requirements.yml
ANSIBLE_ROLES_PATH   ?= roles.d/

ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE.CONFIG    = $(VENV_DIR)/bin/ansible-config
ANSIBLE.GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE.INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE.PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE.VAULT     = $(VENV_DIR)/bin/ansible-vault

## Here be dragons ;)

$(ANSIBLE): | virtualenv
	@test -f $@ || (echo "Cannot find Ansible. Try running 'make ansible-install' or fix PIP_REQUIREMENTS." && false)

.PHONY: ansible-install
ansible-install: | $(PIP)
	$(PIP) install ansible

.PHONY: galaxy-install
galaxy-install: $(ANSIBLE_REQUIREMENTS) | $(ANSIBLE)
	$(ANSIBLE.GALAXY) install --role-file=$(ANSIBLE_REQUIREMENTS) --roles-path=$(ANSIBLE_ROLES_PATH)

.PHONY: list-inventory
list-inventory: | $(ANSIBLE)
	$(ANSIBLE.INVENTORY) $(ANSIBLE_INVENTORY_FLAGS) --list

.PHONY: show-inventory
show-inventory: | $(ANSIBLE)
	$(ANSIBLE.INVENTORY) $(ANSIBLE_INVENTORY_FLAGS) --graph

.PHONY: run-playbook
run-playbook: $(PLAYBOOK) | $(ANSIBLE)
	$(ANSIBLE.PLAYBOOK) $(ANSIBLE_PLAYBOOK_FLAGS) $^

%: %.yml FORCE-PHONY | $(ANSIBLE)
	$(ANSIBLE.PLAYBOOK) $(ANSIBLE_PLAYBOOK_FLAGS) $<

%: %.vault | $(ANSIBLE)
	$(ANSIBLE.VAULT) decrypt $(ANSIBLE_VAULT_FLAGS) --output=$@ $<

.PHONY: FORCE-PHONY
FORCE-PHONY:
	@
