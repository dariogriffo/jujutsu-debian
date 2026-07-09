#!/bin/bash
set -euo pipefail

jujutsu_VERSION=$1
BUILD_VERSION=$2

if [ -z "$jujutsu_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <jujutsu_version> <build_version>"
    echo "Example: $0 1.2.3 1"
    exit 1
fi

PACKAGE_NAME="jujutsu"

# TODO: implement jujutsu build
#
# This should mirror uv-debian's build_src.sh: download the upstream source
# tarball for https://github.com/jj-vcs/jj, generate a per-distribution debian/changelog,
# and run `dpkg-source -b` for each supported Debian/Ubuntu distribution.
echo "build_src.sh for ${PACKAGE_NAME} is not implemented yet."
exit 1
