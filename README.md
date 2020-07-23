# Peepl & Roost provisioning scripts

Provision Peepl web servers using Ansible.

## Why Ansible?

Only crazy people would set up their servers by hand. Having an automated record of what you‘ve done makes tracking down bugs much easier, and it also means you can spin up exact copies of a server if you need to replace one, or if you mess something up and just want to get back to a known good state.

It’s tempting to do this sort of automation through shell scripts. And we’ve all done that before. But fairly quickly you’ll start hitting the limitations of shell scripting. Escaping strings. Programmatically editing lines in files. Making your scripts idempotent. Yuck.

Ansible solves that. Rather than writing raw shell commands, you write _configuration files_, which Ansible then runs on the machine of your choice. It looks after tricky things like error handling, idempotency, strings/templating.

Ansible has an [incredible number of modules](https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html), so for most commands you’d want to run in a shell script, chances are there’s an Ansible module that packages it all up in a nice, error-handled, idempotent wrapper.

And if there isn‘t an Ansible module for what you want to do, you can just use the `command` module, as if you were writing a shell script.

## Setup

First, you will need Ansible installed, eg:

    brew install ansible

[Find out how to install Ansible on your development machine](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

You will also want to edit `hosts.yml` to contain the names, IP addresses, and login details of all the machines (“hosts”) you care about provisioning.

If your servers require key pairs for SSH authentication (like EC2 servers do) then you can put the key pair files into the `keys` directory.

Here’s an example `hosts.yml` file, containing details about a single machine, which is an Amazon EC2 instance, with SSH keys stored in `./keys/example.pem`:

    all:
      hosts:
        roost-app:
          ansible_ssh_host: example.roostnow.co.uk
          ansible_user: ubuntu
          ansible_ssh_private_key_file: keys/example.pem
          ansible_ssh_extra_args: "-o IdentitiesOnly=yes"
          production_domain: example.roostnow.co.uk
          mysql_admin_user: admin
          mysql_admin_password: REPLACEME
          mysql_production_user: roost-app
          mysql_production_password: REPLACEME
          mysql_production_database: roostapp
          ssl_contact_email: example@roostnow.co.uk
          sails_contact_email: example@roostnow.co.uk

In the above example, because we’ve given that machine an “alias” of `roost-app`, it will be provisioned with the roles defined in `playbooks/roost-app.yml`.

Your `hosts.yml` file can define settings for multiple hosts, eg:

    all:
      hosts:
        roost-app:
          [...]
        peepl-app:
          [...]

## To provision a machine (or “host”)

Assuming you’ve set up the machine’s details in `hosts.yml`, with a matching playbook in the `playbooks` directory, you can run:

    ansible-playbook playbooks/roost-app.yml

This example would provision the `roost-app` host defined in `hosts.yml`, with the tasks defined in `playbooks/roost-app.yml`.
