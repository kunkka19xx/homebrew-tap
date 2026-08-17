#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/fetch-look-release.sh [options]

Options:
  --repo <owner/repo>   Source repository (default: kunkka19xx/look)
  --version <x.y.z>     Fetch this version instead of the latest release
  --out <path>          Manifest output path (default: scripts/look-release.txt)
  -h, --help            Show this help

What this script does:
  1) Resolves the latest published release of the source repo (or --version).
  2) Downloads the release's Look-<version>-manifest.txt asset.
  3) Falls back to the macOS zip's recorded sha256 if no manifest asset exists.
  4) Writes a validated manifest to --out for update-look-cask.sh to consume.

Auth:
  Uses `gh` when available, otherwise curl. Set GITHUB_TOKEN to raise the
  anonymous API rate limit or to read a private repository.
EOF
}

repo="kunkka19xx/look"
version=""
out=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --repo) repo="${2:-}"; shift 2 ;;
    --version) version="${2:-}"; shift 2 ;;
    --out) out="${2:-}"; shift 2 ;;
    *) echo "Error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${out:-$repo_root/scripts/look-release.txt}"

if [[ -z "$repo" ]]; then
  echo "Error: --repo requires a value" >&2
  exit 1
fi

have_gh=0
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  have_gh=1
fi

api() {
  local path="$1"
  if [[ "$have_gh" -eq 1 ]]; then
    gh api "$path"
  else
    local -a curl_args=(-fsSL -H "Accept: application/vnd.github+json")
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
      curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    curl "${curl_args[@]}" "https://api.github.com/${path}"
  fi
}

if [[ -n "$version" ]]; then
  version="${version#v}"
  release_path="repos/${repo}/releases/tags/v${version}"
else
  release_path="repos/${repo}/releases/latest"
fi

if ! release_json="$(api "$release_path")"; then
  echo "Error: unable to read release from ${repo} (${release_path})" >&2
  exit 1
fi

# tag, manifest asset url, zip asset url, zip digest
read -r tag manifest_url zip_url zip_digest < <(
  RELEASE_JSON="$release_json" ruby -rjson -e '
    data = JSON.parse(ENV.fetch("RELEASE_JSON"))
    tag = data["tag_name"].to_s
    version = tag.sub(/\A[vV]/, "")
    assets = data["assets"] || []
    manifest = assets.find { |a| a["name"] == "Look-#{version}-manifest.txt" }
    zip = assets.find { |a| a["name"] == "Look-#{version}-macOS.zip" }
    digest = zip && zip["digest"].to_s.sub(/\Asha256:/, "")
    puts [tag, manifest&.fetch("url", nil) || "-", zip&.fetch("url", nil) || "-", (digest.nil? || digest.empty?) ? "-" : digest].join(" ")
  '
)

if [[ -z "$tag" ]]; then
  echo "Error: release payload had no tag_name" >&2
  exit 1
fi

resolved_version="${tag#v}"
resolved_version="${resolved_version#V}"
artifact="Look-${resolved_version}-macOS.zip"

if [[ "$zip_url" == "-" ]]; then
  echo "Error: release ${tag} has no ${artifact} asset" >&2
  exit 1
fi

download_asset() {
  local asset_api_url="$1"
  if [[ "$have_gh" -eq 1 ]]; then
    gh api -H "Accept: application/octet-stream" "$asset_api_url"
  else
    local -a curl_args=(-fsSL -H "Accept: application/octet-stream")
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
      curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    curl "${curl_args[@]}" "$asset_api_url"
  fi
}

sha256=""
source_note=""

if [[ "$manifest_url" != "-" ]]; then
  manifest_body="$(download_asset "$manifest_url")"
  sha256="$(printf '%s\n' "$manifest_body" | ruby -ne 'if $_ =~ /^\s*sha256\s*=\s*([0-9a-fA-F]{64})\s*$/; puts $1.downcase; exit; end')"
  manifest_version="$(printf '%s\n' "$manifest_body" | ruby -ne 'if $_ =~ /^\s*version\s*=\s*(\S+)\s*$/; puts $1; exit; end')"
  if [[ -n "$manifest_version" && "$manifest_version" != "$resolved_version" ]]; then
    echo "Error: manifest version ($manifest_version) does not match release tag ($tag)" >&2
    exit 1
  fi
  source_note="release manifest asset"
fi

if [[ -z "$sha256" && "$zip_digest" != "-" ]]; then
  sha256="$(printf '%s' "$zip_digest" | tr '[:upper:]' '[:lower:]')"
  source_note="release asset digest"
fi

if [[ -z "$sha256" ]]; then
  echo "Downloading ${artifact} to compute sha256..." >&2
  tmp_zip="$(mktemp -t look-release)"
  trap 'rm -f "$tmp_zip"' EXIT
  download_asset "$zip_url" > "$tmp_zip"
  sha256="$(shasum -a 256 "$tmp_zip" | awk '{print $1}')"
  source_note="computed from downloaded zip"
fi

if [[ ! "$sha256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Error: resolved sha256 is not a 64-character lowercase hex string: $sha256" >&2
  exit 1
fi

tmp_out="$(mktemp -t look-manifest)"
cat > "$tmp_out" <<EOF
version=${resolved_version}
artifact=${artifact}
sha256=${sha256}
EOF
mv "$tmp_out" "$out"

echo "Fetched ${repo} ${tag} (sha256 source: ${source_note})"
echo "Wrote ${out#${repo_root}/}:"
echo "  version=${resolved_version}"
echo "  artifact=${artifact}"
echo "  sha256=${sha256}"

main_cask="$repo_root/Casks/look.rb"
if [[ -f "$main_cask" ]]; then
  current_version="$(ruby -ne 'if $_ =~ /^\s*version\s+"([^"]+)"/; puts $1; exit; end' "$main_cask")"
  if [[ "$current_version" == "$resolved_version" ]]; then
    echo "Note: Casks/look.rb is already at ${resolved_version} (use force=1 to re-release)."
  else
    echo "Cask update: ${current_version} -> ${resolved_version}"
  fi
fi
