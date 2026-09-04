#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Rewrites Formula/lgtm.rb from a kunkka19xx/lgtm release.
#
# The checksums come from the release's own SHA256SUMS asset, which the release
# workflow generates from the tarballs it just built. Nothing here recomputes a
# hash from a local build: a formula's sha256 is a claim about the file a user
# will download, and only the published file can support it.

set -euo pipefail

repo="kunkka19xx/lgtm"
version=""
formula="$(cd "$(dirname "$0")/.." && pwd)/Formula/lgtm.rb"

usage() {
  cat <<'USAGE'
Usage: scripts/update-lgtm-formula.sh [--version x.y.z] [--repo owner/repo]

Resolves the latest lgtm release (or --version), reads its SHA256SUMS, and
writes Formula/lgtm.rb. Needs `gh` or a GITHUB_TOKEN for the API.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --repo) repo="${2:?--repo needs owner/repo}"; shift 2 ;;
    --version) version="${2:?--version needs x.y.z}"; shift 2 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$version" ]]; then
  version="$(gh release view --repo "$repo" --json tagName --jq '.tagName')"
  version="${version#v}"
fi
tag="v${version}"

sums="$(mktemp)"
trap 'rm -f "$sums"' EXIT
gh release download "$tag" --repo "$repo" --pattern SHA256SUMS --output "$sums" --clobber

# `sha256sum` writes "<hash>  ./<file>"; take the hash for one target, and fail
# loudly when a target is missing rather than writing a zeroed formula.
sha_for() {
  local want="$1" line
  line="$(grep -E "lgtm-${want}\.tar\.gz\$" "$sums" || true)"
  [[ -n "$line" ]] || { echo "no checksum for $want in SHA256SUMS" >&2; exit 1; }
  awk '{print $1}' <<<"$line"
}

mac_arm="$(sha_for aarch64-macos)"
mac_x86="$(sha_for x86_64-macos)"
lin_arm="$(sha_for aarch64-linux)"
lin_x86="$(sha_for x86_64-linux)"

tmp="$(mktemp)"
trap 'rm -f "$sums" "$tmp"' EXIT

# Rewritten by matching what is *there*, not a placeholder, so this runs on
# every release rather than only the first: the version and the four checksums
# it wrote last time are exactly what it has to replace next time.
#
# Each sha256 is found through the url above it and keyed on the target in the
# filename, so the four are never paired by position - adding a fifth target to
# the formula needs no change here beyond naming it.
python3 - "$formula" "$tmp" "$version" "$tag" <<'PY_END' \
  aarch64-macos="$mac_arm" x86_64-macos="$mac_x86" \
  aarch64-linux="$lin_arm" x86_64-linux="$lin_x86"
import re, sys

formula, out, version, tag = sys.argv[1:5]
sums = dict(a.split("=", 1) for a in sys.argv[5:])
text = open(formula).read()

text = re.sub(r'(^\s*version\s+)"[^"]*"', rf'\g<1>"{version}"', text, count=1, flags=re.M)
text = re.sub(r'(releases/download/)v[^/]+/', rf'\g<1>{tag}/', text)

seen = set()
def pair(m):
    target = m.group("target")
    if target not in sums:
        sys.exit(f"formula names a target the release has no checksum for: {target}")
    seen.add(target)
    return m.group("head") + f'"{sums[target]}"'

text, n = re.subn(
    r'(?P<head>url\s+"[^"]*lgtm-(?P<target>[^"/]+)\.tar\.gz"\s*\n\s*sha256\s+)"[^"]*"',
    pair, text)

missing = set(sums) - seen
if missing:
    sys.exit("formula has no url for: " + ", ".join(sorted(missing)))
if n != len(sums):
    sys.exit(f"rewrote {n} checksums, expected {len(sums)}")

open(out, "w").write(text)
PY_END

# `install -m` rather than `mv`: the temp file carries mktemp's 0600, and a
# formula that is not world-readable is an offence `brew style` fails on.
install -m 644 "$tmp" "$formula"
echo "wrote $formula for $tag"
grep -E 'version |sha256 ' "$formula"
