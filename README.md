# magento2-gitlab-ci

Docker image for Magento 2 GitLab CI/CD jobs (PHP CLI). Includes common PHP extensions, Composer, Deployer, PHP_CodeSniffer, and Node.js.

Default target: **PHP 8.4** with **APCu** (`apc.enable_cli=1`), **pcov**, and **Node 22**.

## Included tools

| Tool | Default version (build arg) |
|------|-----------------------------|
| PHP | `8.4` (`PHP_VERSION`) |
| Node.js | `22` (`NODE_VERSION`) |
| Composer | `latest-2.2.x` (`COMPOSER_VERSION`) |
| Deployer | `v7.5.12` (`DEPLOYER_VERSION`) |
| PHP_CodeSniffer | `3.7.2` (`PHPCS_VERSION`) |

Notable PHP extensions: `pdo_mysql`, `ftp`, `soap`, `xsl`, `intl`, `gd`, `zip`, `sockets`, `amqp`, `apcu`, `pcov`, `pcntl`, `gmp`, `bcmath`.

## Build arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `PHP_VERSION` | `8.4` | Official `php:{version}-cli` base image |
| `NODE_VERSION` | `22` | NodeSource major version (`setup_{version}.x`) |
| `COMPOSER_VERSION` | `latest-2.2.x` | Composer phar release path segment |
| `DEPLOYER_VERSION` | `v7.5.12` | Deployer release tag |
| `PHPCS_VERSION` | `3.7.2` | PHP_CodeSniffer release tag |

## Build and push

Log in to Docker Hub (or your registry), then build for `linux/amd64` and push:

```bash
docker buildx build \
  --platform linux/amd64 \
  --push \
  --build-arg PHP_VERSION=8.4 \
  --build-arg NODE_VERSION=22 \
  --build-arg COMPOSER_VERSION=latest-2.2.x \
  --build-arg DEPLOYER_VERSION=v7.5.12 \
  --build-arg PHPCS_VERSION=3.7.2 \
  -t innobyte/magento2-gitlab-ci:8.4-deployer7.x \
  .
```

Using Dockerfile defaults only:

```bash
docker buildx build \
  --platform linux/amd64 \
  --push \
  -t innobyte/magento2-gitlab-ci:8.4-deployer7.x \
  .
```

## Local build (no push)

```bash
docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg PHP_VERSION=8.4 \
  --build-arg NODE_VERSION=22 \
  -t innobyte/magento2-gitlab-ci:8.4-deployer7.x \
  .
```

## Verify

```bash
docker run --rm innobyte/magento2-gitlab-ci:8.4-deployer7.x php -m | grep -iE 'apcu|pcov'
docker run --rm innobyte/magento2-gitlab-ci:8.4-deployer7.x node --version
docker run --rm innobyte/magento2-gitlab-ci:8.4-deployer7.x npm --version
```
