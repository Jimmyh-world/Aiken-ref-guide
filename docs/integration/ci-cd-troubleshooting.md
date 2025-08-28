# CI/CD Troubleshooting Guide

## 🎯 **Troubleshooting Overview**

This guide provides solutions for common issues encountered with the CI/CD system, including workflow failures, local development problems, and performance issues.

## 🚨 **Common Issues and Solutions**

### **1. Workflow Failures**

#### **Issue: Aiken Installation Fails**
**Error**: `error: could not find 'aiken' in registry 'crates-io' with version '=1.1.15'`

**Solution**:
```bash
# Check available Aiken versions
cargo search aiken --limit 10

# Install a compatible version
cargo install aiken --version 1.1.15 --locked

# Or install latest if specific version unavailable
cargo install aiken --locked
```

**Prevention**: Update the workflow to use available versions:
```yaml
# In .github/workflows/_reusable-aiken-check.yml
- name: Install Aiken
  run: |
    # Try specific version, fallback to latest
    if cargo install aiken --version ${{ inputs.aiken_version }} --locked 2>/dev/null; then
      echo "Installed specific version: $(aiken --version)"
    else
      echo "Specific version not available, installing latest..."
      cargo install aiken --locked
      echo "Installed latest version: $(aiken --version)"
    fi
```

#### **Issue: Rust Version Compatibility**
**Error**: `requires rustc 1.86.0 or newer, while the currently active rustc version is 1.83.0`

**Solution**:
```bash
# Update Rust toolchain
rustup update

# Or install specific version
rustup install 1.86.0
rustup default 1.86.0
```

**Prevention**: Use compatible Aiken versions:
```yaml
# Use versions compatible with current Rust
aiken: ['1.1.14', '1.1.15']  # Compatible with Rust 1.83.0+
```

#### **Issue: Workflow Not Triggering**
**Problem**: Workflows don't run when pushing changes

**Solution**:
1. **Check Branch Configuration**:
   ```yaml
   # Ensure workflows run on all branches
   on:
     push:  # No branch restrictions
     pull_request:
       branches: [main]
   ```

2. **Verify Path Triggers**:
   ```yaml
   # Check if your changes match the path patterns
   on:
     pull_request:
       paths:
         - 'examples/**'  # Your changes should match this pattern
   ```

3. **Check Workflow File Syntax**:
   ```bash
   # Validate YAML syntax
   yamllint .github/workflows/*.yml
   ```

### **2. Local Development Issues**

#### **Issue: Local Script Fails**
**Error**: `./scripts/ci/local-check.sh: Permission denied`

**Solution**:
```bash
# Make script executable
chmod +x scripts/ci/local-check.sh

# Verify permissions
ls -la scripts/ci/local-check.sh
```

#### **Issue: Aiken Commands Not Found**
**Error**: `command not found: aiken`

**Solution**:
```bash
# Install Aiken
cargo install aiken --locked

# Add to PATH if needed
export PATH="$HOME/.cargo/bin:$PATH"

# Verify installation
aiken --version
```

#### **Issue: Format Check Fails**
**Error**: `I found some files with incorrectly formatted source code`

**Solution**:
```bash
# Format all files
aiken fmt

# Check specific directory
cd examples/hello-world
aiken fmt

# Verify formatting
aiken fmt --check
```

#### **Issue: Tests Fail Locally**
**Error**: `Static analysis or tests failed`

**Solution**:
1. **Check Aiken Version**:
   ```bash
   aiken --version
   # Ensure you're using a compatible version
   ```

2. **Run Individual Checks**:
   ```bash
   # Check formatting
   aiken fmt --check
   
   # Run static analysis
   aiken check
   
   # Run tests only
   aiken check  # Tests are included in check
   ```

3. **Check for Warnings**:
   ```bash
   # Look for specific warnings in output
   aiken check 2>&1 | grep -i warning
   ```

### **3. Performance Issues**

#### **Issue: Slow Workflow Execution**
**Problem**: Workflows taking longer than expected

**Solutions**:

1. **Optimize Caching**:
   ```yaml
   - uses: actions/cache@v4
     with:
       path: |
         ~/.cargo/bin
         ~/.cargo/registry
         ~/.cargo/git
         target
       key: ${{ runner.os }}-cargo-${{ inputs.aiken_version }}-${{ hashFiles('**/Cargo.lock') }}
       restore-keys: |
         ${{ runner.os }}-cargo-${{ inputs.aiken_version }}-
         ${{ runner.os }}-cargo-
   ```

2. **Enable Parallel Execution**:
   ```yaml
   strategy:
     fail-fast: false  # Allow parallel jobs to continue
     matrix:
       aiken: ['1.1.14', '1.1.15']
       example: [...]
   ```

3. **Optimize Dependencies**:
   ```bash
   # Use --locked for faster installation
   cargo install aiken --version 1.1.15 --locked
   ```

#### **Issue: High Resource Usage**
**Problem**: Workflows consuming too much memory/CPU

**Solutions**:

1. **Limit Concurrent Jobs**:
   ```yaml
   concurrency:
     group: ci-examples-${{ github.ref }}
     cancel-in-progress: true  # Cancel redundant runs
   ```

2. **Optimize Matrix Size**:
   ```yaml
   # Reduce matrix combinations if needed
   matrix:
     aiken: ['1.1.15']  # Test fewer versions
     example: ['hello-world']  # Test fewer examples
   ```

### **4. Documentation Issues**

#### **Issue: Markdown Linting Fails**
**Error**: Multiple markdown linting violations

**Solutions**:

1. **Update Configuration**:
   ```json
   // .markdownlint.json
   {
     "line-length": false,
     "no-duplicate-heading": false,
     "no-bare-urls": false,
     "fenced-code-language": false,
     "blanks-around-fences": false,
     "blanks-around-headings": false,
     "blanks-around-lists": false
   }
   ```

2. **Fix Common Issues**:
   ```bash
   # Install markdownlint locally
   npm install -g markdownlint-cli2
   
   # Check specific files
   markdownlint-cli2 "**/*.md"
   
   # Auto-fix where possible
   markdownlint-cli2 "**/*.md" --fix
   ```

#### **Issue: Link Validation Fails**
**Error**: External links returning 404 or timeout

**Solutions**:

1. **Check Link Configuration**:
   ```yaml
   - name: Check Links
     uses: lycheeverse/lychee-action@v1
     with:
       args: --no-progress --exclude-mail --require-https --timeout 20 --max-retries 3 **/*.md
   ```

2. **Update Broken Links**:
   ```bash
   # Find broken links
   lychee --no-progress **/*.md
   
   # Update links in documentation
   # Replace broken URLs with working alternatives
   ```

### **5. Matrix Testing Issues**

#### **Issue: Matrix Job Failures**
**Problem**: Some matrix combinations fail while others pass

**Solutions**:

1. **Check Version Compatibility**:
   ```yaml
   # Ensure all versions are compatible
   matrix:
     aiken: ['1.1.14', '1.1.15']  # Test both versions
     example:
       - { name: 'hello-world', path: 'examples/hello-world' }
       - { name: 'nft-one-shot', path: 'examples/token-contracts/nft-one-shot' }
   ```

2. **Debug Specific Jobs**:
   ```bash
   # Test specific combination locally
   ./scripts/ci/local-check.sh examples/hello-world 1.1.14
   ./scripts/ci/local-check.sh examples/hello-world 1.1.15
   ```

3. **Check Job Logs**:
   ```bash
   # View specific job logs
   gh run view --job=<job-id>
   
   # Download artifacts
   gh run download <run-id>
   ```

## 🔍 **Debugging Techniques**

### **1. Local Reproduction**

```bash
# Reproduce CI environment locally
docker run --rm -it -v $(pwd):/workspace -w /workspace ubuntu:latest

# Install dependencies
apt update && apt install -y curl build-essential
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
cargo install aiken --version 1.1.15 --locked

# Run the same commands as CI
./scripts/ci/local-check.sh examples/hello-world 1.1.15
```

### **2. Workflow Debugging**

```yaml
# Add debug information to workflows
- name: Debug Information
  run: |
    echo "Working Directory: ${{ inputs.working_directory }}"
    echo "Aiken Version: ${{ inputs.aiken_version }}"
    echo "Runner OS: ${{ runner.os }}"
    echo "Available Commands:"
    which aiken || echo "Aiken not found"
    aiken --version || echo "Aiken version check failed"
```

### **3. Artifact Analysis**

```bash
# Download and analyze artifacts
gh run download <run-id>

# Check specific log files
cat logs-*/check.log
cat logs-*/test.log
cat logs-*/fmt.log
```

## 📊 **Monitoring and Prevention**

### **1. Performance Monitoring**

```yaml
# Add performance tracking
- name: Performance Summary
  run: |
    echo "## 📊 Performance Summary" >> $GITHUB_STEP_SUMMARY
    echo "- **Execution Time**: ${{ steps.timer.outputs.duration }}" >> $GITHUB_STEP_SUMMARY
    echo "- **Cache Hit**: ${{ steps.cache.outputs.cache-hit }}" >> $GITHUB_STEP_SUMMARY
```

### **2. Error Tracking**

```yaml
# Track common errors
- name: Error Analysis
  if: failure()
  run: |
    echo "## 🚨 Error Analysis" >> $GITHUB_STEP_SUMMARY
    if grep -q "aiken.*not found" check.log; then
      echo "- **Issue**: Aiken installation failed" >> $GITHUB_STEP_SUMMARY
      echo "- **Solution**: Check version compatibility" >> $GITHUB_STEP_SUMMARY
    fi
```

### **3. Preventive Measures**

1. **Regular Testing**:
   ```bash
   # Test all examples regularly
   for example in examples/*/; do
     ./scripts/ci/local-check.sh "$example" 1.1.15
   done
   ```

2. **Version Compatibility**:
   ```bash
   # Test new Aiken versions before updating
   cargo install aiken --version <new-version> --locked
   ./scripts/ci/local-check.sh examples/hello-world <new-version>
   ```

3. **Documentation Updates**:
   ```bash
   # Keep documentation current
   markdownlint-cli2 "**/*.md"
   lychee --no-progress **/*.md
   ```

## 🔗 **Related Documentation**

- **[CI/CD Overview](../integration/ci-cd-overview.md)**: System overview and architecture
- **[Implementation Guide](../integration/ci-cd-implementation.md)**: Detailed implementation information
- **[Local Development Guide](../integration/local-development.md)**: Setting up development environment
- **[Performance Optimization](../performance/ci-cd-optimization.md)**: Advanced optimization techniques

## 🎯 **Getting Help**

### **When to Seek Additional Help**

- **Persistent Failures**: Issues that persist after trying solutions above
- **Performance Problems**: Workflows consistently slow or resource-intensive
- **New Error Types**: Unfamiliar error messages not covered in this guide
- **Integration Issues**: Problems with external tools or services

### **Where to Get Help**

1. **Repository Issues**: Create an issue with detailed error information
2. **GitHub Actions**: Check GitHub Actions documentation
3. **Aiken Community**: Consult Aiken documentation and community
4. **Stack Overflow**: Search for similar issues and solutions

### **Information to Include**

When reporting issues, include:
- **Error Messages**: Complete error output
- **Environment**: OS, Aiken version, Rust version
- **Steps to Reproduce**: Exact commands and sequence
- **Expected vs Actual**: What you expected vs what happened
- **Workaround Attempts**: Solutions you've already tried

---

**Next Steps**: 
- Read the [Implementation Guide](../integration/ci-cd-implementation.md) for detailed setup
- Review [Performance Optimization](../performance/ci-cd-optimization.md) for advanced techniques
- Check [Local Development Guide](../integration/local-development.md) for setup instructions
