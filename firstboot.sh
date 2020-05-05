#!/bin/sh

# set defaults
tmp="/root/"
default_hostname="meat"
default_domain="sausage.systems"
export DEBIAN_FRONTEND=noninteractive

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

# set fqdn
fqdn="$default_hostname.$default_domain"

# update hostname
sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost $fqdn/g" /etc/hosts

# Add jitsi package repo
echo 'deb https://download.jitsi.org stable/' >> /etc/apt/sources.list.d/jitsi-stable.list
wget -qO -  https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -

# Add zabbix package repo
wget https://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1+bionic_all.deb
wget -qO -  https://repo.zabbix.com/zabbix-official-repo.key | sudo apt-key add -

apt-get install apt-transport-https

# update repos
apt-get -y update

echo "jitsi-videobridge jitsi-videobridge/jvb-hostname string meat.sausage.systems" | debconf-set-selections
echo "jitsi-meet-web-config jitsi-meet/cert-choice select 'Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)'" | debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt -y install jitsi-meet zabbix-sender zabbix-agent python3

sed -i "s/read EMAIL/EMAIL='matt@sausage.systems'/g" /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
/usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

sed -i "s/#DefaultLimitNOFILE=/DefaultLimitNOFILE=65000/g" /etc/systemd/system.conf
sed -i "s/#DefaultLimitNPROC=/DefaultLimitNPROC=65000/g" /etc/systemd/system.conf
sed -i "s/#DefaultTasksMax=/DefaultTasksMax=65000/g" /etc/systemd/system.conf
sed -i 's/JVB_OPTS=.*/JVB_OPTS="--apis=rest,"/g' /etc/jitsi/videobridge/config

# Install Sausage watermark
wget -O /usr/share/jitsi-meet/images/watermark.png https://gitlab.com/sausages/examples/-/raw/master/sausage.png?inline=false

# Configure zabbix-agent
sed -i "s/# UserParameter=/UserParameter=callstats.get,/opt/zabbix_callstats.py/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# Server=.*/Server=95.179.229.113,127.0.0.1/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# Hostname=.*/Hostname=meat.sausage.systems/g" /etc/zabbix/zabbix_agentd.conf

# Installing zabbix callstats script
cat > /opt/zabbix_callstats.py << EOF
#!/usr/bin/env python3
"""
Sends jitsi callstat metrics to Zabbix via zabbix_sender
"""
import json
import requests
import subprocess

videobridge_metric_url = "http://127.0.0.1:8080/colibri/stats"

def send_metric(metric_name, metric_value):
    subprocess.run(["zabbix_sender", "-c", "/etc/zabbix/zabbix_agentd.conf", "-k", metric_name, "-o", metric_value], stdout=(subprocess.DEVNULL))

def collect_metrics(videobridge_metric_url):
    r = requests.get(videobridge_metric_url)
    all_metrics = json.loads(r.content.decode())
    return all_metrics

def main():
    results = collect_metrics(videobridge_metric_url)
    #print(results)
    for metric, value in results.items():
        #print("Metric: {} Value: {}".format(metric,value))
        send_metric(str(metric), str(value))
    print(1)

if __name__ == '__main__':
    main()
EOF

chmod +x /opt/zabbix_callstats.py

systemctl daemon-reload
systemctl enable jicofo.service
systemctl enable jitsi-videobridge2
systemctl enable zabbix-agent.service
systemctl restart jitsi-videobridge2
systemctl restart zabbix-agent.service

echo "meat_firstboot script ran" > /tmp/meat_firstboot.log
