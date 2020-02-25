# roost-provision

Provision Roost servers using Ansible.

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

For example, if we were hosting the Roost website off an EC2 instance with the IP address `52.52.52.52`, I’d put the key file into `keys`, and I’d modify `hosts.yml` like so:

    all:
      hosts:
        roost-web:
          ansible_ssh_host: 52.52.52.52
          ansible_user: ec2-user
          ansible_ssh_private_key_file: keys/my-keyfile.pem
          [...]

In the above example, because we’ve given that machine a name of `roost-web`, it will be provisioned with the roles defined in `playbooks/roost-web.yml` – namely, it will be set up as an Amazon Linux 2 LAMP server, ready for you to manually install Wordpress.

## To provision a machine (or “host”)

Assuming you’ve set up the machine’s details in `hosts.yml`, you can provision it using any of the playbooks in the `playbooks` directory.

For example:

    ansible-playbook playbooks/roost-web.yml

Sometimes, during testing, it can be useful to run just a single "role" out of a playbook. Here’s how you’d do that:

    ansible-playbook playbooks/roost-web.yml --tags amazon-linux-wordpress

## Roost-web: Manually setting up a Wordpress site

As mentioned above, `roost-web` servers will get provisioned with:

* Apache, serving two web directories (`/var/www/production` and `/var/www/staging`) on both HTTP and HTTPS
* SSL certificates for the production and staging domains
* MySQL, with `production` and `staging` databases, and a `wordpress` user
* PHP

It also installs the [wp-cli](https://wp-cli.org/) command line tool at `/usr/bin/wp`, to help you interact with Wordpress sites manually at the command line.

If you wanted to install Wordpress into the `/var/www/staging` directory, you might do:

    cd /var/www/staging
    wp core download --locale=en_GB
    wp config create --dbname=staging --dbuser=wordpress --dbpass={{ wp_mysql_password }}
    wp core install --url={{ staging_domain }} --title='My lovely WordPress site' --admin_user='admin' --admin_password='changeme' --admin_email='joe@example.com' --skip-email
