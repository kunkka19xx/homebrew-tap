#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/update-look-cask.sh <manifest.txt>

Manifest format:
  version=0.1.7
  artifact=Look-0.1.7-macOS.zip
  sha256=<64-char sha256>

What this script does:
  1) Reads version/artifact/sha256 from the manifest file.
  2) Creates a backup cask from current Casks/look.rb (look@<old_version>.rb).
  3) Updates Casks/look.rb to the new version and sha256.

Notes:
  - Artifact is validated against Look-<version>-macOS.zip.
  - Existing backup casks are included in conflicts_with for the new backup file.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -ne 1 ]]; then
  usage
  exit $(( $# == 1 ? 0 : 1 ))
fi

manifest_file="$1"
if [[ ! -f "$manifest_file" ]]; then
  echo "Error: manifest file not found: $manifest_file" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
casks_dir="$repo_root/Casks"
main_cask="$casks_dir/look.rb"

if [[ ! -f "$main_cask" ]]; then
  echo "Error: missing cask file: $main_cask" >&2
  exit 1
fi

version=""
artifact=""
sha256=""

while IFS='=' read -r raw_key raw_value; do
  key="${raw_key#"${raw_key%%[![:space:]]*}"}"
  key="${key%"${key##*[![:space:]]}"}"
  value="${raw_value#"${raw_value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  case "$key" in
    version) version="$value" ;;
    artifact) artifact="$value" ;;
    sha256) sha256="$value" ;;
    ""|\#*) ;;
    *) ;;
  esac
done < "$manifest_file"

if [[ -z "$version" || -z "$artifact" || -z "$sha256" ]]; then
  echo "Error: manifest must include version, artifact, and sha256" >&2
  exit 1
fi

expected_artifact="Look-${version}-macOS.zip"
if [[ "$artifact" != "$expected_artifact" ]]; then
  echo "Error: artifact mismatch" >&2
  echo "  expected: $expected_artifact" >&2
  echo "  got:      $artifact" >&2
  exit 1
fi

if [[ ! "$sha256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Error: sha256 must be a 64-character lowercase hex string" >&2
  exit 1
fi

current_version="$(ruby -ne 'if $_ =~ /^\s*version\s+"([^"]+)"/; puts $1; exit; end' "$main_cask")"
current_sha256="$(ruby -ne 'if $_ =~ /^\s*sha256\s+"([^"]+)"/; puts $1; exit; end' "$main_cask")"

if [[ -z "$current_version" || -z "$current_sha256" ]]; then
  echo "Error: unable to read current version/sha256 from $main_cask" >&2
  exit 1
fi

if [[ "$version" == "$current_version" ]]; then
  echo "Error: new version matches current version ($current_version)" >&2
  exit 1
fi

backup_cask_name="look@${current_version}"
backup_cask_file="$casks_dir/${backup_cask_name}.rb"

if [[ -f "$backup_cask_file" ]]; then
  echo "Error: backup cask already exists: $backup_cask_file" >&2
  echo "Update manually or remove the file, then re-run." >&2
  exit 1
fi

existing_versioned=()
shopt -s nullglob
for f in "$casks_dir"/look@*.rb; do
  name="$(basename "$f" .rb)"
  existing_versioned+=("$name")
done
shopt -u nullglob

conflicts=("look")
for name in "${existing_versioned[@]}"; do
  conflicts+=("$name")
done
quoted_conflicts=""
for name in "${conflicts[@]}"; do
  if [[ -n "$quoted_conflicts" ]]; then
    quoted_conflicts+=", "
  fi
  quoted_conflicts+="\"$name\""
done

{
  echo "cask \"$backup_cask_name\" do"
  echo "  owner = \"kunkka19xx\""
  echo "  repo = \"look\""
  echo "  app_name = \"Look\""
  echo "  release_tag_prefix = \"v\""
  echo "  release_asset_suffix = \"macOS.zip\""
  echo
  echo "  version \"$current_version\""
  echo "  sha256 \"$current_sha256\""
  echo
  echo "  url \"https://github.com/#{owner}/#{repo}/releases/download/#{release_tag_prefix}#{version}/#{app_name}-#{version}-#{release_asset_suffix}\""
  echo "  name \"look\""
  echo "  desc \"Keyboard-first local launcher for macOS\""
  echo "  homepage \"https://github.com/#{owner}/#{repo}\""
  echo
  echo "  livecheck do"
  echo "    skip \"Versioned cask\""
  echo "  end"
  echo
  echo "  conflicts_with cask: [${quoted_conflicts}]"
  echo "  app \"#{app_name}.app\""
  echo "end"
} > "$backup_cask_file"

ruby - "$main_cask" "$version" "$sha256" <<'RUBY'
path, new_version, new_sha = ARGV
content = File.read(path)
content.sub!(/^\s*version\s+"[^"]+"/, "  version \"#{new_version}\"")
content.sub!(/^\s*sha256\s+"[^"]+"/, "  sha256 \"#{new_sha}\"")
File.write(path, content)
RUBY

echo "Created backup: ${backup_cask_file#${repo_root}/}"
echo "Updated main cask to version ${version}: ${main_cask#${repo_root}/}"
echo
echo "Next steps:"
echo "  brew audit --cask --strict Casks/look.rb"
echo "  git add Casks/look.rb Casks/${backup_cask_name}.rb"
