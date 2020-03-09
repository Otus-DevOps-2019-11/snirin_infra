# snirin_infra
snirin Infra repository

ДЗ 11 ansible-2

ДЗ 10 ansible-1
После команды ansible app -m command -a 'rm -rf ~/reddit' удаляется католог с репозиторием и выполнение плейбука ansible-playbook clone.yml клонирует его заново

Созданы файлы inventory.json и inventory.sh, последний прописан в ansible.cfg.
Команда ansible all -m ping выполняется успешно

ДЗ 9 terraform-2
Сделано два окружения prod и stage
Добавлены provisioners
State вынесен в backet

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

Проверка
В папке terraform (в ветке из пулреквеста terraform-1) выполнить terraform apply, в проекте должен быть открыт 22 порт для ssh (в новом проекте открыт по умолчанию)
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

Полезное

Импорт созданного правила файервола
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
Для работы с монгой на инстансе
export LC_ALL=C
Список бакетов
gsutil ls
https://console.cloud.google.com/storage

Проверка монги
ssh appuser@34.77.204.59 sudo systemctl status mongod
mongo 34.77.204.59 (Должна быть закомментирована строчка #source_tags = ["reddit-app"] при создании файервола для монги)

nmap -Pn 10.132.0.63   (?)
netstat -plunt
ss -nlp | grep 27017
netstat -apn | grep 27017
sudo lsof -nPi | grep 9292

packer build -var 'project_id=aaaa-123' packer_example.json
packer build -var-file variables.json packer_example.json
packer validate -var 'project_id=aaaa-123' packer_example.json
packer inspect packer_example.json

terraform help
terraform init
terraform plan
terraform apply
terraform destroy
terraform show
terraform output
terraform taint module.db.google_compute_instance.db
terraform fmt -recursive
terraform validate
terraform console
TF_LOG="DEBUG"
TF_LOG_FILE

pip install -r requirements.txt
ansible appserver -i ./inventory -m ping
ansible all -m ping -i inventory.yml
ansible dbserver -m command -a uptime
ansible app -m command -a 'ruby -v'
ansible app -m shell -a 'ruby -v; bundler -v'
ansible db -m command -a 'systemctl status mongod'
ansible db -m systemd -a name=mongod
ansible db -m service -a name=mongod
ansible app -m command -a 'git clone https://github.com/express42/reddit.git /home/appuser/reddit'
ansible app -m command -a 'rm -rf ~/reddit'
ansible-playbook main.yml
ansible-playbook reddit_app.yml --check --limit db
ansible-playbook reddit_app2.yml --tags deploy-tag
ansible-playbook -i path/to/inventories main.yml
ansible-vault --vault-id dev@prompt encrypt --encrypt-vault-id dev secrets.yml
ansible-playbook myplaybook.yml --ask-vault-pass
ansible -m ping localhost -vvvv
ansible-console -l balancer
ANSIBLE_ENABLE_TASK_DEBUGGER=True ansible-playbook -i hosts site.yml
ansible-playbook main.yml --step
