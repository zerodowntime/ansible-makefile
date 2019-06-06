##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

USE_PYTHON3      ?= yes
ADD_PATH         ?= yes
VENV_DIR         ?= venv
PIP_REQUIREMENTS ?= requirements.txt

PIP    = $(VENV_DIR)/bin/pip
PYTHON = $(VENV_DIR)/bin/python

## Here be dragons ;)

# Fix for Ansible *.py inventory scripts, useful for other tools.
ifeq ($(ADD_PATH), yes)
export PATH := $(VENV_DIR)/bin:$(PATH)
endif

.SECONDARY: virtualenv
virtualenv: $(VENV_DIR)/.installed $(VENV_DIR)/.gitignore

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

$(VENV_DIR)/.installed: $(PIP_REQUIREMENTS) | $(VENV_DIR)
	$(PIP) install --upgrade pip
ifdef PIP_REQUIREMENTS
	$(PIP) install -r $(PIP_REQUIREMENTS)
endif
	touch $@

$(VENV_DIR)/.gitignore: | $(VENV_DIR)
	echo '*' > $@

.PHONY: pip-freeze
pip-freeze: | $(PIP)
	$(PIP) freeze > $(PIP_REQUIREMENTS)
