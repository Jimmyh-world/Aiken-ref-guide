---
title: 'Branch Protection Setup Guide'
description: 'Instructions for setting up GitHub branch protection rules'
tags: [github, branch-protection, ci-cd, governance]
---

# 🛡️ Branch Protection Setup Guide

> **Instructions for setting up GitHub branch protection rules to ensure code quality and security**

## 🎯 **Recommended Branch Protection Rules**

### **For `main` Branch**

Navigate to your repository settings → Branches → Add rule for `main`:

#### **Branch Protection Settings**
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: `1`
  - ✅ Dismiss stale PR approvals when new commits are pushed
  - ✅ Require review from code owners

#### **Status Checks**
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**

**Required Status Checks:**
- `CI – Core`
- `CI – Examples / hello-world (Aiken 1.1.15)`
- `CI – Examples / hello-world (Aiken 1.1.19)`
- `CI – Examples / nft-one-shot (Aiken 1.1.15)`
- `CI – Examples / nft-one-shot (Aiken 1.1.19)`
- `CI – Examples / escrow-contract (Aiken 1.1.15)`
- `CI – Examples / escrow-contract (Aiken 1.1.19)`
- `Docs`

#### **Additional Rules**
- ✅ **Require signed commits** (recommended)
- ✅ **Include administrators** (apply rules to admins)
- ✅ **Allow force pushes**: ❌ Disabled
- ✅ **Allow deletions**: ❌ Disabled

## 🔧 **Setup Instructions**

1. **Navigate to Repository Settings**
   ```
   Your Repository → Settings → Branches
   ```

2. **Add Branch Protection Rule**
   ```
   Click "Add rule" → Enter "main" as branch name pattern
   ```

3. **Configure Protection Settings**
   - Enable all recommended settings above
   - Add all required status checks
   - Save the rule

4. **Verify Protection**
   - Try creating a PR to test the workflow
   - Ensure all CI checks must pass before merge

## ✅ **Current Repository Status**

**As of December 2024, this repository already has:**
- ✅ Comprehensive CI/CD testing all examples
- ✅ CODEOWNERS file for automatic review assignment
- ✅ Security-focused issue templates
- ✅ Professional governance structure

**Branch protection can be enabled by the repository owner following the instructions above.**

---

**Note**: Branch protection rules can only be set by repository administrators through the GitHub web interface.
