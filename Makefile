include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	docker compose up -d postgres

env-down:
	docker compose down postgres

env-port-forward:
	@docker compose up port-forward-postgres

env-port-close:
	@docker compose down port-forward-postgres

env-cleanup:
	@read -p "Are you sure to cleanup ? [y/n]" ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down && \
		rm -rf out/pgdata && \
		echo "Files cleaned up"; \
	else \
		echo "Cleanup stopped"; \
	fi

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Migrate seq is not provided. Example: make migrate-create seq=init" && \
		exit 1; \
	fi; \
	docker compose run --rm postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)";


migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Action is not provided. Example: make migrate-action action=up 1" && \
		exit 1; \
	fi; \
	docker compose run --rm postgres-migrate \
		-path /migrations \
		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable" \
		"$(action)"

migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

test-target:
	@echo "valueeee $(val)"
