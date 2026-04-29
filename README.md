### Hexlet tests and linter status:
[![Actions Status](https://github.com/kova05b/devops-engineer-from-scratch-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/kova05b/devops-engineer-from-scratch-project-77/actions)

## DevOps Проект 77

### Что разворачивается (Задание 2)

- 2 виртуальные машины с Nginx (`project-77-web-1`, `project-77-web-2`)
- HTTPS Application Load Balancer перед виртуальными машинами
- Удаленный Terraform state в существующем бакете Yandex Object Storage `projectdevopsdeploy`
- Переиспользуются существующие сетевые ресурсы:
  - `project-devops-deploy-net`
  - `project-devops-deploy-subnet`
- Переиспользуется существующий сертификат Certificate Manager (`certificate_id`)

Приложение в этом задании простое (статическая страница Nginx), поэтому Managed PostgreSQL не требуется.

### Структура проекта

- `terraform/` - Terraform-файлы инфраструктуры
- `ansible/` - Ansible и Vault-файлы
- `Makefile` - часто используемые Terraform-команды

### Быстрый запуск

1) Подготовьте переменные:

- Скопируйте `terraform/terraform.tfvars.example` в `terraform/terraform.tfvars`
- Заполните реальные значения (`yc_token`, ID облака/каталога, SSH-ключ)
- При необходимости задайте `certificate_id` (по умолчанию используется существующий сертификат)

2) Инициализация и проверка:

```bash
make init
make fmt
make validate
```

3) Создание инфраструктуры:

```bash
make plan
make apply
make output
```

4) Проверка:

- Получите IP балансировщика из `make output` (`https_url`)
- Откройте `https://<alb_ip>` в браузере (предупреждение о self-signed сертификате — ожидаемо)
- Обновите страницу несколько раз: в ответе должно меняться имя VM

5) Удаление инфраструктуры:

```bash
make destroy
```

### Примечания про backend и секреты

- Конфигурация провайдера: `terraform/provider.tf`
- Конфигурация backend: `terraform/backend.tf`
- Секреты передаются снаружи (`terraform.tfvars`, переменные окружения, vault)
- Локальные state-файлы не попадают в git

## Деплой Ansible (Задание 3)

### Что добавлено

- Основной плейбук: `ansible/playbook.yml`
- Требуемые коллекции: `ansible/requirements.yml`
- Инвентори: `ansible/inventory.ini` (генерируется из Terraform outputs)
- `web-2` подключается по SSH через `web-1` (ProxyJump), потому что `web-2` без публичного IP
- Теги в плейбуке:
  - `prepare` — установка Docker и зависимостей
  - `deploy` — запуск контейнера через `community.general.docker_container`

### Команды Makefile для Ansible

```bash
make ansible-install
make ansible-inventory
make ansible-ping
make ansible-prepare
make ansible-deploy
```

По умолчанию используется SSH-ключ `/home/administrator/.ssh/id_ed25519` (переменная `ANSIBLE_SSH_KEY` в `Makefile`).

### Порядок деплоя

```bash
# 1. Поднять инфраструктуру Terraform
make apply

# 2. Установить коллекции Ansible
make ansible-install

# 3. Сгенерировать inventory из terraform output
make ansible-inventory

# 4. Проверить доступность хостов
make ansible-ping

# 5. Подготовить серверы и задеплоить приложение
make ansible-prepare
make ansible-deploy
```