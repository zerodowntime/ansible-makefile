##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

USE_PYTHON3 ?= no
VENV_DIR    ?= venv

PIP_REQUIREMENTS  = requirements.txt
PIP               = $(VENV_DIR)/bin/pip
ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE_GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE_INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE_PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_VAULT     = $(VENV_DIR)/bin/ansible-vault

## Here be dragons ;)

# Fix for ansible inventory scripts, can be skipped if no *.py scripts are in use.
export PATH := $(VENV_DIR)/bin:$(PATH)

%: %.yml pip-install
	$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PLAYBOOK_OPTS) $<

pip-install: $(VENV_DIR) $(PIP_REQUIREMENTS)
	$(PIP) install -r $(PIP_REQUIREMENTS)

$(VENV_DIR):
ifeq ($(USE_PYTHON3), yes)
	python3 -m venv $@
else
	virtualenv $@
endif
	$(PIP) install --upgrade pip
