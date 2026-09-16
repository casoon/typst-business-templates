#!/bin/bash
# Installation script for docgen CLI
# Usage: curl -fsSL https://raw.githubusercontent.com/casoon/typst-business-templates/main/install.sh | bash

set -e

REPO="casoon/typst-business-templates"
BINARY_NAME="docgen"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Detect OS and architecture
detect_platform() {
    local os arch

    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)

    case "$os" in
        linux)
            case "$arch" in
                x86_64|amd64)
                    echo "x86_64-unknown-linux-gnu"
                    ;;
                aarch64|arm64)
                    echo "aarch64-unknown-linux-gnu"
                    ;;
                *)
                    error "Unsupported architecture: $arch"
                    ;;
            esac
            ;;
        darwin)
            case "$arch" in
                x86_64|amd64)
                    echo "x86_64-apple-darwin"
                    ;;
                aarch64|arm64)
                    echo "aarch64-apple-darwin"
                    ;;
                *)
                    error "Unsupported architecture: $arch"
                    ;;
            esac
            ;;
        *)
            error "Unsupported operating system: $os"
            ;;
    esac
}

# Get latest version from GitHub
get_latest_version() {
    curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Download and install
install() {
    local platform version url tmp_dir expected actual

    platform=$(detect_platform)
    version=$(get_latest_version)

    if [ -z "$version" ]; then
        error "Could not determine latest version"
    fi

    info "Installing $BINARY_NAME $version for $platform"

    url="https://github.com/$REPO/releases/download/$version/docgen-${platform}.tar.gz"

    tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT

    info "Downloading from $url"
    curl -fsSL "$url" -o "$tmp_dir/docgen.tar.gz"

    info "Verifying checksum..."
    curl -fsSL "https://github.com/$REPO/releases/download/$version/checksums.txt" -o "$tmp_dir/checksums.txt"
    expected=$(awk -v asset="docgen-${platform}.tar.gz" '$2 == asset || $2 == "*" asset { print $1 }' "$tmp_dir/checksums.txt")
    if [ -z "$expected" ]; then
        error "No checksum published for docgen-${platform}.tar.gz"
    fi
    if command -v sha256sum &> /dev/null; then
        actual=$(sha256sum "$tmp_dir/docgen.tar.gz" | awk '{ print $1 }')
    elif command -v shasum &> /dev/null; then
        actual=$(shasum -a 256 "$tmp_dir/docgen.tar.gz" | awk '{ print $1 }')
    else
        error "No SHA-256 tool found (sha256sum or shasum)"
    fi
    if [ "$actual" != "$expected" ]; then
        error "Checksum mismatch for docgen-${platform}.tar.gz"
    fi

    info "Extracting..."
    tar -xzf "$tmp_dir/docgen.tar.gz" -C "$tmp_dir"

    # Create install directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    info "Installing to $INSTALL_DIR"
    mv "$tmp_dir/$BINARY_NAME" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    # Check if install dir is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        warn "$INSTALL_DIR is not in your PATH"
        echo ""
        echo "Add the following to your shell profile (.bashrc, .zshrc, etc.):"
        echo ""
        echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
        echo ""
    fi

    info "Successfully installed $BINARY_NAME $version"
    echo ""
    echo "Run 'docgen --help' to get started"
}

# Check dependencies
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        error "curl is required but not installed"
    fi

    if ! command -v tar &> /dev/null; then
        error "tar is required but not installed"
    fi

    # Check for typst (optional but recommended)
    if ! command -v typst &> /dev/null; then
        warn "typst is not installed. docgen requires typst for PDF generation."
        echo "  Install typst: https://github.com/typst/typst#installation"
        echo ""
    fi
}

main() {
    echo ""
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║     docgen CLI Installer              ║"
    echo "  ║     Business Document Generator       ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo ""

    check_dependencies
    install
}

main "$@"
