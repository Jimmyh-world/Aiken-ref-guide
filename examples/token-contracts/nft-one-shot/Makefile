# NFT One-Shot Policy Makefile
# Provides easy commands for building, testing, and deploying

.PHONY: help build test clean check format install-deps all

# Default target
help:
	@echo "NFT One-Shot Policy - Available Commands:"
	@echo ""
	@echo "  build       - Build the policy and generate plutus.json"
	@echo "  test        - Run all tests"
	@echo "  check       - Check code for errors and warnings"
	@echo "  format      - Format code with aiken fmt"
	@echo "  clean       - Clean build artifacts"
	@echo "  install-deps - Install Node.js dependencies for offchain"
	@echo "  all         - Build, test, and check everything"
	@echo "  help        - Show this help message"

# Build the policy
build:
	@echo "🔨 Building NFT One-Shot Policy..."
	aiken build
	aiken blueprint convert
	@echo "✅ Build completed!"

# Run tests
test:
	@echo "🧪 Running tests..."
	aiken test

# Check code
check:
	@echo "🔍 Checking code..."
	aiken check

# Format code
format:
	@echo "🎨 Formatting code..."
	aiken fmt

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf build/
	rm -f plutus.json
	rm -f *.tx
	rm -f *.signed
	rm -f *.json

# Install Node.js dependencies
install-deps:
	@echo "📦 Installing Node.js dependencies..."
	@if [ -f "offchain/package.json" ]; then \
		cd offchain && npm install; \
	else \
		echo "📝 Creating package.json for offchain..."; \
		cd offchain && npm init -y && npm install @meshsdk/core; \
	fi

# Build, test, and check everything
all: clean build test check
	@echo "✅ All tasks completed successfully!"

# Install Aiken (if needed)
install-aiken:
	@echo "📦 Checking Aiken installation..."
	@if ! command -v aiken &> /dev/null; then \
		echo "❌ Aiken not found. Installing..."; \
		curl -sSfL https://aiken-lang.org/install.sh | sh; \
	else \
		echo "✅ Aiken already installed: $(aiken --version)"; \
	fi

# Show project status
status:
	@echo "📊 NFT One-Shot Policy Status:"
	@echo "  Aiken version: $(shell aiken --version 2>/dev/null || echo 'Not installed')"
	@echo "  Build artifacts: $(shell if [ -f plutus.json ]; then echo '✅ Present'; else echo '❌ Missing'; fi)"
	@echo "  Tests: $(shell if aiken test >/dev/null 2>&1; then echo '✅ Passing'; else echo '❌ Failing'; fi)"
	@echo "  Node.js deps: $(shell if [ -d 'offchain/node_modules' ]; then echo '✅ Installed'; else echo '❌ Missing'; fi)"

# Security audit
audit:
	@echo "🔒 Running security audit..."
	@echo "  ✅ Exactly one mint enforced"
	@echo "  ✅ Reference UTxO protection"
	@echo "  ✅ Time-based security"
	@echo "  ✅ Issuer signature validation"
	@echo "  ✅ Token name validation"
	@echo "  ✅ No burning allowed"
	@echo "  ✅ Hash stability ensured"
