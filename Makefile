.PHONY: help sync release release-look publish audit-look

MANIFEST := scripts/look-release.txt
SOURCE_REPO := kunkka19xx/look

ifneq ($(force),)
FORCE_FLAG := --force
endif

ifneq ($(version),)
VERSION_FLAG := --version $(version)
endif

help:
	@printf "Targets:\n"
	@printf "  make release           fetch latest $(SOURCE_REPO) release, update cask\n"
	@printf "  make release push=1    ...and commit + push the tap\n"
	@printf "  make release version=0.6.12   pin a specific release\n"
	@printf "  make release force=1   re-release same version with a new sha256\n"
	@printf "  make release sync=0    skip the fetch, use $(MANIFEST) as-is\n"
	@printf "  make sync              only refresh $(MANIFEST) from the latest release\n"
	@printf "  make release-look manifest=/path/release.txt [force=1]\n"
	@printf "  make publish           commit + push current cask changes\n"
	@printf "  make audit-look\n"

sync:
	@./scripts/fetch-look-release.sh --repo "$(SOURCE_REPO)" --out "$(MANIFEST)" $(VERSION_FLAG)

release:
ifneq ($(sync),0)
	@$(MAKE) --no-print-directory sync
endif
	@./scripts/update-look-cask.sh "$(MANIFEST)" $(FORCE_FLAG)
ifeq ($(push),1)
	@$(MAKE) --no-print-directory publish
endif

release-look:
	@if [ -z "$(manifest)" ]; then \
		echo "Error: missing manifest path"; \
		echo "Usage: make release-look manifest=/path/release.txt"; \
		exit 1; \
	fi
	@./scripts/update-look-cask.sh "$(manifest)" $(FORCE_FLAG)

publish:
	@set -e; \
	git add Casks "$(MANIFEST)"; \
	if git diff --cached --quiet; then \
		echo "Nothing to publish: no staged changes."; \
	else \
		cask_version=$$(ruby -ne 'if $$_ =~ /^\s*version\s+"([^"]+)"/; puts $$1; exit; end' Casks/look.rb); \
		git commit -m "look $$cask_version"; \
		git push; \
	fi

audit-look:
	@brew audit --cask --strict Casks/look.rb
