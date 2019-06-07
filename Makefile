##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

USE_PYTHON3          ?= yes
ADD_PATH             ?= yes
VENV_DIR             ?= venv
PIP_REQUIREMENTS     ?= requirements.txt
ANSIBLE_REQUIREMENTS ?= requirements.yml
ANSIBLE_ROLES_PATH   ?= roles.d/

PIP               = $(VENV_DIR)/bin/pip
PYTHON            = $(VENV_DIR)/bin/python
ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE.CONFIG    = $(VENV_DIR)/bin/ansible-config
ANSIBLE.GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE.INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE.PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE.VAULT     = $(VENV_DIR)/bin/ansible-vault

## Here be dragons ;)

# Fix for Ansible *.py inventory scripts, useful for other tools.
ifeq ($(ADD_PATH), yes)
export PATH := $(VENV_DIR)/bin:$(PATH)
endif

.SECONDARY: virtualenv
virtualenv: $(VENV_DIR)/.installed

.PHONY: clean-virtualenv
clean-virtualenv:
	$(RM) -r $(VENV_DIR)

$(PIP) $(PYTHON): | $(VENV_DIR)

$(VENV_DIR):
ifeq ($(USE_PYTHON3), yes)
	python3 -m venv $(VENV_DIR)
else
	virtualenv $(VENV_DIR)
endif
	echo '*' > $(VENV_DIR)/.gitignore

$(VENV_DIR)/.installed: $(PIP_REQUIREMENTS) | $(VENV_DIR)
	$(PIP) install --upgrade pip
ifdef PIP_REQUIREMENTS
	$(PIP) install -r $(PIP_REQUIREMENTS)
endif
	touch $@

.PHONY: pip-freeze
pip-freeze: | $(PIP)
	$(PIP) freeze > $(PIP_REQUIREMENTS)


$(ANSIBLE): | virtualenv
	@test -f $@ || (echo "Cannot find Ansible. Try running 'make ansible-install' or fix PIP_REQUIREMENTS." && false)
	$(ANSIBLE) --version

.PHONY: ansible-install
ansible-install: | $(PIP)
	$(PIP) install ansible
	$(ANSIBLE) --version

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
