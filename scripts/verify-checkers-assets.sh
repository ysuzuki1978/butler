#!/usr/bin/env bash

set -euo pipefail

project_dir=$(cd "$(dirname "$0")/.." && pwd)
asset_dir=${1:-"$project_dir/.tools/device"}

amonet_name=amonet-checkers-v2.0.1.zip
amonet_sha=770324a8ed5ab922c0383f8ba072d70fc0190cc2c879f12f67b8d6cfa3ad30ee
lineage_name=lineage-18.1-20260904-UNOFFICIAL-checkers.zip
lineage_sha=785fa643fd68b2e6f6f02d96a2da58373c6a577b92a27cf6cec69603bb94068e

if command -v sha256sum >/dev/null 2>&1; then
    hash_file() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then
    hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
else
    echo "Error: sha256sum or shasum is required." >&2
    exit 1
fi

verify_file() {
    local name=$1
    local expected=$2
    local path="$asset_dir/$name"

    if [[ ! -f "$path" ]]; then
        echo "Missing: $path" >&2
        return 1
    fi

    local actual
    actual=$(hash_file "$path")
    if [[ "$actual" != "$expected" ]]; then
        echo "SHA-256 mismatch: $name" >&2
        echo "  expected: $expected" >&2
        echo "  actual:   $actual" >&2
        return 1
    fi

    unzip -tq "$path" >/dev/null
    echo "Verified: $name"
}

verify_file "$amonet_name" "$amonet_sha"
verify_file "$lineage_name" "$lineage_sha"

host_os=$(uname -s)
host_arch=$(uname -m)
echo "Host: $host_os $host_arch"

if [[ "$host_os" == "Linux" && "$host_arch" == "x86_64" ]]; then
    echo "Unlock host: compatible with the bundled Linux fastboot binary"
elif [[ "$host_os" == "Darwin" ]]; then
    echo "Unlock host: macOS is not supported by amonet v2.0.1; use an Intel/AMD Windows or Linux host"
else
    echo "Unlock host: verify compatibility; the bundled Linux binaries are x86-64/i386"
fi
