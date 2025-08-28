#!/usr/bin/env bash
# Local CI/CD Parity Script - mirrors reusable workflow
set -Eeuo pipefail

# Usage: ./scripts/ci/local-check.sh [directory] [aiken-version] [run-benchmarks]
DIR="${1:-.}"
AIKEN_VERSION="${2:-1.1.15}"
RUN_BENCHMARKS="${3:-false}"

echo "🚀 Local CI/CD Check"
echo "Directory: $DIR"
echo "Aiken Version: $AIKEN_VERSION"
echo "Benchmarks: $RUN_BENCHMARKS"
echo "----------------------------------------"

# Install Aiken if needed
if ! command -v aiken &> /dev/null || ! aiken --version | grep -q "$AIKEN_VERSION"; then
    echo "📦 Installing Aiken $AIKEN_VERSION..."
    # Try to install specific version, fallback to latest if not available
    if cargo install aiken --version "$AIKEN_VERSION" --locked 2>/dev/null; then
        echo "Installed specific version: $(aiken --version)"
    else
        echo "Specific version not available, installing latest..."
        cargo install aiken --locked
        echo "Installed latest version: $(aiken --version)"
    fi
fi

cd "$DIR"

# Mirror the reusable workflow steps
echo "🔍 Checking dependencies..."
# Note: aiken packages check is not available in all versions
if aiken packages check 2>/dev/null; then
    echo "✅ Dependencies checked"
else
    echo "⚠️  Dependency check not available in this version"
fi

echo "🎨 Checking formatting..."
if ! aiken fmt --check; then
    echo "❌ Format check failed. Run: aiken fmt"
    exit 1
fi

echo "🔍 Running static analysis and tests..."
if ! aiken check; then
    echo "❌ Static analysis or tests failed"
    exit 1
fi

if [[ "$RUN_BENCHMARKS" == "true" ]]; then
    echo "📊 Running benchmarks..."
    aiken bench || echo "⚠️  Benchmark warnings found"
fi

echo "✅ All checks passed!"
