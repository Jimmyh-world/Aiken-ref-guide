#!/bin/bash

# Aiken Reference Guide Repository Monitor
# This script provides a comprehensive overview of repository status

echo "🔍 Aiken Reference Guide - Repository Monitor"
echo "=============================================="
echo

# Repository basic info
echo "📊 Repository Statistics:"
gh repo view --json stargazerCount,forkCount,issues,pullRequests,updatedAt --jq '
  "Stars: " + (.stargazerCount | tostring) + 
  " | Forks: " + (.forkCount | tostring) + 
  " | Issues: " + (.issues.totalCount | tostring) + 
  " | PRs: " + (.pullRequests.totalCount | tostring) + 
  " | Last Updated: " + (.updatedAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M UTC"))
'

echo
echo "🔄 Recent Workflow Runs:"
gh run list --limit 3 --json status,conclusion,workflowName,createdAt,headBranch

echo
echo "📝 Recent Commits:"
git log --oneline -5

echo
echo "🔒 Security Status:"
# Check for any security alerts
gh api repos/Jimmyh-world/Aiken-ref-guide/security-advisories --jq 'length' 2>/dev/null || echo "No security advisories found"

echo
echo "✅ Repository Health Check:"
# Check if main branch is up to date
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)
if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    echo "✓ Local branch is up to date with remote"
else
    echo "⚠ Local branch is behind remote"
fi

# Check for uncommitted changes
if [ -z "$(git status --porcelain)" ]; then
    echo "✓ Working directory is clean"
else
    echo "⚠ Working directory has uncommitted changes"
fi

echo
echo "📈 Quick Actions:"
echo "  • View recent runs: gh run list"
echo "  • Watch latest run: gh run watch"
echo "  • View issues: gh issue list"
echo "  • View PRs: gh pr list"
echo "  • Check status: gh repo view"
