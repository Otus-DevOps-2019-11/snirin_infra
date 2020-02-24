# snirin_infra
snirin Infra repository

ДЗ 8 terraform-1
При редактировании ключей shh в метаданных проекта через google_compute_project_metadata или google_compute_project_metadata_item,
нужно указывать все ключи, которые должны остаться, иначе они будут затерты

Сделано два инстанса и создан балансер в lb.tf через команды
google_compute_http_health_check
google_compute_target_pool
google_compute_forwarding_rule

Добавлены две output переменные
reddit_app_external_ips
reddit_app_load_balancing_ip

Для себя
terraform help
terraform init
terraform plan
terraform apply
terraform destroy
terraform show

Проверка
В папке terraform выполнить terraform apply
И по адресам из reddit_app_external_ip и reddit_app_load_balancing_ip на порту 9292 буде доступно приложение
34.76.137.236:9292

ДЗ 7 packer-base
Создание базового образа
packer build -var-file=variables.json ubuntu16.json
Создание полного образа
PACKER_LOG=1 packer build -var-file=variables.json immutable.json
Деплой приложение из полного образа
packer/config-scripts/create-redditvm.sh
или командой
gcloud compute instances create reddit-app --image-family=reddit-full --tags puma-server --machine-type=g1-small

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
gcloud compute --project=infra-265807 firewall-rules create default-puma-server \
 --direction=INGRESS \
 --priority=1000 \
 --network=default \
 --action=ALLOW \
 --rules=tcp:9292 \
 --source-ranges=0.0.0.0 \
 --target-tags=puma-server

Для проверка перейти по
35.233.127.3:9292

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
