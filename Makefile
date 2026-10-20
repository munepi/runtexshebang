##DONOT use TEXMFDIST if you are not a distributor.
TLTEXMF=${DESTDIR}$(shell kpsewhich --var-value=TEXMFLOCAL)
TLBINDIR=${DESTDIR}$(shell which texlua | sed s,/texlua,,)

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help
	@grep -E '^[-_a-zA-Z0-9]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all
all:
	@grep -E "^[-_A-Za-z0-9]+:" $(MAKEFILE_LIST) | \
		sed -e "s,:.*,," | sort

.PHONY: test
test: ## Test runtexshebang.lua
	texlua test/run.lua

.PHONY: install
install: runtexshebang.pdf ## Install runtexshebang
	mkdir -p ${TLTEXMF}/scripts/runtexshebang/
	mkdir -p ${TLTEXMF}/doc/support/runtexshebang/
	cp -a runtexshebang.lua ${TLTEXMF}/scripts/runtexshebang/
	cp -a README.md LICENSE runtexshebang.pdf ${TLTEXMF}/doc/support/runtexshebang/

	cd ${TLBINDIR}/ && \
		ln -f -s ${TLTEXMF}/scripts/runtexshebang/runtexshebang.lua runtexshebang

.PHONY: uninstall
uninstall: ## Unistall runtexshebang
	rm -rf ${TLTEXMF}/scripts/runtexshebang/
	rm -rf ${TLTEXMF}/doc/support/runtexshebang/
	rm -f ${TLBINDIR}/runtexshebang

.PHONY: clean
clean: ## Clean this repository
	find . -type f -name '*~' -delete
	rm -rf test/tmp
	rm -rf runtexshebang.zip runtexshebang runtexshebang.pdf

.PHONY: ctanzip
ctanzip: runtexshebang.zip ## Archive for CTAN upload
runtexshebang.zip: clean test runtexshebang.pdf
	git archive --format=tar --prefix=runtexshebang/ HEAD | gtar -x
	rm -f runtexshebang/.gitignore runtexshebang/Makefile runtexshebang/ctan.toml
	rm -rf runtexshebang/test
	cp runtexshebang.pdf runtexshebang/
	zip -9 -r runtexshebang.zip runtexshebang/*
	rm -rf runtexshebang

.PHONY: doc
doc: runtexshebang.pdf ## Build the PDF documentation from README.md (needs pandoc and lualatex)
runtexshebang.pdf: README.md
	pandoc $< -o $@ --pdf-engine=lualatex --shift-heading-level-by=-1 \
		-V CJKmainfont=HaranoAjiMincho -V geometry:margin=25mm -V colorlinks=true \
		-V 'header-includes=\usepackage{fvextra}\AtBeginDocument{\DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,commandchars=\\\{\}}}\ltjsetparameter{jacharrange={-9}}'
