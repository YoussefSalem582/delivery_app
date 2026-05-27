#!/usr/bin/env bash
# ============================================================
# check_docs_freshness.sh - Verify that the version in pubspec.yaml
# matches the version mentioned in README.md, CHANGELOG.md (Unreleased
# section), and tech_readme_files/CURRENT_STATUS.md. Unix/macOS
# counterpart to scripts/check_docs_freshness.ps1.
#
# Usage: bash scripts/check_docs_freshness.sh
# CI:    invoked by .github/workflows/docs.yml
# ============================================================

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"

# --- 1. Extract `version: x.y.z+build` from pubspec.yaml ---
pubspec="${REPO_ROOT}/pubspec.yaml"
if [[ ! -f "${pubspec}" ]]; then
    echo "pubspec.yaml not found at ${pubspec}" >&2
    exit 2
fi

version="$( awk '/^version:/ { sub(/^version:[[:space:]]*/, "", $0); print; exit }' "${pubspec}" )"
if [[ -z "${version}" ]]; then
    echo "No \`version:\` line found in pubspec.yaml" >&2
    exit 2
fi

printf 'pubspec.yaml version: %s\n' "${version}"

# --- 2. Helpers ---
status_ok=0
status_fail=0

# Escape regex special chars (+ . etc.) for grep.
escape_regex() {
    printf '%s' "$1" | sed -e 's/[]\/$*.^[]/\\&/g' -e 's/+/\\+/g'
}
re_version="$( escape_regex "${version}" )"

check_file_contains() {
    local label="$1"
    local path="$2"
    if [[ ! -f "${path}" ]]; then
        printf '  [%-5s] %s (path: %s)\n' 'MISS' "${label}" "${path}"
        status_fail=$(( status_fail + 1 ))
        return
    fi
    if grep -Eq "${re_version}" "${path}"; then
        printf '  [%-5s] %s\n' 'OK' "${label}"
        status_ok=$(( status_ok + 1 ))
    else
        printf '  [%-5s] %s (path: %s)\n' 'DRIFT' "${label}" "${path}"
        status_fail=$(( status_fail + 1 ))
    fi
}

check_changelog_unreleased() {
    local path="${REPO_ROOT}/CHANGELOG.md"
    if [[ ! -f "${path}" ]]; then
        printf '  [%-5s] CHANGELOG.md (missing)\n' 'MISS'
        status_fail=$(( status_fail + 1 ))
        return
    fi
    # Extract everything between the [Unreleased] heading and the next ## heading.
    local body
    body="$( awk '
        /^##[[:space:]]*\[Unreleased\]/ { in_section = 1; next }
        in_section && /^##[[:space:]]/  { in_section = 0 }
        in_section { print }
    ' "${path}" )"

    if [[ -z "${body// /}" ]]; then
        printf '  [%-5s] CHANGELOG [Unreleased] section is empty or missing\n' 'EMPTY'
        status_fail=$(( status_fail + 1 ))
        return
    fi

    if printf '%s' "${body}" | grep -Eq "${re_version}"; then
        printf '  [%-5s] CHANGELOG [Unreleased] mentions %s\n' 'OK' "${version}"
        status_ok=$(( status_ok + 1 ))
    else
        printf '  [%-5s] CHANGELOG [Unreleased] does not mention %s (warning, not fatal)\n' 'WARN' "${version}"
        # warnings do NOT fail the check
    fi
}

# --- 3. Run the checks ---
check_file_contains 'README.md'         "${REPO_ROOT}/README.md"
check_file_contains 'CURRENT_STATUS.md' "${REPO_ROOT}/tech_readme_files/CURRENT_STATUS.md"
check_changelog_unreleased

echo
if [[ ${status_fail} -gt 0 ]]; then
    printf 'Docs are stale relative to pubspec.yaml (%s).\n' "${version}" >&2
    echo 'Fix README.md, CHANGELOG.md, and CURRENT_STATUS.md to reflect the current version, then re-run.' >&2
    exit 1
fi

printf 'All docs reference pubspec.yaml version %s.\n' "${version}"
exit 0
