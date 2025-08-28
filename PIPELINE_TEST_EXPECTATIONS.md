# CI/CD Pipeline Test Expectations

## 🚀 **What to Expect on GitHub Actions**

### **Triggered Workflows**

When you push to `feat/ci-cd-optimization`, you should see these workflows:

1. **CI – Core** ✅
   - **Trigger**: Documentation and script changes
   - **Purpose**: Validate repository structure
   - **Expected**: Quick validation of docs and scripts

2. **CI – Examples** ✅
   - **Trigger**: Example directory changes
   - **Purpose**: Matrix testing across Aiken versions
   - **Expected**: 4 parallel jobs (2 examples × 2 versions)

3. **Docs** ✅
   - **Trigger**: Markdown file changes
   - **Purpose**: Documentation quality checks
   - **Expected**: Markdown linting and link validation

### **Expected Job Matrix**

```
CI – Examples:
├── hello-world (Aiken 1.1.14) ✅
├── hello-world (Aiken 1.1.15) ✅
├── nft-one-shot (Aiken 1.1.14) ✅
└── nft-one-shot (Aiken 1.1.15) ✅
```

### **Performance Expectations**

- **Total Time**: 4-6 minutes (vs 8-12 minutes before)
- **Parallel Jobs**: Up to 4 concurrent executions
- **Efficiency**: 60-80% time reduction

## 🔍 **What to Monitor**

### **Success Indicators**
- ✅ All workflows complete successfully
- ✅ Matrix jobs run in parallel
- ✅ Examples pass on both Aiken versions
- ✅ Documentation validation passes
- ✅ No formatting or linting errors

### **Potential Issues to Watch**
- ⚠️ Aiken version compatibility
- ⚠️ Rust toolchain setup
- ⚠️ Cache hit/miss rates
- ⚠️ Parallel execution efficiency

## 📊 **Key Metrics to Track**

### **Execution Time**
- **Before**: 8-12 minutes sequential
- **Target**: 4-6 minutes parallel
- **Actual**: [Monitor in Actions]

### **Success Rate**
- **Target**: 100% workflow success
- **Actual**: [Monitor in Actions]

### **Parallel Efficiency**
- **Target**: 4 concurrent jobs
- **Actual**: [Monitor in Actions]

## 🛠️ **Troubleshooting**

### **If Workflows Fail**

1. **Check Aiken Installation**
   ```bash
   # Verify version compatibility
   cargo install aiken --version 1.1.15 --locked
   ```

2. **Test Locally**
   ```bash
   # Test specific example
   ./scripts/ci/local-check.sh examples/hello-world 1.1.15
   ```

3. **Check Logs**
   - Review workflow artifacts
   - Check for version compatibility issues
   - Verify path triggers

### **Common Issues**

- **Rust Version**: Ensure Rust 1.83.0+ compatibility
- **Aiken Versions**: Verify 1.1.14 and 1.1.15 availability
- **Path Triggers**: Check workflow trigger conditions
- **Cache Issues**: Clear GitHub Actions cache if needed

## 🎯 **Success Criteria**

### **Ready for Merge to Main**
- [ ] All workflows pass consistently
- [ ] Performance targets met (4-6 minutes)
- [ ] Parallel execution working
- [ ] No critical errors or warnings
- [ ] Documentation validation clean

### **Post-Merge Monitoring**
- [ ] Monitor performance in production
- [ ] Track success rates
- [ ] Optimize based on real usage
- [ ] Add performance benchmarks

## 📈 **Next Steps After Testing**

1. **If Successful**: Merge to main branch
2. **If Issues Found**: Fix and re-test
3. **Performance Review**: Analyze execution times
4. **Optimization**: Implement additional improvements

---

**Status**: 🧪 **Testing in Progress** - Monitor GitHub Actions for results
