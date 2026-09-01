#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
swiftlint_bin="${SWIFTLINT_BIN:-swiftlint}"
scheme="${SWIFTLINT_ANALYZE_SCHEME:-SwiftyVK_macOS}"
destination="${SWIFTLINT_ANALYZE_DESTINATION:-platform=macOS}"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/swiftyvk-swiftlint-analyze.XXXXXX")"
compiler_log="$work_dir/xcodebuild.log"

cleanup() {
    rm -rf "$work_dir"
}
trap cleanup EXIT

if ! command -v "$swiftlint_bin" >/dev/null 2>&1; then
    echo "error: swiftlint is not installed" >&2
    exit 1
fi

cp "$repo_root/.swiftlint.yml" "$work_dir/.swiftlint.yml"
cp -R "$repo_root/Library" "$work_dir/Library"

if ! xcodebuild \
    -project "$work_dir/Library/SwiftyVK.xcodeproj" \
    -scheme "$scheme" \
    -configuration Debug \
    -destination "$destination" \
    -derivedDataPath "$work_dir/DerivedData" \
    build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY= \
    > "$compiler_log" 2>&1; then
    cat "$compiler_log" >&2
    exit 1
fi

"$swiftlint_bin" analyze \
    --quiet \
    --config "$work_dir/.swiftlint.yml" \
    --compiler-log-path "$compiler_log"
