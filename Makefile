##DONOT use TEXMFDIST if you are not a distributor.
TLTEXMF=${DESTDIR}$(shell kpsewhich --var-value=TEXMFLOCAL)
TLBINDIR=${DESTDIR}$(shell which texlua | sed s,/texlua,,)

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all
all: test
	# @egrep -h "^[-_A-z0-9]*:" Makefile | \
	# 	sed -e "s,:.*,," | sort

.PHONY: test
test: ## Test runtexshebang.lua
	test/shebang_matched.bash
	test/shebang_not_found.bash

.PHONY: install uninstall
install: ## Install runtexshebang
	mkdir -p ${TLTEXMF}/scripts/runtexshebang/
	mkdir -p ${TLTEXMF}/doc/support/runtexshebang/
	cp -a runtexshebang.lua ${TLTEXMF}/scripts/runtexshebang/
	cp -a README.md LICENSE ${TLTEXMF}/doc/support/runtexshebang/

	cd ${TLBINDIR}/ && \
		ln -f -s ${TLTEXMF}/scripts/runtexshebang/runtexshebang.lua runtexshebang

uninstall: ## Unnstall runtexshebang
	rm -rf ${TLTEXMF}/scripts/runtexshebang/
	rm -rf ${TLTEXMF}/doc/support/runtexshebang/
	rm -f ${TLBINDIR}/runtexshebang
