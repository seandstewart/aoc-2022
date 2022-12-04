SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

DOCKER_RUN ?= docker compose run -it --rm

init: install storage  ## Install all dependencies and spin up the storage backend.

install:  ## Install the project and its dependencies.
	brew install scarvalhojr/tap/aoc-cli
	curl -sSL https://install.python-poetry.org | python3 -
	poetry install
.PHONY: install


storage:  ## Spin up the storage backend.
	docker compose up --build -d
.PHONY: storage

nuke-storage:
	docker compose down -v --rmi all
	docker volume rm aoc-2022_database
.PHONY: nuke-storage

migrate-up:  ## Run any pending migrations.
	$(DOCKER_RUN) aoc-migrations deploy
.PHONY: migrate-up

migrate-down:  ## Rever any modified migrations so we can re-apply them.
	$(DOCKER_RUN) aoc-migrations revert --modified
.PHONY: migrate-down


name ?=
comment ?=
require ?=

new-migration:  ## Make a new migration. Required Arguments: `name=<name>`, `comment=<comment>`, `require=<require>`
	$(DOCKER_RUN) aoc-migrations add $(name) --require $(require) -m $(comment)
.PHONY: new-migration


day ?= 1
part ?= 1

puzzle:  ## Get the puzzle for the targeted day. Arguments: `day=<day|1>`, `part=<part|1>`.
	cp -R "day/.template" "day/$(day)"
	chmod +x "day/$(day)/solve.py"
	git add "day/$(day)/"
	aoc download --day=$(day) --input-file="day/$(day)/input" --overwrite
	aoc read --day=$(day) --puzzle-file="day/$(day)/puzzle.md" --width=88 --overwrite
.PHONY: puzzle


solve: storage  ## Run the solution for the targeted day. Arguments: `day=<day|1>`
	./day/$(day)/solve.py
.PHONY: solve

help: ## Display this help screen.
	@printf "\n$(ITALIC)$(GREEN)Supported Commands: $(RESET)\n"
	@grep -E '^[a-zA-Z0-9._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(CYAN)$(MSGPREFIX) %-$(MAX_CHARS)s$(RESET) $(ITALIC)$(DIM)%s$(RESET)\n", $$1, $$2}'

.PHONY: help
.DEFAULT_GOAL := help

# Messaging
MAX_CHARS ?= 24
BOLD := \033[1m
RESET_BOLD := \033[21m
ITALIC := \033[3m
RESET_ITALIC := \033[23m
DIM := \033[2m
BLINK := \033[5m
RESET_BLINK := \033[25m
RED := \033[1;31m
GREEN := \033[32m
YELLOW := \033[1;33m
MAGENTA := \033[1;35m
CYAN := \033[36m
RESET := \033[0m
MSGPREFIX ?=   »
