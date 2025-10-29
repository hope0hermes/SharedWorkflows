# Migration Guide

This guide helps you migrate existing projects to use SharedWorkflows.

## Table of Contents

- [Before You Start](#before-you-start)
- [Migration Steps](#migration-steps)
- [Example: StravaAnalyzer](#example-stravaanalyzer)
- [Example: StravaFetcher](#example-stravafetcher)
- [Verification](#verification)
- [Rollback Plan](#rollback-plan)

---

## Before You Start

### Prerequisites

✅ Repository uses Python with hatch  
✅ Has `__version__` in `src/<package>/__init__.py`  
✅ Has `CHANGELOG.md` with `## [Unreleased]` section  
✅ Uses conventional commits  
✅ Has existing GitHub Actions workflows  

### Backup

```bash
# Create backup branch
git checkout -b backup/before-shared-workflows
git push origin backup/before-shared-workflows

# Create feature branch for migration
git checkout main
git pull
git checkout -b feat/migrate-to-shared-workflows
```

---

## Migration Steps

### Step 1: Configure Secrets

1. Create PAT_TOKEN:
   - Go to https://github.com/settings/tokens/new
   - Scopes: `repo`, `workflow`
   - Generate and copy token

2. Add to repository:
   - Settings → Secrets and variables → Actions
   - New repository secret: `PAT_TOKEN`
   - Paste token

### Step 2: Update tests.yml

**Before** (70+ lines):
```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.12"]

    steps:
    - uses: actions/checkout@v4
    
    # ... 50+ more lines ...
```

**After** (12 lines):
```yaml
name: Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@main
    with:
      python-version: "3.12"
      package-name: "your_package"
      coverage-threshold: 80
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Step 3: Update commitlint.yml

**Before** (90+ lines):
```yaml
name: Lint Commit Messages

on:
  push:
    branches:
      - 'release/**'
  pull_request:
    branches: [ main ]

jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # ... 70+ more lines ...
```

**After** (10 lines):
```yaml
name: Lint Commit Messages

on:
  pull_request:
    branches: [ main ]

jobs:
  commitlint:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-commitlint.yml@main
```

### Step 4: Update release.yml

**Before** (200+ lines):
```yaml
name: Release

on:
  push:
    branches: [ main ]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write

    steps:
    - uses: actions/checkout@v4
    
    # ... 180+ more lines ...
```

**After** (12 lines):
```yaml
name: Release

on:
  push:
    branches: [ main ]

jobs:
  release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-release.yml@main
    with:
      package-path: "src/your_package/__init__.py"
    secrets:
      PAT_TOKEN: ${{ secrets.PAT_TOKEN }}
```

### Step 5: Update create-release.yml

**Before** (80+ lines):
```yaml
name: Create Release

on:
  push:
    branches: [ main ]

jobs:
  create-release:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
    - uses: actions/checkout@v4
    
    # ... 70+ more lines ...
```

**After** (10 lines):
```yaml
name: Create Release

on:
  push:
    branches: [ main ]

jobs:
  create-release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-create-release.yml@main
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Step 6: Commit and Push

```bash
git add .github/workflows/
git commit -m "feat: migrate to SharedWorkflows

- Replace 400+ lines of workflow code with ~45 lines
- Use reusable workflows for maintainability
- Preserve all existing functionality"

git push origin feat/migrate-to-shared-workflows
```

### Step 7: Create PR

```bash
gh pr create \
  --title "feat: migrate to SharedWorkflows" \
  --body "Migrates to reusable workflows from hope0hermes/SharedWorkflows

**Benefits:**
- Single source of truth for CI/CD logic
- Easier maintenance (update once, applies everywhere)
- Reduced duplication (400+ lines → ~45 lines)

**Changes:**
- Updated tests.yml
- Updated commitlint.yml  
- Updated release.yml
- Updated create-release.yml

**Testing:**
- All existing functionality preserved
- Workflows will run on this PR to verify"
```

---

## Example: StravaAnalyzer

See the actual migration in StravaAnalyzer:

**Before:**
- `tests.yml`: 71 lines
- `commitlint.yml`: 90 lines  
- `release.yml`: 203 lines
- `create-release.yml`: 70 lines
- **Total: 434 lines**

**After:**
- `tests.yml`: 12 lines
- `commitlint.yml`: 10 lines
- `release.yml`: 12 lines
- `create-release.yml`: 10 lines
- **Total: 44 lines**

**Saved: 390 lines (90% reduction!)**

---

## Example: StravaFetcher

Similar migration with same benefits.

**Key difference:**
```yaml
# StravaAnalyzer
with:
  package-path: "src/strava_analyzer/__init__.py"

# StravaFetcher
with:
  package-path: "src/strava_fetcher/__init__.py"
```

Everything else is identical!

---

## Verification

### After PR is created:

1. ✅ **Tests workflow runs** on the PR
2. ✅ **Commitlint workflow runs** on the PR
3. ✅ **All checks pass**

### After PR is merged:

4. ✅ **Release workflow runs** and creates version bump PR
5. ✅ Merge version bump PR
6. ✅ **Create-release workflow runs** and creates GitHub Release

### Verify functionality:

```bash
# Check workflows
gh workflow list

# Check latest run
gh run list --limit 5

# View workflow run
gh run view <run-id>
```

---

## Rollback Plan

If something goes wrong:

### Option 1: Revert PR

```bash
git revert <merge-commit-sha>
git push origin main
```

### Option 2: Restore from backup

```bash
git checkout main
git reset --hard backup/before-shared-workflows
git push origin main --force
```

### Option 3: Manual fix

Edit workflow files to fix specific issues while keeping SharedWorkflows.

---

## Troubleshooting

### Workflows not running

**Problem:** No workflows appear after PR creation

**Solution:**
- Check workflow files are in `.github/workflows/`
- Ensure files have `.yml` extension
- Verify syntax with `yamllint .github/workflows/*.yml`

### PAT_TOKEN errors

**Problem:** Release workflow fails with "Resource not accessible by integration"

**Solution:**
- Verify PAT_TOKEN secret exists
- Check token has `repo` and `workflow` scopes
- Regenerate token if expired

### Tests failing

**Problem:** Tests that passed before now fail

**Solution:**
- Check Python version matches
- Verify hatch configuration
- Compare test output with original workflow

### Version bump not created

**Problem:** Release workflow runs but no PR created

**Solution:**
- Verify commit messages follow conventional format
- Check that commits aren't skipped (`[skip ci]`, `chore: bump version`)
- Ensure PAT_TOKEN has correct permissions

---

## Post-Migration

### Monitor

- Watch first few workflow runs
- Check Slack/email notifications
- Review GitHub Actions usage

### Cleanup

After successful migration:

```bash
# Delete backup branch (optional)
git push origin :backup/before-shared-workflows

# Update documentation
# Update CI badge URLs if needed
```

### Celebrate! 🎉

You've reduced 400+ lines to ~45 lines while maintaining all functionality!

---

## Questions?

- Check [USAGE.md](USAGE.md) for configuration options
- See [EXAMPLES.md](EXAMPLES.md) for advanced patterns
- Open an issue in SharedWorkflows repository
