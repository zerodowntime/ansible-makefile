##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

CHECK       ?= no
DIFF        ?= no
EXTRA_VARS  ?=
INVENTORY   ?= a
LIMIT       ?=
SKIP_TAGS   ?=
TAGS        ?=
VERBOSE     ?= 0
OPTS        ?=
USE_PYTHON3 ?= no
VENV_DIR    ?= venv

PIP_REQUIREMENTS  = requirements.txt
PIP               = $(VENV_DIR)/bin/pip
ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE_GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE_INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE_PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_VAULT     = $(VENV_DIR)/bin/ansible-vault

ANSIBLE_PLAYBOOK_OPTS += $(if $(filter y yes, $(CHECK)),--check)
ANSIBLE_PLAYBOOK_OPTS += $(if $(filter y yes, $(DIFF)),--diff)
ANSIBLE_PLAYBOOK_OPTS += $(foreach item,$(EXTRA_VARS),--extra-vars=$(item))
ANSIBLE_PLAYBOOK_OPTS += $(foreach item,$(INVENTORY),--inventory=$(item))
ANSIBLE_PLAYBOOK_OPTS += $(if $(LIMIT),--limit=$(LIMIT))
ANSIBLE_PLAYBOOK_OPTS += $(if $(SKIP_TAGS),--skip-tags=$(SKIP_TAGS))
ANSIBLE_PLAYBOOK_OPTS += $(if $(TAGS),--tags=$(TAGS))
ANSIBLE_PLAYBOOK_OPTS += $(if $(filter 1 2 3 4 5 6, $(VERBOSE)),$(word $(VERBOSE), -v -vv -vvv -vvvv -vvvvv -vvvvvv))
ANSIBLE_PLAYBOOK_OPTS += $(OPTS)

.PHONY: help clean pip-install

help:
	@echo "Usage: make playbook [playbook ...]"
	@echo "Variables:"
	@echo "  CHECK       - don't make any changes. Default: '$(CHECK)'."
	@echo "  DIFF        - show the differences. Default: '$(DIFF)'."
	@echo "  EXTRA_VARS  - additional variables. Default: '$(EXTRA_VARS)'."
	@echo "  INVENTORY   - specify inventory. Default: '$(INVENTORY)'."
	@echo "  LIMIT       - limit selected hosts. Default: '$(LIMIT)'."
	@echo "  SKIP_TAGS   - only run plays and tasks whose tags do not match. Default: '$(SKIP_TAGS)'."
	@echo "  TAGS        - only run plays and tasks tagged with these values. Default: '$(TAGS)'."
	@echo "  VERBOSE     - verbose mode [0-6]. Default: '$(VERBOSE)'."
	@echo "  OPTS        - extra options. Default: '$(OPTS)'."
	@echo "  USE_PYTHON3 - yes, for python3 virtual environment. Default: '$(USE_PYTHON3)'."
	@echo "  VENV_DIR    - directory to create the environment. Default: '$(VENV_DIR)'."

clean:
	$(RM) -r $(VENV_DIR)

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
