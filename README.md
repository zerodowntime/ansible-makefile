# ansible-makefile

## Targets

- `virtualenv` - creates virtualenv directory and installs pip requirements
- `clean-virtualenv` - removes virtualenv directory
- `pip-freeze` - updates PIP_REQUIREMENTS file
- `ansible-install` - installs latest Ansible version
- `galaxy-install` - installs Ansible roles from ANSIBLE_REQUIREMENTS file
- `list-inventory` - shows Ansible inventory hosts info (--list)
- `show-inventory` - shows Ansible inventory graph (--graph)
- `run-playbook` - must provide `PLAYBOOK` variable with playbook(s)
- `%` - runs playbook `%.yml`
- `%` - decrypts `%.vault` file

## Configuration variables
- `USE_PYTHON3` - if `yes` will use python3, else virtualenv tool (default: `yes`)
- `VENV_DIR` - a directory to create the environment in (default: `venv`)
- `ADD_PATH` - if `yes` will add VENV_DIR to PATH (default: `yes`)
- `PYTHON_EXE` - the Python interpreter to use (default: `python3|python2`)
- `PIP_REQUIREMENTS` - pip requirements file name (default: `requirements.txt`)
- `ANSIBLE_REQUIREMENTS` - file containing a list of roles to be imported (default: `requirements.yml`)
- `ANSIBLE_ROLES_PATH` - the path to the directory containing your roles (default: `roles.d/`)

## Execution variables
- `ANSIBLE_INVENTORY_FLAGS` - passed to `ansible-inventory` command
- `ANSIBLE_PLAYBOOK_FLAGS` - passed to `ansible-playbook` command
- `ANSIBLE_VAULT_FLAGS` - passed to `ansible-vault` command

## Basic usage

If you do not have `requirements.txt`, prepare environment:
```
make ansible-install
make pip-freeze
```

If you have `requirements.txt` file:
```
make virtualenv
```
or just can just run Ansible targets and let `virtualenv` to be installed as a prerequisite:
```
make galaxy-install                     # optional
make run-playbook PLAYBOOK=playbook.yml # run playbook (full playbook name)
make playbook [playbook2 ...]           # run playbook (without *.yml)
```

## Customization

The best way to customize is to create your own `Makefile`, include this one and add your own magic ie.:
```
include ansible-makefile/Makefile

SETUP     ?= devel

ADD_INVENTORY_OPTIONS += -i inventories/$(SETUP)

ANSIBLE_PLAYBOOK_FLAGS   += $(ADD_INVENTORY_OPTIONS)
ANSIBLE_INVENTORY_FLAGS  += $(ADD_INVENTORY_OPTIONS)

PLAYBOOKS += playbooks/foo
PLAYBOOKS += playbooks/bar
PLAYBOOKS += playbooks/baz

all: $(PLAYBOOKS)
  echo ALL DONE!!

aws-magic: playbooks/aws-vpc-setup playbooks/aws-route53-setup

run-some-tasks: ANSIBLE_PLAYBOOK_FLAGS += -t foobar
run-some-tasks: ANSIBLE_PLAYBOOK_FLAGS += -t whatever
run-some-tasks: playbooks/site
```
## License

[Apache License 2.0](LICENSE)

## Support

ansible@zerodowntime.pl
