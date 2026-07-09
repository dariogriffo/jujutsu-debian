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

# Function to map Debian architecture to jujutsu release name
get_jujutsu_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "jj-v${jujutsu_VERSION}-x86_64-unknown-linux-musl"
            ;;
        "arm64")
            echo "jj-v${jujutsu_VERSION}-aarch64-unknown-linux-musl"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local jujutsu_release

    jujutsu_release=$(get_jujutsu_release "$build_arch")
    if [ -z "$jujutsu_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $jujutsu_release"

    # Clean up any previous builds for this architecture
    rm -rf "$jujutsu_release" || true
    rm -f "${jujutsu_release}.tar.gz" || true

    # Download and extract jujutsu release for this architecture
    if ! wget "https://github.com/jj-vcs/jj/releases/download/v${jujutsu_VERSION}/${jujutsu_release}.tar.gz"; then
        echo "❌ Failed to download jujutsu release for $build_arch"
        return 1
    fi

    mkdir -p "$jujutsu_release"
    if ! tar -xf "${jujutsu_release}.tar.gz" -C "$jujutsu_release"; then
        echo "❌ Failed to extract jujutsu release for $build_arch"
        return 1
    fi

    rm -f "${jujutsu_release}.tar.gz"

    # Build packages for supported Debian distributions
    declare -a arr=("bookworm" "trixie" "forky" "sid")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$jujutsu_VERSION-${BUILD_VERSION}+${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "jujutsu-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg jujutsu_VERSION="$jujutsu_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg JUJUTSU_RELEASE="$jujutsu_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "jujutsu-$dist-$build_arch")"
        if ! docker cp "$id:/jujutsu_$FULL_VERSION.deb" - > "./jujutsu_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./jujutsu_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$jujutsu_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building jujutsu $jujutsu_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la jujutsu_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
