# Система доменных имен

DNS-лаборатория с полным циклом разрешения доменных имен. Реализация инфраструктуры, имитирующая классическую иерархию, начиная с корневого сервера, и заканчивая доменными записями. Проект разработан для демонстрации понимания принципов системной инженерии, компьютерных сетей и ключевых DevOps концепций : IaC, Observability и т.д.

## Архитектура

### Слой 1 : Облачная инфраструктура : Terraform

Изолированная сеть с политиками безопасности по zero-trust

- **VPC** : сеть, подсеть, шлюз и таблица маршрутизации
- **Security Groups** : SSH-доступ `bastion`, DNS-серверы `core`, ELK-стек `elasticsearch`
- **VMs** :
  - `dns-ins-bastion` : SSH-шлюз
  - `dns-ins-root` : корневой сервер зоны `.`
  - `dns-ins-top-level-domain` : TLD-сервер зоны `domain`
  - `dns-ins-authoritative-{a,b}` : авторитативные серверы зоны `subdomain.domain` : *master/slave*
  - `dns-ins-recursor` : рекурсивный кеширующий резолвер
  - `dns-ins-stub` : хост с нагрузочным Docker-контейнером : *Go скрипт*
  - `dns-ins-elk` : ELK-стек : *Logstash, Elasticsearch, Kibana*

### Слой 2 : Система доменных имен : Ansible + Bind9

Ansible-плейбуки, выполняющие идемпотентное развертывание системы доменных имен

- **Иерархия и делегирование** :
  - `root` -> `domain.` -> `tldd`
  - `tldd` -> `subdomain.domain.` -> `au_a`/`au_b`
  - `au_a`/`au_b` -> конечные записи : *A, AAAA*

### Слой 3 : Мониторинг : ELK + Vector

- **Сбор логов** : Vector-агент на каждом узле DNS-инфраструктуры, собирающий логи Bind9
- **Агрегация и визуализация** : Docker Compose стек на хосте `elko` : *Logstash, Elasticsearch, Kibana*

### Слой 4 : Тестирование : Go

Кастомный скрипт, выполняющий роль stub-резолвера

- **Назначение** : генерация реалистичного DNS-трафика для тестирования инфраструктуры
- **Особенности** :
  - Переменный список доменов
  - Переменная нагрузка : случайное число запросов и временные интервалы

## Технологии и навыки

| Категория | Технологии/Инструменты | Навыки |
| :-- | :-- | :-- |
| **Cloud & IaC** | Yandex Cloud, Yandex Provider, Terraform | Программное определение инфраструктуры, работа с VPC, Security Groups, автоматическая генерация ключей |
| **Configuration Management** | Ansible, Jinja2 | Идемпотентная настройка распределённых систем, работа с шаблонами, управление сервисами |
| **Monitoring & Observability** | ELK Stack (Elasticsearch, Logstash, Kibana), Vector | Централизованный сбор и анализ логов, настройка пайплайнов данных, парсинг текстовых записей, визуализация метрик |
| **Networking & DNS** | BIND9 (авторитативный/рекурсивный), DNS-протокол (UDP/TCP)| Понимание архитектуры DNS : зон, делегирования, рекурсивного и авторитативного резолвинга |
| **Containers & Development** | Docker, Go | Разработка скриптов, контейнеризация, работа с переменными окружения |
| **Automation** | Динамический инвентарь Ansible, генерация конфигураций в Terraform | Автоматизация полного цикла развёртывания, интеграция между инструментами |
| **Security** | Security Groups (Zero-Trust), SSH-ключи (Ed25519), изоляция сети, бастион хост | Безопасность облачной инфраструктуры, принцип минимальных привилегий |

## Развертывание

```bash
git clone git@github.com:andrew-dibov/infra-dns.git
cd infra-dns

mkdir .auth
cat > ./terraform/terraform.tfvars << EOF
yc__cloud_id = "$(yc config get cloud-id)"
yc__folder_id = "$(yc config get folder-id)"
yc__zone_id = "$(yc config get zone)"
EOF

yc iam key create --service-account-name terraform-sa --output ./terraform/auth.terraform.json

cd terraform
terraform init
terraform apply

cd ../ansible
ansible all -m ping
ansible-playbook playbooks/infra-*
ansible-playbook playbooks/elk-*
```