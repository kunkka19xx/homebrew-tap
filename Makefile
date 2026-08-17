.PHONY: help release release-look audit-look

MANIFEST := scripts/look-release.txt

ifneq ($(force),)
FORCE_FLAG := --force
endif

help:
	@printf "Targets:\n"
	@printf "  make release      (uses $(MANIFEST))\n"
	@printf "  make release force=1   (re-release same version, new sha256)\n"
	@printf "  make release-look manifest=/path/release.txt [force=1]\n"
	@printf "  make audit-look\n"

release:
	@./scripts/update-look-cask.sh "$(MANIFEST)" $(FORCE_FLAG)

release-look:
	@if [ -z "$(manifest)" ]; then \
		echo "Error: missing manifest path"; \
		echo "Usage: make release-look manifest=/path/release.txt"; \
		exit 1; \
	fi
	@./scripts/update-look-cask.sh "$(manifest)" $(FORCE_FLAG)

audit-look:
	@brew audit --cask --strict Casks/look.rb
