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
