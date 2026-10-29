#!/bin/bash
#
# bump-version.sh — version/build bumper (build-setting source of truth)
#
# Edits MARKETING_VERSION (CFBundleShortVersionString) and
# CURRENT_PROJECT_VERSION (CFBundleVersion) directly in project.pbxproj.
# Build settings are the SINGLE source of truth; both Info.plists omit these
# keys and let GENERATE_INFOPLIST_FILE inject them. Do not put literal
# versions back in the plists.
#
# Run MANUALLY before archiving — never from a build phase (rewriting
# project.pbxproj mid-build causes rebuild loops).
#
# Usage:
#   Scripts/bump-version.sh                    # increment build number by 1
#   Scripts/bump-version.sh 300                # set build number to exactly 300
#   Scripts/bump-version.sh --marketing 2.3.0  # set marketing version to 2.3.0
#
set -euo pipefail

# --- Locate project ---------------------------------------------------------
cd "$(dirname "$0")/.."
XCODEPROJ="$(find . -maxdepth 1 -name '*.xcodeproj' | head -1)"
if [ -z "$XCODEPROJ" ]; then
    echo "error: no .xcodeproj found in $(pwd)" >&2
    exit 1
fi
PROJECT="$XCODEPROJ/project.pbxproj"

if [ ! -f "$PROJECT" ]; then
    echo "error: $PROJECT not found" >&2
    exit 1
fi

# --- Helpers ----------------------------------------------------------------

# Replace every "<ws>KEY = <value>;" with the new value across the pbxproj.
# Leading-whitespace anchor avoids clobbering similarly-suffixed settings
# (e.g. DYLIB_CURRENT_VERSION).
set_build_setting() {
    local key="$1" value="$2"
    /usr/bin/sed -i '' -E "s/([[:space:]])${key} = [^;]*;/\1${key} = ${value};/g" "$PROJECT"
}

# Largest integer currently assigned to a build setting (for increment mode).
# Trailing "|| true" keeps pipefail from aborting when there are no matches.
max_build_setting() {
    local key="$1"
    /usr/bin/grep -Eo "([[:space:]])${key} = [0-9]+;" "$PROJECT" 2>/dev/null \
        | /usr/bin/grep -Eo '[0-9]+' \
        | /usr/bin/sort -n \
        | /usr/bin/tail -1 || true
}

# Confirm the pbxproj still parses; restore the backup if the edit broke it.
lint_or_restore() {
    if ! /usr/bin/plutil -lint "$PROJECT" >/dev/null; then
        echo "error: project.pbxproj failed to parse after edit — restoring backup" >&2
        /bin/mv "${PROJECT}.bak" "$PROJECT"
        exit 1
    fi
    /bin/rm -f "${PROJECT}.bak"
}

# Always edit against a backup so a bad write can't corrupt the project.
/bin/cp "$PROJECT" "${PROJECT}.bak"

# --- Modes ------------------------------------------------------------------
if [ "${1:-}" = "--marketing" ]; then
    if [ -z "${2:-}" ]; then
        echo "error: --marketing requires a version string, e.g. --marketing 2.3.0" >&2
        /bin/rm -f "${PROJECT}.bak"
        exit 1
    fi
    set_build_setting "MARKETING_VERSION" "$2"
    lint_or_restore
    echo "Marketing version (MARKETING_VERSION / CFBundleShortVersionString) set to $2"

elif [ -n "${1:-}" ]; then
    set_build_setting "CURRENT_PROJECT_VERSION" "$1"
    lint_or_restore
    echo "Build number (CURRENT_PROJECT_VERSION / CFBundleVersion) set to $1"

else
    current="$(max_build_setting "CURRENT_PROJECT_VERSION")"
    if [ -z "$current" ]; then
        echo "error: no numeric CURRENT_PROJECT_VERSION found to increment" >&2
        /bin/rm -f "${PROJECT}.bak"
        exit 1
    fi
    next=$((current + 1))
    set_build_setting "CURRENT_PROJECT_VERSION" "$next"
    lint_or_restore
    echo "Build number (CURRENT_PROJECT_VERSION / CFBundleVersion) incremented: ${current} -> ${next}"
fi
