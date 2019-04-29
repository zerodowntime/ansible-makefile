# ansible-makefile

## Usage:
```
make playbook [playbook2 ...]  # run playbooks (one after another)
make clean                     # remove virtual environment
make help                      # guess ;)
```

## Variables:
* `CHECK`       - don't make any changes. Default: 'no'.
* `DIFF`        - show the differences. Default: 'no'.
* `EXTRA_VARS`  - additional variables. Default: ''.
* `INVENTORY`   - specify inventory. Default: ''.
* `LIMIT`       - limit selected hosts. Default: ''.
* `SKIP_TAGS`   - only run plays and tasks whose tags do not match. Default: ''.
* `TAGS`        - only run plays and tasks tagged with these values. Default: ''.
* `VERBOSE`     - verbose mode [0-6]. Default: '0'.
* `OPTS`        - extra options. Default: ''.
* `USE_PYTHON3` - yes, for python3 virtual environment. Default: 'no'.
* `VENV_DIR`    - directory to create the environment. Default: 'venv'.
