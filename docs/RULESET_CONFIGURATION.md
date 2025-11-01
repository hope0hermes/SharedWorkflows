# Branch Ruleset Configuration Guide

This guide documents the branch protection rulesets that should be applied to repositories using SharedWorkflows. These rulesets enforce consistent quality standards across all projects.

## Overview

GitHub's **Rulesets** (branch protection) are repository-level configurations that:
- Enforce required status checks before merging
- Prevent branch deletion and force pushes
- Require pull request reviews and resolutions
- Control merge methods allowed

Since GitHub does not support sharing rulesets across repositories natively, this guide provides:
1. The exact configuration to apply
2. Manual setup instructions via GitHub UI
3. Automated verification via CLI
4. Troubleshooting guidance

## Standard Ruleset Configuration

### Ruleset Name
**`main protection`**

### Enforcement Status
**Active** - Rules are enforced on the `main` branch

### Target
**Branch** - Apply to all branches matching the pattern below

### Branch Pattern
- **Include**: `refs/heads/main`
- **Exclude**: (none)

## Rules

### 1. Deletion Protection
**Restrict deletions** - Prevents accidental or malicious deletion of the main branch
- Applies to: All roles (no bypass)

### 2. Non-Fast-Forward Protection
**Prevent force pushes** - Blocks `git push --force` and similar commands
- Applies to: All roles (no bypass)

### 3. Pull Request Rules
Requires pull requests for changes to the main branch:

| Setting | Value | Purpose |
|---------|-------|---------|
| Allowed merge methods | merge, squash, rebase | Flexibility in commit strategy |
| Dismiss stale reviews | false | Require fresh reviews for each push |
| Require code owner review | false | Not required (customize if needed) |
| Require last push approval | false | Not required (customize if needed) |
| Required review count | 0 | Not required (customize if needed) |
| Require resolved conversations | true | All review threads must be resolved |

### 4. Required Status Checks
These CI/CD checks must pass before merging:

```
✓ commitlint / Lint Commit Messages
✓ test / Lint {project-name}
✓ test / Test {project-name}
```

**Note**: Replace `{project-name}` with your project's identifier (e.g., `strava-analyzer`)

| Setting | Value | Purpose |
|---------|-------|---------|
| Strict required status checks | true | Require up-to-date status checks (no stale results) |
| Do not enforce on create | false | Enforce rules even when branch is created |

## Setup Instructions

### Option 1: Manual Setup via GitHub UI (Recommended for Initial Setup)

1. **Navigate to Repository Settings**
   - Go to your repository on GitHub
   - Click **Settings** → **Rules** → **Rulesets**

2. **Create New Ruleset**
   - Click **New ruleset** → **New branch ruleset**

3. **Name and Target**
   - **Ruleset name**: `main protection`
   - **Enforcement**: Active
   - **Target**: Branch
   - **Branch targeting criteria**: `main`

4. **Configure Branch Rules**
   - ✅ **Restrict deletions**: Enable
   - ✅ **Restrict force pushes**: Enable

5. **Configure Pull Request Rules**
   - ✅ **Require a pull request before merging**: Enable
   - **Allowed merge methods**: Check `merge`, `squash`, `rebase`
   - **Dismiss stale pull request reviews**: Disable
   - **Require code owner review**: Disable (optional - enable for strict review)
   - **Require approval of the most recent push**: Disable
   - **Require conversation resolution before merging**: ✅ Enable

6. **Configure Status Checks**
   - ✅ **Require status checks to pass**: Enable
   - **Require branches to be up to date before merging**: ✅ Enable
   - **Status checks that must pass**:
     - `commitlint / Lint Commit Messages`
     - `test / Lint {project-name}`
     - `test / Test {project-name}`

7. **Save Ruleset**
   - Click **Create** button

### Option 2: Automated Setup via GitHub CLI

Create a file `scripts/setup-ruleset.sh`:

```bash
#!/bin/bash
set -e

REPO="${1}"
PROJECT_NAME="${2}"

if [ -z "$REPO" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <repo> <project-name>"
    echo "Example: $0 hope0hermes/MyProject my-project"
    exit 1
fi

echo "Setting up branch ruleset for $REPO..."

# Note: GitHub CLI doesn't directly support creating rulesets yet
# You must use the GitHub API or GitHub UI
# Use this command to verify existing rulesets:
gh api repos/$REPO/rulesets --jq '.[] | select(.name=="main protection")'

echo ""
echo "To create the ruleset, use GitHub UI or GitHub REST API."
```

**Using GitHub REST API directly:**

```bash
curl -X POST \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/rulesets \
  -d '{
    "name": "main protection",
    "target": "branch",
    "enforcement": "active",
    "conditions": {
      "ref_name": {
        "include": ["refs/heads/main"],
        "exclude": []
      }
    },
    "rules": [
      {
        "type": "deletion"
      },
      {
        "type": "non_fast_forward"
      },
      {
        "type": "pull_request",
        "parameters": {
          "allowed_merge_methods": ["merge", "squash", "rebase"],
          "automatic_copilot_code_review_enabled": false,
          "dismiss_stale_reviews_on_push": false,
          "require_code_owner_review": false,
          "require_last_push_approval": false,
          "required_approving_review_count": 0,
          "required_review_thread_resolution": true
        }
      },
      {
        "type": "required_status_checks",
        "parameters": {
          "do_not_enforce_on_create": false,
          "required_status_checks": [
            {
              "context": "commitlint / Lint Commit Messages"
            },
            {
              "context": "test / Lint PROJECT_NAME"
            },
            {
              "context": "test / Test PROJECT_NAME"
            }
          ],
          "strict_required_status_checks_policy": true
        }
      }
    ]
  }'
```

## Verification

### Check Existing Rulesets

```bash
# List all rulesets for a repo
gh api repos/OWNER/REPO/rulesets --jq '.'

# Get detailed configuration of a specific ruleset
gh api repos/OWNER/REPO/rulesets/RULESET_ID --jq '.'

# Check only required status checks
gh api repos/OWNER/REPO/rulesets/RULESET_ID \
  --jq '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[]'
```

### Verify Consistency Across Repos

Create `scripts/verify-rulesets.sh`:

```bash
#!/bin/bash

REPOS=(
  "hope0hermes/StravaAnalyzer"
  "hope0hermes/SharedWorkflows-TestHarness"
  "hope0hermes/StravaFetcher"
)

echo "=== Verifying Branch Rulesets ==="
echo ""

for repo in "${REPOS[@]}"; do
  echo "Repository: $repo"
  
  # Get rulesets
  rulesets=$(gh api repos/$repo/rulesets --jq '.[].id' 2>/dev/null)
  
  if [ -z "$rulesets" ]; then
    echo "  ❌ No rulesets found"
  else
    for ruleset_id in $rulesets; do
      ruleset_name=$(gh api repos/$repo/rulesets/$ruleset_id --jq '.name')
      enforcement=$(gh api repos/$repo/rulesets/$ruleset_id --jq '.enforcement')
      
      echo "  ✓ Ruleset: $ruleset_name (Enforcement: $enforcement)"
      
      # Show status checks
      checks=$(gh api repos/$repo/rulesets/$ruleset_id \
        --jq '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[] | .context' 2>/dev/null)
      
      if [ -n "$checks" ]; then
        echo "    Status Checks:"
        echo "$checks" | while read -r check; do
          echo "      - $check"
        done
      fi
    fi
  fi
  
  echo ""
done
```

Run the verification script:

```bash
chmod +x scripts/verify-rulesets.sh
./scripts/verify-rulesets.sh
```

## Troubleshooting

### Issue: Status checks not appearing in ruleset

**Cause**: The status check doesn't exist yet (workflows haven't run)

**Solution**: 
1. Push a commit to the repository
2. Wait for workflows to run and generate status checks
3. Then add them to the ruleset

### Issue: "commitlint / Lint Commit Messages" check not working

**Cause**: Commitlint workflow not configured in the repository

**Solution**: 
Ensure your repository has the `commitlint.yml` workflow from SharedWorkflows:
- Path: `.github/workflows/commitlint.yml`
- Should validate conventional commits

### Issue: Cannot merge due to missing status checks

**Cause**: A required status check failed or hasn't completed yet

**Solution**:
1. Click on "Details" in the PR status check section
2. Review the workflow logs
3. Fix the issue and push a new commit
4. Wait for all checks to pass

### Issue: Rulesets don't sync across repositories

**Cause**: GitHub doesn't support automatic ruleset synchronization

**Solution**:
- Manually verify rulesets using the verification script above
- Create a checklist in your team's documentation
- Consider automation via GitHub Apps (advanced)

## Best Practices

### 1. Match Rulesets Across Repositories
When using SharedWorkflows, ensure all consuming repositories have identical rulesets:
- Same branch patterns (`main`)
- Same required status checks
- Same protections enabled

### 2. Document Custom Rules
If you modify rulesets for a specific project, document the reason:

```markdown
### Project-Specific Ruleset Changes

**Repository**: MySpecialProject

**Customization**: 
- Requires 2 code owner approvals (instead of 0)
- Reason: High-risk financial calculations

**Date Modified**: 2025-11-01
**Modified By**: @developer-name
```

### 3. Regular Audits
Periodically verify rulesets haven't drifted:

```bash
# Monthly audit
*/0 * 1 * * /path/to/scripts/verify-rulesets.sh >> /var/log/ruleset-audit.log
```

### 4. Update Documentation After Changes
When you modify a ruleset, update this document and commit the change.

## Related Documentation

- [GitHub Rulesets Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [SharedWorkflows Setup Guide](./SETUP.md)
- [Version Management](./VERSION_MANAGEMENT.md)
