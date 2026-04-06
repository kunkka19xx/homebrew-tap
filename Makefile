.PHONY: help release release-look audit-look

MANIFEST := scripts/look-release.txt

help:
	@printf "Targets:\n"
	@printf "  make release      (uses $(MANIFEST))\n"
	@printf "  make release-look manifest=/path/release.txt\n"
	@printf "  make audit-look\n"

release:
	@./scripts/update-look-cask.sh "$(MANIFEST)"

release-look:
	@if [ -z "$(manifest)" ]; then \
		echo "Error: missing manifest path"; \
		echo "Usage: make release-look manifest=/path/release.txt"; \
		exit 1; \
	fi
	@./scripts/update-look-cask.sh "$(manifest)"

audit-look:
	@brew audit --cask --strict Casks/look.rb
