#!/bin/bash
set -euo pipefail

# Upstream Linux architectures for jujutsu (https://github.com/jj-vcs/jj):
#   amd64  -> jj-<version>-x86_64-unknown-linux-musl.tar.gz
#   arm64  -> jj-<version>-aarch64-unknown-linux-musl.tar.gz
#
# amd64 and arm64 only.
# TODO: implement jujutsu build

jujutsu_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$jujutsu_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <jujutsu_version> <build_version> [architecture]"
    echo "Example: $0 1.2.3 1 arm64"
    echo "Example: $0 1.2.3 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

echo "build_debian.sh for jujutsu is not implemented yet."
exit 1
