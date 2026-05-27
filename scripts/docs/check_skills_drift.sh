#!/usr/bin/env bash
# ============================================================
# check_skills_drift.sh - Verify that every official skill in
# .agents/skills/ matches the SHA-256 folder hash recorded in
# skills-lock.json. Unix/macOS counterpart to
# scripts/check_skills_drift.ps1.
#
# Reproduces the algorithm used by vercel-labs/skills's
# computeSkillFolderHash():
#   for each file in the skill folder (sorted by relative path,
#   forward slashes, excluding .git and node_modules), feed the
#   path bytes and then the content bytes into a single rolling
#   SHA-256. See https://github.com/vercel-labs/skills/blob/main/src/skill-lock.ts
#
# Project-tuned skills (add-feature, add-api, add-language) are
# NOT in skills-lock.json and are skipped.
#
# Usage:
#   bash scripts/check_skills_drift.sh
# CI:
#   invoked by .github/workflows/docs.yml
#
# Requires: bash, awk, jq, openssl, find.
# ============================================================

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"
LOCK="${REPO_ROOT}/skills-lock.json"
SKILLS_DIR="${REPO_ROOT}/.agents/skills"

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required but not installed." >&2
    exit 2
fi

if ! command -v openssl >/dev/null 2>&1; then
    echo "openssl is required but not installed." >&2
    exit 2
fi

if [[ ! -f "${LOCK}" ]]; then
    echo "skills-lock.json not found at ${LOCK}" >&2
    exit 2
fi

# Compute the folder hash for a single skill directory.
compute_skill_hash() {
    local skill_dir="$1"
    # Build a tmpfile of: relative-path bytes ++ file content bytes, in sorted
    # relative-path order. Then SHA-256 the whole stream.
    local tmp
    tmp="$( mktemp )"
    trap 'rm -f "${tmp}"' RETURN

    (
        cd "${skill_dir}"
        # Find all files except .git and node_modules. Print rel paths with
        # forward slashes, sorted lexically.
        find . -type f \
            -not -path '*/.git/*' \
            -not -path '*/node_modules/*' \
            -print | sort
    ) | while IFS= read -r rel; do
        # rel is like "./SKILL.md" — strip the leading "./"
        rel="${rel#./}"
        # Path bytes first
        printf '%s' "${rel}" >> "${tmp}"
        # Then file content bytes
        cat "${skill_dir}/${rel}" >> "${tmp}"
    done

    openssl dgst -sha256 < "${tmp}" | awk '{ print $NF }'
}

ok=0
drift=0
missing=0
total=0

# Iterate over skill names from skills-lock.json
while IFS= read -r name; do
    total=$(( total + 1 ))
    expected="$( jq -r ".skills[\"${name}\"].computedHash" "${LOCK}" )"
    skill_dir="${SKILLS_DIR}/${name}"

    if [[ ! -d "${skill_dir}" ]]; then
        printf '  [%-5s] %s\n' 'MISS' "${name}"
        missing=$(( missing + 1 ))
        continue
    fi

    actual="$( compute_skill_hash "${skill_dir}" )"

    if [[ "${actual}" != "${expected}" ]]; then
        printf '  [%-5s] %s\n' 'DRIFT' "${name}"
        printf '         expected: %s\n' "${expected}"
        printf '         actual:   %s\n' "${actual}"
        drift=$(( drift + 1 ))
    else
        ok=$(( ok + 1 ))
    fi
done < <( jq -r '.skills | keys[]' "${LOCK}" )

echo
printf 'Summary: %d ok / %d drift / %d missing (of %d locked skills)\n' "${ok}" "${drift}" "${missing}" "${total}"

if [[ ${drift} -gt 0 || ${missing} -gt 0 ]]; then
    echo
    echo 'Official skills drifted from skills-lock.json.' >&2
    echo 'To resync from upstream (flutter/skills + dart-lang/skills), run:' >&2
    echo '    npx skills update' >&2
    echo 'If you intended to fork an upstream skill, do not edit it in-place - copy it into a project-tuned folder (sibling of add-feature/) and reference the copy in AGENTS.md.' >&2
    exit 1
fi

echo 'All official skills match skills-lock.json.'
exit 0
