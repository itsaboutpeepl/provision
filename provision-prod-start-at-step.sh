#! /bin/zsh

# Issues: https://stackoverflow.com/a/53976078

# ~ https://stackoverflow.com/a/33264113 start at a subtask
# NOTE: `y` to run each task individually and `c` to continue all tasks from there
ansible-playbook playbooks/vegi-backend-prod.yml --step --start-at-task='Manually install npm packages'