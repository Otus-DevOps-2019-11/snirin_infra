# snirin_infra
snirin Infra repository


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
