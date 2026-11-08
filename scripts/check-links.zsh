#!/usr/bin/env zsh
# Offline link validation for this repository.
#
# Checks, without any network access:
#   1. Every external URL in the markdown files is well-formed:
#      http or https only, and the host is not localhost or a
#      private, loopback, link-local, or reserved address.
#   2. Every relative markdown link points at a file that exists.
#   3. Every external URL used in catalog entries also appears in
#      sources.md.
#
# Usage:
#   zsh scripts/check-links.zsh              # check the repo root
#   zsh scripts/check-links.zsh --root DIR   # check another tree
#   zsh scripts/check-links.zsh --self-test  # run the built-in test

set -u

typeset -a problems
typeset -i url_count=0 link_count=0

# Print a problem and record it.
fail() {
  problems+=("$1")
  print -- "FAIL: $1"
}

# True when the host part of a URL is a host we refuse to treat as a
# valid public web address.
bad_host() {
  local host="$1"
  local ip
  host="${host%%:*}"          # strip port
  host="${host%%\]*}"         # strip stray bracket tail
  host="${host#\[}"           # strip leading bracket of IPv6 form
  host="${host%\]*}"
  if [[ "$host" == "localhost" || "$host" == *.local ]]; then
    return 0
  fi
  if [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    local -a oct
    oct=("${(@s.:.)host}")
    if (( oct[1] == 127 || oct[1] == 10 || oct[1] == 0 )); then
      return 0
    fi
    if (( oct[1] == 172 && oct[2] >= 16 && oct[2] <= 31 )); then
      return 0
    fi
    if (( oct[1] == 192 && oct[2] == 168 )); then
      return 0
    fi
    if (( oct[1] == 169 && oct[2] == 254 )); then
      return 0
    fi
  fi
  if [[ "$host" == ::1 || "$host" == fe80* || "$host" == fc* || "$host" == fd* ]]; then
    return 0
  fi
  return 1
}

# Run all checks over the markdown files under $1.
# Returns 0 when clean, 1 when any problem was found.
run_checks() {
  local root="$1"
  problems=()
  url_count=0
  link_count=0

  local -a files
  files=(${(f)"$(find "$root" -name '*.md' -type f | sort)"})
  if (( ${#files} == 0 )); then
    fail "no markdown files found under $root"
    return 1
  fi

  local sources_file="$root/sources.md"
  local sources_body=""
  if [[ -f "$sources_file" ]]; then
    sources_body="$(<"$sources_file")"
  fi

  local file line url target dir base
  for file in "${files[@]}"; do
    dir="${file:h}"
    local trailing_punct='[.,;:!?]$'
    while IFS= read -r line; do
      url="$line"
      # Drop trailing sentence punctuation that the regex may capture.
      while [[ "$url" =~ $trailing_punct ]]; do
        url="${url%?}"
      done
      if [[ -z "$url" ]]; then
        continue
      fi
      url_count=$((url_count + 1))
      if [[ "$url" != http://* && "$url" != https://* ]]; then
        fail "$file: URL must start with http:// or https:// : $url"
        continue
      fi
      local host="${url#*://}"
      host="${host%%/*}"
      host="${host%%\?*}"
      if [[ -z "$host" ]]; then
        fail "$file: URL has no host: $url"
        continue
      fi
      if bad_host "$host"; then
        fail "$file: URL host is not a public web host: $url"
        continue
      fi
      # Rule 3 applies to catalog entries only.
      if [[ "$file" == */catalog/* && -n "$sources_body" ]]; then
        if [[ "$sources_body" != *"$url"* ]]; then
          fail "$file: URL not listed in sources.md: $url"
        fi
      fi
    done < <(grep -oE 'https?://[^) "'"'"'<>]+' "$file" | sort -u)

    # Relative links: [label](target) where target is not external,
    # not an anchor-only link, and not a mailto link.
    while IFS= read -r target; do
      link_count=$((link_count + 1))
      base="${target%%#*}"
      base="${base%%\?*}"
      if [[ -z "$base" ]]; then
        continue
      fi
      if [[ ! -e "$dir/$base" ]]; then
        fail "$file: link target does not exist: $target"
      fi
    done < <(grep -oE '\]\([^)]+\)' "$file" | sed -E 's/^\]\(//; s/\)$//' \
             | grep -vE '^(https?://|mailto:|#)')
  done
  return ${#problems}
}

self_test() {
  local tmp
  tmp="$(mktemp -d)"
  local rc=0
  {
    mkdir -p "$tmp/catalog"
    print -- "# T" > "$tmp/sources.md"
    print -- "ok" > "$tmp/target.md"
    print -- "See [target](../target.md)." > "$tmp/catalog/good.md"
    print -- "- https://example.com/a" >> "$tmp/sources.md"
    print -- "- https://community.n8n.io/t/x/1" >> "$tmp/sources.md"
    print -- "See [target](../target.md) and https://example.com/a." > "$tmp/catalog/also-good.md"
    # Bad file: ftp scheme, localhost host, private IP, missing link target,
    # and a catalog URL missing from sources.md.
    print -- "ftp://example.com/x and http://localhost:5678/webhook" > "$tmp/catalog/bad.md"
    print -- "also https://10.0.0.5/x and [gone](../missing.md)" >> "$tmp/catalog/bad.md"
    print -- "and https://community.n8n.io/t/other/2" >> "$tmp/catalog/bad.md"
  } 2>/dev/null

  local expected_fail expected_pass
  if run_checks "$tmp" > /dev/null 2>&1; then
    print -- "self-test: expected failures not reported"
    rc=1
  fi
  rm -f "$tmp/catalog/bad.md"
  if ! run_checks "$tmp" > /dev/null 2>&1; then
    print -- "self-test: clean fixture reported problems"
    rc=1
  fi
  rm -rf "$tmp"
  if (( rc == 0 )); then
    print -- "self-test: PASS"
  fi
  return $rc
}

main() {
  local root=""
  local mode="check"
  while (( $# > 0 )); do
    case "$1" in
      --root) root="$2"; shift 2 ;;
      --self-test) mode="selftest"; shift ;;
      -h|--help)
        cat <<'USAGE'
Usage: zsh scripts/check-links.zsh [--root DIR] [--self-test]
USAGE
        return 0 ;;
      *) print -- "unknown argument: $1" >&2; return 2 ;;
    esac
  done

  if [[ "$mode" == "selftest" ]]; then
    self_test
    return $?
  fi

  if [[ -z "$root" ]]; then
    root="${0:A:h:h}"
  fi
  if [[ ! -d "$root" ]]; then
    print -- "not a directory: $root" >&2
    return 2
  fi

  if run_checks "$root"; then
    print -- "OK: $url_count unique URLs and $link_count relative links checked, no problems"
    return 0
  fi
  print -- "PROBLEMS FOUND: ${#problems} issue(s)"
  return 1
}

main "$@"
