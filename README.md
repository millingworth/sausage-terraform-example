# sausage-terraform-example
- Install python3 + python3-pip + tox
`sudo apt update; sudo apt -y install python3 python3-pip tox`
- Setup virtualenv / terraform etc
`make install`
- Test terraform
`source your_openstack_creds`
`source ./venv/bin/activate`
`make plan`
- Deploy terraform plan
`make apply`
