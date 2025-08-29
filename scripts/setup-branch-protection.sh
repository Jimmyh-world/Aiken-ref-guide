#!/bin/bash
set -euo pipefail

# Enhanced Branch Protection Setup Script
# Sets up branch protection rules for the enhanced quality architecture

echo "🔒 Setting up Enhanced Branch Protection Rules"

# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required but not installed"
    echo "📋 Install from: https://github.com/cli/cli#installation"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI not authenticated"
    echo "📋 Run: gh auth login"
    exit 1
fi

# Get repository information
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
echo "🎯 Repository: $REPO"

# Function to set branch protection
setup_branch_protection() {
    local branch="$1"
    local required_checks="$2"
    local required_reviews="$3"
    local description="$4"
    
    echo "📋 Setting up protection for $branch branch ($description)"
    
    # Create branch protection rule
    gh api \
        --method PUT \
        "/repos/$REPO/branches/$branch/protection" \
        --field required_status_checks="{
            \"strict\": true,
            \"checks\": $required_checks
        }" \
        --field enforce_admins=true \
        --field required_pull_request_reviews="{
            \"required_approving_review_count\": $required_reviews,
            \"dismiss_stale_reviews\": true,
            \"require_code_owner_reviews\": true,
            \"require_last_push_approval\": true
        }" \
        --field restrictions=null \
        --field allow_force_pushes=false \
        --field allow_deletions=false \
        --field block_creations=false \
        --field required_linear_history=true \
        --field allow_fork_syncing=true \
        || echo "⚠️ Warning: Some protection settings may not have been applied to $branch"
}

# Main branch protection (Production Excellence)
echo ""
echo "🚀 Configuring MAIN branch protection (Production Excellence)"
main_checks='[
    {"context": "CI – Core"},
    {"context": "CI – Examples (Enhanced) / Examples Summary"},
    {"context": "Production Promotion Gate / Production Promotion Decision"},
    {"context": "Quality Monitoring / Main Branch Quality Assessment"}
]'

setup_branch_protection "main" "$main_checks" 2 "Production Excellence"

# Development branch protection (Active Innovation)
echo ""
echo "🔧 Configuring DEVELOPMENT branch protection (Active Innovation)"
dev_checks='[
    {"context": "CI – Core"},
    {"context": "CI – Examples (Enhanced) / Examples Summary"}
]'

# Create development branch if it doesn't exist
if ! gh api "/repos/$REPO/branches/development" &> /dev/null; then
    echo "📝 Creating development branch from main"
    MAIN_SHA=$(gh api "/repos/$REPO/git/refs/heads/main" --jq '.object.sha')
    gh api \
        --method POST \
        "/repos/$REPO/git/refs" \
        --field ref="refs/heads/development" \
        --field sha="$MAIN_SHA" \
        || echo "⚠️ Development branch creation failed - may already exist"
fi

setup_branch_protection "development" "$dev_checks" 1 "Active Innovation"

# Educational branch protection (Learning Excellence)
echo ""
echo "📚 Configuring EDUCATIONAL branch protection (Learning Excellence)"
edu_checks='[
    {"context": "CI – Core"},
    {"context": "Educational Content Validation"}
]'

# Create educational branch if it doesn't exist
if ! gh api "/repos/$REPO/branches/educational" &> /dev/null; then
    echo "📝 Creating educational branch from main"
    MAIN_SHA=$(gh api "/repos/$REPO/git/refs/heads/main" --jq '.object.sha')
    gh api \
        --method POST \
        "/repos/$REPO/git/refs" \
        --field ref="refs/heads/educational" \
        --field sha="$MAIN_SHA" \
        || echo "⚠️ Educational branch creation failed - may already exist"
fi

setup_branch_protection "educational" "$edu_checks" 1 "Learning Excellence"

echo ""
echo "✅ Branch protection setup completed!"
echo ""
echo "📋 Summary:"
echo "   🚀 MAIN: Production-ready examples only (2 reviewers required)"
echo "   🔧 DEVELOPMENT: Work-in-progress features (1 reviewer required)"
echo "   📚 EDUCATIONAL: Learning content with safety warnings (1 reviewer required)"
echo ""
echo "🔒 All branches have:"
echo "   - Required status checks"
echo "   - No force pushes"
echo "   - No deletions"
echo "   - Linear history required"
echo "   - Dismiss stale reviews"
echo "   - Code owner reviews required"
echo ""
echo "🎯 Next steps:"
echo "   1. Verify branch protection in GitHub Settings > Branches"
echo "   2. Update CODEOWNERS file if needed"
echo "   3. Begin content migration process"
echo "   4. Test workflows on each branch"
