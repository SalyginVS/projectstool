up: docker-up
down: docker-down
restart: docker-down docker-up
init: docker-down-clear projectstool-clear docker-pull docker-build docker-up projectstool-init projectstool-init
test: projectstool-test

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

projectstool-init: projectstool-composer-install projectstool-assets-install projectstool-wait-db projectstool-migrations projectstool-fixtures projectstool-ready

projectstool-clear:
	docker run --rm -v ${PWD}/projectstool:/app --workdir=/app alpine rm -f .ready

projectstool-composer-install:
	docker-compose run --rm projectstool-php-cli composer install

projectstool-assets-install:
	docker-compose run --rm projectstool-node yarn install

projectstool-wait-db:
	until docker-compose exec -T projectstool-postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done

projectstool-migrations:
	docker-compose run --rm projectstool-php-cli php bin/console doctrine:migrations:migrate --no-interaction

projectstool-fixtures:
	docker-compose run --rm projectstool-php-cli php bin/console doctrine:fixtures:load --no-interaction

projectstool-ready:
	docker run --rm -v ${PWD}/projectstool:/app --workdir=/app alpine touch .ready

projectstool-assets-dev:
	docker-compose run --rm projectstool-node npm run dev

projectstool-test:
	docker-compose run --rm projectstool-php-cli php bin/phpunit

build-production:
	docker build --pull --file=projectstool/docker/production/nginx.docker --tag ${REGISTRY_ADDRESS}/projectstool-nginx:${IMAGE_TAG} projectstool
	docker build --pull --file=projectstool/docker/production/php-fpm.docker --tag ${REGISTRY_ADDRESS}/projectstool-php-fpm:${IMAGE_TAG} projectstool
	docker build --pull --file=projectstool/docker/production/php-cli.docker --tag ${REGISTRY_ADDRESS}/projectstool-php-cli:${IMAGE_TAG} projectstool
	docker build --pull --file=projectstool/docker/production/postgres.docker --tag ${REGISTRY_ADDRESS}/projectstool-postgres:${IMAGE_TAG} projectstool

push-production:
	docker push ${REGISTRY_ADDRESS}/projectstool-nginx:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/projectstool-php-fpm:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/projectstool-php-cli:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/projectstool-postgres:${IMAGE_TAG}

deploy-production:
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'rm -rf docker-compose.yml .env'
	scp -o StrictHostKeyChecking=no -P ${PRODUCTION_PORT} docker-compose-production.yml ${PRODUCTION_HOST}:docker-compose.yml
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "REGISTRY_ADDRESS=${REGISTRY_ADDRESS}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "IMAGE_TAG=${IMAGE_TAG}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "PROJECTSTOOL_APP_SECRET=${PROJECTSTOOL_APP_SECRET}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "PROJECTSTOOL_DB_PASSWORD=${PROJECTSTOOL_DB_PASSWORD}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "PROJECTSTOOL_OAUTH_FACEBOOK_SECRET=${PROJECTSTOOL_OAUTH_FACEBOOK_SECRET}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose pull'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose --build -d'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'until docker-compose exec -T projectstool-postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose run --rm projectstool-php-cli php bin/console doctrine:migrations:migrate --no-interaction'