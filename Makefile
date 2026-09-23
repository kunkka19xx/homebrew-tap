.PHONY: help sync release release-look prune-look publish audit-look \
        style style-look style-lgtm \
        release-lgtm publish-lgtm audit-lgtm

MANIFEST := scripts/look-release.txt
SOURCE_REPO := kunkka19xx/look

# This repository, as Homebrew names it: homebrew-tap -> kunkka19xx/tap. The
# audit targets need the tap installed (`brew tap $(TAP)`), because they check
# the published formula rather than the file on disk.
TAP := kunkka19xx/tap

ifneq ($(force),)
FORCE_FLAG := --force
endif

ifneq ($(version),)
VERSION_FLAG := --version $(version)
endif

# How many look@<version> casks to keep besides look.rb (4 + look.rb = 5 versions);
# older ones are deleted on each release.
keep ?= 4
KEEP_FLAG := --keep $(keep)

help:
	@printf "Targets:\n"
	@printf "  make release           fetch latest $(SOURCE_REPO) release, update cask\n"
	@printf "  make release push=1    ...and commit + push the tap\n"
	@printf "  make release version=0.6.12   pin a specific release\n"
	@printf "  make release force=1   re-release same version with a new sha256\n"
	@printf "  make release sync=0    skip the fetch, use $(MANIFEST) as-is\n"
	@printf "  make release keep=3    keep 3 look@<version> casks instead of 4\n"
	@printf "  make prune-look [keep=N]      only prune old look@<version> casks\n"
	@printf "  make sync              only refresh $(MANIFEST) from the latest release\n"
	@printf "  make release-look manifest=/path/release.txt [force=1]\n"
	@printf "  make publish           commit + push current cask changes\n"
	@printf "  make style             brew style both, on the working tree\n"
	@printf "  make audit-look        brew audit look, on the published tap\n"
	@printf "\n"
	@printf "  make release-lgtm      regenerate Formula/lgtm.rb from the latest release\n"
	@printf "  make release-lgtm version=0.1.0   pin a specific release\n"
	@printf "  make release-lgtm push=1          ...and commit + push the tap\n"
	@printf "  make style-lgtm        brew style, on the working tree\n"
	@printf "  make audit-lgtm        brew audit, on the published tap\n"

sync:
	@./scripts/fetch-look-release.sh --repo "$(SOURCE_REPO)" --out "$(MANIFEST)" $(VERSION_FLAG)

release:
ifneq ($(sync),0)
	@$(MAKE) --no-print-directory sync
endif
	@./scripts/update-look-cask.sh "$(MANIFEST)" $(FORCE_FLAG) $(KEEP_FLAG)
ifeq ($(push),1)
	@$(MAKE) --no-print-directory publish
endif

release-look:
	@if [ -z "$(manifest)" ]; then \
		echo "Error: missing manifest path"; \
		echo "Usage: make release-look manifest=/path/release.txt"; \
		exit 1; \
	fi
	@./scripts/update-look-cask.sh "$(manifest)" $(FORCE_FLAG) $(KEEP_FLAG)

prune-look:
	@./scripts/update-look-cask.sh --prune $(KEEP_FLAG)

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

# `brew audit` stopped taking a path in Homebrew 6 - "Calling `brew audit
# [path ...]` is disabled" - and only accepts a name inside an installed tap.
# So auditing splits in two: `brew style` still reads the working tree and is
# what to run before pushing, and `brew audit` runs against the tap as
# published, which is what a user will actually install.
style: style-look style-lgtm

style-look:
	@brew style Casks/look.rb

style-lgtm:
	@brew style Formula/lgtm.rb

audit-look:
	@brew audit --cask --strict $(TAP)/look

# lgtm is a formula, not a cask: `look` ships a .app, `lgtm` ships one binary.
# Its checksums come from the release's own SHA256SUMS - the same file
# `install.sh` and the AUR package verify against, so all three agree by
# construction rather than by three people copying a hash correctly.
release-lgtm:
	@./scripts/update-lgtm-formula.sh $(VERSION_FLAG)
ifeq ($(push),1)
	@$(MAKE) --no-print-directory publish-lgtm
endif

publish-lgtm:
	@set -e; \
	git add Formula/lgtm.rb; \
	if git diff --cached --quiet; then \
		echo "Nothing to publish: no staged changes."; \
	else \
		v=$$(ruby -ne 'if $$_ =~ %r{/download/v([^/]+)/}; puts $$1; exit; end' Formula/lgtm.rb); \
		git commit -m "lgtm $$v"; \
		git push; \
	fi

audit-lgtm:
	@brew audit --formula --strict $(TAP)/lgtm
