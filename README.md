# dns-servers
# Настройка корпоративного и кэширующего DNS-сервера

Учебный проект по развертыванию инфраструктуры в Yandex Cloud с помощью **Terraform** и настройке DNS-серверов через **Ansible**.

## 🎯 О проекте

Цель проекта — автоматизировать создание и настройку двух DNS-серверов:
1. **Bind9** — авторитетный DNS-сервер (хранит зоны, отвечает на запросы).
2. **Unbound** — кэширующий DNS-сервер (ускоряет повторные запросы).

Проект написан по принципам **Infrastructure as Code (IaC)**. Вся инфраструктура создается и настраивается автоматизированно, без ручного кликания в консоли.

## 🏗️ Что внутри

* **`infrastructure/terraform/`** — код для создания виртуальных машин, сети и групп безопасности в Yandex Cloud.
* **`infrastructure/ansible/`** — роли и плейбуки для установки и настройки Bind9 и Unbound.
* **`.gitignore`** — защита секретов (SSH-ключи, токены, файлы состояния) от попадания в Git.

## 🚀 Быстрый старт

### 1. Клонировать репозиторий
```bash
git clone https://github.com/S6ade/dns-servers.git
cd dns-servers
```

### 2. Развернуть инфраструктуру (Terraform)
```bash
cd infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
# Заполнить terraform.tfvars своими данными (cloud_id, folder_id, ssh_public_key)
terraform init
terraform apply
```

### 3. Настроить серверы (Ansible)
```bash
cd ../ansible
cp inventory.example.ini inventory.ini
# Вписать IP-адреса из вывода Terraform в inventory.ini
ansible-playbook -i inventory.ini playbooks/bind9.yml
ansible-playbook -i inventory.ini playbooks/unbound.yml
```

## 📚 Документация

Подробные инструкции, описание архитектуры и инструкции по troubleshooting находятся в файлах README внутри соответствующих папок:
* [Terraform: создание инфраструктуры](./infrastructure/terraform/README.md)
* [Ansible: настройка DNS-серверов](./infrastructure/ansible/README.md)

## 🛠️ Технологии

* **Yandex Cloud** (облачная платформа)
* **Terraform** (IaC)
* **Ansible** (Configuration Management)
* **Bind9**, **Unbound** (DNS-серверы)
* **Ubuntu 22.04 LTS** (операционная система)
