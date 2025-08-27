#!/bin/bash

# Hello World Validator Build Script
# This script compiles the validator and generates the plutus.json file

set -e

echo "🔨 Building Hello World Validator..."

# Check if Aiken is installed
if ! command -v aiken &> /dev/null; then
    echo "❌ Error: Aiken is not installed. Please install Aiken first."
    echo "   Visit: https://aiken-lang.org/getting-started/installation"
    exit 1
fi

# Check Aiken version
echo "📋 Aiken version: $(aiken --version)"

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf build/
rm -f plutus.json

# Check the code
echo "🔍 Checking code..."
aiken check

# Format the code
echo "🎨 Formatting code..."
aiken fmt

# Build the validator
echo "🏗️ Building validator..."
aiken build

# Generate plutus.json
echo "📄 Generating plutus.json..."
aiken blueprint convert

echo "✅ Build completed successfully!"
echo "📁 Generated files:"
echo "   - build/ (compiled artifacts)"
echo "   - plutus.json (validator script)"

# Display validator hash
if [ -f "plutus.json" ]; then
    echo "🔑 Validator hash: $(jq -r '.validators[0].hash' plutus.json)"
fi
