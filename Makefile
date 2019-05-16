##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

CHECK       ?= no
DIFF        ?= no
EXTRA_VARS  ?=
INVENTORY   ?=
LIMIT       ?=
SKIP_TAGS   ?=
TAGS        ?=
VERBOSE     ?= 0
OPTS        ?=
USE_PYTHON3 ?= yes
VENV_DIR    ?= venv

PIP_REQUIREMENTS     = requirements.txt
ANSIBLE_REQUIREMENTS = requirements.yml

PIP               = $(VENV_DIR)/bin/pip
ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE_GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE_INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE_PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_VAULT     = $(VENV_DIR)/bin/ansible-vault

ANSIBLE_PLAYBOOK_FLAGS += $(if $(filter y yes, $(CHECK)),--check)
ANSIBLE_PLAYBOOK_FLAGS += $(if $(filter y yes, $(DIFF)),--diff)
ANSIBLE_PLAYBOOK_FLAGS += $(foreach item,$(EXTRA_VARS),--extra-vars=$(item))
ANSIBLE_PLAYBOOK_FLAGS += $(foreach item,$(INVENTORY),--inventory=$(item))
ANSIBLE_PLAYBOOK_FLAGS += $(if $(LIMIT),--limit=$(LIMIT))
ANSIBLE_PLAYBOOK_FLAGS += $(foreach item,$(SKIP_TAGS),--skip-tags=$(item))
ANSIBLE_PLAYBOOK_FLAGS += $(foreach item,$(TAGS),--tags=$(item))
ANSIBLE_PLAYBOOK_FLAGS += $(if $(filter 1 2 3 4 5 6, $(VERBOSE)),$(word $(VERBOSE), -v -vv -vvv -vvvv -vvvvv -vvvvvv))
ANSIBLE_PLAYBOOK_FLAGS += $(OPTS)

ANSIBLE_INVENTORY_FLAGS += $(foreach item,$(INVENTORY),--inventory=$(item))

.PHONY: help clean virtualenv ansible-galaxy-install show-inventory

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

virtualenv: $(VENV_DIR) $(VENV_DIR)/.done
	@

$(VENV_DIR):
ifeq ($(USE_PYTHON3), yes)
	python3 -m venv $@
else
	virtualenv $@
endif

$(VENV_DIR)/.done: $(VENV_DIR) $(PIP_REQUIREMENTS)
	$(PIP) install --upgrade pip
	$(PIP) install -r $(PIP_REQUIREMENTS)
	touch $@

%: %.yml virtualenv
	$(ANSIBLE_PLAYBOOK) $(ANSIBLE_PLAYBOOK_FLAGS) $<

%.pem: %.pem.vault virtualenv
	$(ANSIBLE_VAULT) decrypt --output=$@ $<

ansible-galaxy-install: virtualenv $(ANSIBLE_REQUIREMENTS)
	$(ANSIBLE_GALAXY) install --role-file=$(ANSIBLE_REQUIREMENTS) --roles-path=roles.d/

show-inventory: virtualenv
	$(ANSIBLE_INVENTORY) $(ANSIBLE_INVENTORY_FLAGS) --graph
