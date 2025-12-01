#!/bin/bash

# Script to push GitHub Actions workflows to remote repository

echo "Pushing workflows to dev branch..."

cd /home/mulalo/applications/lss_construction

# Check current status
echo "Current git status:"
git status

echo ""
echo "Attempting to push to origin dev..."

# Try to push
git push origin dev

if [ $? -eq 0 ]; then
    echo "✓ Successfully pushed to dev branch!"
    echo ""
    echo "Creating pull request..."
    
    gh pr create --base main --head dev \
        --title "Add GitHub Actions CI/CD workflows and branch protection" \
        --body "## Summary
This PR adds comprehensive CI/CD workflows and updates branch protection rules.

## GitHub Actions Workflows Added

### 1. **CI Workflow** (\`.github/workflows/ci.yml\`)
- Runs on PRs to main and pushes to dev
- Builds Docker image with caching
- Validates HTML files
- Verifies required files exist
- Validates Docker Compose configuration

### 2. **Build Workflow** (\`.github/workflows/build.yml\`)
- Verifies Docker image builds successfully
- Validates Docker Compose config
- Starts services and tests health
- Tests HTTP endpoint accessibility

### 3. **Test Workflow** (\`.github/workflows/test.yml\`)
- HTML validation with htmlhint
- CSS linting with stylelint
- Checks for broken internal links
- Verifies image references
- Validates required files exist

### 4. **Deploy Workflow** (\`.github/workflows/deploy.yml\`)
- Triggers on push to main
- Validates deployment readiness
- Documents automated deployment schedule
- Creates deployment summary

## Branch Protection Rules

### Main Branch:
- ✅ Requires **ci**, **build**, and **test** checks to pass
- ✅ Requires conversation resolution
- ✅ Dismisses stale reviews on new commits
- ✅ Prevents force pushes
- ✅ Prevents branch deletion
- ✅ No manual approval required (solo developer)

### Dev Branch:
- ✅ Prevents force pushes
- ✅ Prevents branch deletion
- ℹ️ Direct commits allowed for development flexibility

## Benefits
- 🔒 Protected branches prevent accidental changes
- ✅ Automated quality checks on every PR
- 🚀 Deployment workflow ready for main branch
- 📊 Clear CI/CD pipeline visibility
- 🛡️ Prevents broken deployments to production

## Testing
All workflows have been tested locally and are ready for deployment."
    
    if [ $? -eq 0 ]; then
        echo "✓ Pull request created successfully!"
    else
        echo "✗ Failed to create pull request. You may need to create it manually."
    fi
else
    echo "✗ Failed to push. Please check your git credentials."
    echo ""
    echo "You may need to authenticate with GitHub:"
    echo "  gh auth login"
    echo ""
    echo "Or set up SSH keys for git push."
fi
