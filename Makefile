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

ANSIBLE_PLAYBOOK_FLAGS += $(if $(filter y yes, $(ASK_VAULT_PASS)),--ask-vault-pass)
ANSIBLE_PLAYBOOK_FLAGS += $(if $(filter y yes, $(ASK_BECOME_PASS)),--ask-become-pass)
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

.PHONY: help clean

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

clean: clean-virtualenv

include virtualenv.mk

include ansible.mk

# Fix for ansible inventory scripts, can be skipped if no *.py scripts are in use.
export PATH := $(VENV_DIR)/bin:$(PATH)
