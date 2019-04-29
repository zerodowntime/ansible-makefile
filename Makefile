##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

USE_PYTHON3 ?= no
VENV_DIR    ?= venv

PIP_REQUIREMENTS  = requirements.txt
PIP               = $(VENV_DIR)/bin/pip
pip-install: $(VENV_DIR) $(PIP_REQUIREMENTS)
	$(PIP) install -r $(PIP_REQUIREMENTS)

$(VENV_DIR):
ifeq ($(USE_PYTHON3), yes)
	python3 -m venv $@
else
	virtualenv $@
endif
	$(PIP) install --upgrade pip
