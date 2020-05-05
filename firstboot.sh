#!/bin/sh

# set defaults
tmp="/root/"

# check for root privilege
if [ "$(id -u)" != "0" ]; then
   echo " this script must be run as root" 1>&2
   echo
   exit 1
fi

# determine ubuntu version
ubuntu_version=$(lsb_release -cs)

# print status message
echo " preparing your server; this may take a few minutes ..."

# Add additional ssh keys
# cat >> /home/ubuntu/.ssh/authorized_keys << EOF
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZIV98YFCbCTwB5VKahUsT0pmWuhp/posTRWaX98DNXRgdeLb0LoaINmZK1EtVWZFj9I7TRif3KOiZ2yvLmCiHaGYT5bQTfbaUbZ0fHEyNWymLHJ2tyjVyS9iTFqUBNieOs0WPmI+IIdEYpGIgUOF6xTfzh7fHGgSjfol5uwfWpG1VoWK11MtWQeYkQj4dSpnGJkeFrRZlIWrWZtOKxusr87Khxi7Vs8O4C+lOuFhjG8cTwpQ4OlWtVTPKnQ3zysrFYJhidqWskNrl7jnFr0LByhS2pI3Q6pVzLgVWHqqlVP+fJf+PTkR62jYnrwSeKMBZR1CaVodtokKk82ir8+Ot matt.illingworth@datacentred.co.uk
# EOF

# Do more things here

echo "firstboot script ran" > /tmp/firstboot.log
