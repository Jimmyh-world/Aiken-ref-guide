# Hello World Validator Makefile
# Provides easy commands for building, testing, and deploying

.PHONY: help build test clean check format lock unlock all

# Default target
help:
	@echo "Hello World Validator - Available Commands:"
	@echo ""
	@echo "  build    - Build the validator and generate plutus.json"
	@echo "  test     - Run all tests"
	@echo "  check    - Check code for errors and warnings"
	@echo "  format   - Format code with aiken fmt"
	@echo "  clean    - Clean build artifacts"
	@echo "  lock     - Lock tADA to the validator (requires cardano-cli)"
	@echo "  unlock   - Spend from the validator (requires cardano-cli)"
	@echo "  all      - Build, test, and check everything"
	@echo "  help     - Show this help message"

# Build the validator
build:
	@echo "🔨 Building Hello World Validator..."
	./scripts/build.sh

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
	rm -f datum.hash
	rm -f script.addr
	rm -f redeemer.hash

# Lock tADA to validator
lock:
	@echo "🔒 Locking tADA to validator..."
	./scripts/lock.sh

# Unlock from validator
unlock:
	@echo "🔓 Unlocking from validator..."
	./scripts/unlock.sh

# Build, test, and check everything
all: clean build test check
	@echo "✅ All tasks completed successfully!"

# Install dependencies (if needed)
install:
	@echo "📦 Checking Aiken installation..."
	@if ! command -v aiken &> /dev/null; then \
		echo "❌ Aiken not found. Installing..."; \
		curl -sSfL https://aiken-lang.org/install.sh | sh; \
	else \
		echo "✅ Aiken already installed: $(aiken --version)"; \
	fi

# Show project status
status:
	@echo "📊 Hello World Validator Status:"
	@echo "  Aiken version: $(shell aiken --version 2>/dev/null || echo 'Not installed')"
	@echo "  Build artifacts: $(shell if [ -f plutus.json ]; then echo '✅ Present'; else echo '❌ Missing'; fi)"
	@echo "  Tests: $(shell if aiken test >/dev/null 2>&1; then echo '✅ Passing'; else echo '❌ Failing'; fi)"
