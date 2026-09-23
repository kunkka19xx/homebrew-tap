.PHONY: help style style-lgtm release-lgtm publish-lgtm audit-lgtm

# This repository, as Homebrew names it: homebrew-tap -> kunkka19xx/tap. The
# audit targets need the tap installed (`brew tap $(TAP)`), because they check
# the published formula rather than the file on disk.
TAP := kunkka19xx/tap

ifneq ($(version),)
VERSION_FLAG := --version $(version)
endif

help:
	@printf "Targets:\n"
	@printf "  make release-lgtm      regenerate Formula/lgtm.rb from the latest release\n"
	@printf "  make release-lgtm version=0.1.0   pin a specific release\n"
	@printf "  make release-lgtm push=1          ...and commit + push the tap\n"
	@printf "  make style             brew style, on the working tree\n"
	@printf "  make audit-lgtm        brew audit, on the published tap\n"

# `brew audit` stopped taking a path in Homebrew 6 - "Calling `brew audit
# [path ...]` is disabled" - and only accepts a name inside an installed tap.
# So auditing splits in two: `brew style` still reads the working tree and is
# what to run before pushing, and `brew audit` runs against the tap as
# published, which is what a user will actually install.
style: style-lgtm

style-lgtm:
	@brew style Formula/lgtm.rb

# lgtm is a formula, not a cask: it ships one binary.
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
