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
USE_PYTHON3 ?= no
VENV_DIR    ?= venv

PIP_REQUIREMENTS  = requirements.txt
PIP               = $(VENV_DIR)/bin/pip
ANSIBLE           = $(VENV_DIR)/bin/ansible
ANSIBLE_GALAXY    = $(VENV_DIR)/bin/ansible-galaxy
ANSIBLE_INVENTORY = $(VENV_DIR)/bin/ansible-inventory
ANSIBLE_PLAYBOOK  = $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_VAULT     = $(VENV_DIR)/bin/ansible-vault

ifeq ($(CHECK), yes)
ANSIBLE_PLAYBOOK_OPTS += --check
endif
ifeq ($(DIFF), yes)
ANSIBLE_PLAYBOOK_OPTS += --diff
endif
ifdef EXTRA_VARS
ANSIBLE_PLAYBOOK_OPTS += $(foreach item,$(EXTRA_VARS),--extra-vars=$(item))
endif
ifdef INVENTORY
ANSIBLE_PLAYBOOK_OPTS += $(foreach item,$(INVENTORY),--inventory=$(item))
endif
ifdef LIMIT
ANSIBLE_PLAYBOOK_OPTS += --limit=$(LIMIT)
endif
ifdef SKIP_TAGS
ANSIBLE_PLAYBOOK_OPTS += --skip-tags=$(SKIP_TAGS)
endif
ifdef TAGS
ANSIBLE_PLAYBOOK_OPTS += --tags=$(TAGS)
endif
ifneq ($(VERBOSE), 0)
ANSIBLE_PLAYBOOK_OPTS += $(word $(VERBOSE), -v -vv -vvv -vvvv -vvvvv -vvvvvv)
endif
ifdef OPTS
ANSIBLE_PLAYBOOK_OPTS += $(OPTS)
endif

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
