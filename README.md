# Система доменных имен

DNS-песочница с полным циклом разрешения имен. Реализация инфраструктуры, имитирующая классическую иерархию от корневого сервера до доменных записей. Проект создан для демонстрации понимания инженерных принципов, компьютерных сетей и ключевых DevOps концепций.

## Архитектура

### Слой 1 : Облачная инфраструктура : Terraform

Изолированная сеть с политиками безопасности

- **VPC** : сеть, подсеть, шлюз и таблица маршрутизации
- **Security Groups** :
  - `core` : DNS-серверы
  - `bastion` : SSH-доступ
  - `elasticsearch` : ELK-стек
- **VMs** :
  - `dns-ins-bastion` : SSH-шлюз
  - `dns-ins-root` : корневой сервер зоны `.`
  - `dns-ins-top-level-domain` : TLD-сервер зоны `domain`
  - `dns-ins-authoritative-{a,b}` : авторитативные серверы зоны `subdomain.domain` : master/slave
  - `dns-ins-recursor` : рекурсивный кеширующий резолвер
  - `dns-ins-stub` : хост с нагрузочным Docker-контейнером : Go-скрипт
  - `dns-ins-elk` : ELK-стек : Logstash, Elasticsearch, Kibana

### Слой 2 : Система доменных имен : Ansible + Bind9

Ansible-плейбуки, выполняющие идемпотентное развертывание

- **Иерархия и делегирование** :
  - `root` -> `domain.` -> `tldd`
  - `tldd` -> `subdomain.domain.` -> `au_a`/`au_b`
  - `au_a`/`au_b` -> конечные записи

### Слой 3 : Мониторинг : ELK + Vector

- **Сбор логов** : Vector-агент на каждом узле, собирающий логи Bind9
- **Агрегация и визуализация** : Docker Compose : Logstash, Elasticsearch, Kibana

### Слой 4 : Тестирование : Go

Кастомный скрипт в роли stub-резолвера

- **Назначение** : генерация DNS-трафика для тестирования
- **Особенности** :
  - Переменный список доменов
  - Переменная нагрузка : случайные временные интервалы и количество запросов

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
# скопировать и перейти
git clone https://github.com/andrew-dibov/infra-dns.git && cd infra-dns

# создать директорию под ssh-ключи
mkdir .auth

# добавить переменные
cat > ./terraform/terraform.tfvars << EOF
yc__cloud_id  = "$(yc config get cloud-id)"
yc__folder_id = "$(yc config get folder-id)"
yc__zone_id   = "ru-central1-a"
EOF

# сгенерировать ключ сервисного аккаунта
yc iam key create --service-account-name terraform-sa --output ./terraform/auth.terraform.json

# установить соответствующую версию ansible
pip install -r ./ansible/requirements.txt

# инициализировать и применить terraform
(cd terraform && terraform init)
(cd terraform && terraform apply)

# проверить доступность и применить ansible
(cd ansible && ansible all -m ping)
(cd ansible && ansible-playbook playbooks/infra-*)
(cd ansible && ansible-playbook playbooks/elk-*)
```