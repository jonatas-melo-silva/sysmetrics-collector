SHELL := /bin/bash

PREFIX ?= /usr/local
NAME   := sysmetrics-collector
LIBDIR  = $(PREFIX)/lib/$(NAME)

SH_FILES := bin/$(NAME) $(shell find src scripts tests/stubs -type f) tests/test_helper.bash

.DEFAULT_GOAL := help

.PHONY: help
help: ## Lista os comandos
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

.PHONY: lint
lint: ## shellcheck e verificação de formato (shfmt)
	shellcheck $(SH_FILES)
	shfmt -d $(SH_FILES)

.PHONY: fmt
fmt: ## Formata os scripts com shfmt
	shfmt -w $(SH_FILES)

.PHONY: test
test: ## Roda a suíte de testes (bats)
	bats -r tests

.PHONY: check
check: lint test ## lint + test (o mesmo que a CI roda)

.PHONY: install
install: ## Instala em PREFIX (padrão /usr/local) e registra o serviço systemd
	install -d $(DESTDIR)$(LIBDIR) $(DESTDIR)$(PREFIX)/bin $(DESTDIR)/etc/systemd/system
	cp -r bin src VERSION $(DESTDIR)$(LIBDIR)/
	ln -sf $(LIBDIR)/bin/$(NAME) $(DESTDIR)$(PREFIX)/bin/$(NAME)
	sed 's|@PREFIX@|$(PREFIX)|g' packaging/systemd/$(NAME).service.in \
		> $(DESTDIR)/etc/systemd/system/$(NAME).service

.PHONY: uninstall
uninstall: ## Remove o que o install criou
	rm -rf $(DESTDIR)$(LIBDIR)
	rm -f $(DESTDIR)$(PREFIX)/bin/$(NAME) $(DESTDIR)/etc/systemd/system/$(NAME).service

.PHONY: dev-build dev-shell dev-check
dev-build: ## Constrói a imagem de desenvolvimento (podman, ou docker se não houver)
	scripts/dev.sh build

dev-shell: ## Abre um shell no container de desenvolvimento
	scripts/dev.sh shell

dev-check: ## Roda lint + testes dentro do container
	scripts/dev.sh run make check
