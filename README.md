# snirin_infra
snirin Infra repository

ДЗ 6 cloud-testapp
testapp_IP = 35.233.127.3
testapp_port = 9292

Создание инстанса со startup скриптом
gcloud compute instances create reddit-app1 \
 --boot-disk-size=10GB \
 --image-family ubuntu-1604-lts \
 --image-project=ubuntu-os-cloud \
 --machine-type=g1-small \
 --tags puma-server \
 --metadata-from-file startup-script=startup.sh

Правило файервола
gcloud compute --project=infra-265807 firewall-rules create default-puma-server2 \
 --direction=INGRESS \
 --priority=1000 \
 --network=default \
 --action=ALLOW \
 --rules=tcp:80 \
 --source-ranges=0.0.0.0 \
 --target-tags=puma-server

ДЗ 5 cloud-bastion
bastion_IP = 35.195.142.20
someinternalhost_IP = 10.132.0.4

Подключение одной командой (4 варианта)
ssh -t -A appuser@35.195.142.20  ssh someinternalhost
ssh -J appuser@35.195.142.20  appuser@someinternalhost
ssh -o ProxyCommand="ssh -W %h:%p appuser@35.195.142.20" appuser@someinternalhost
ssh -o "ProxyJump appuser@35.195.142.20" appuser@someinternalhost

Для подключения через "ssh someinternalhost" надо как вариант добавить в файл .ssh/config следующие строки (2 варианта)
1. начиная с ssh v7.3
Host bastion
    User appuser
    Hostname 35.195.142.20

Host someinternalhost
    ProxyJump bastion
    User appuser
    Hostname someinternalhost

2.
Host someinternalhost
HostName someinternalhost
User appuser
ProxyCommand ssh -W %h:%p appuser@35.195.142.20

###### How to add let's encrypt certificate to our vpn-server:
- just go to "settings" in our pritunl web interface and add `<bastion-ext-ip>.sslip.io` to "let's encrypt domain" field, then reopen your pritunl web interface in browser using `<bastion-ext-ip>.sslip.io` instead of `<bastion-ext-ip>`
