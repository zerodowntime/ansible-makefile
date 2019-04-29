##
## author: Piotr Stawarski <piotr.stawarski@zerodowntime.pl>
##

USE_PYTHON3 ?= no
VENV_DIR    ?= venv

$(VENV_DIR):
ifeq ($(USE_PYTHON3), yes)
	python3 -m venv $@
else
	virtualenv $@
endif
	$(PIP) install --upgrade pip
