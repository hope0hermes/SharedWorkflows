# Testing Guide

## Overview

SharedWorkflows includes a comprehensive test suite to validate all actions and workflows before deployment to production projects.

## Test Architecture

```
.github/workflows/
├── test-actions.yml          # Tests all 10 composite actions
└── test-workflows.yml        # Tests reusable workflows

test-fixtures/
└── python-project/           # Test fixture with known characteristics
    ├── src/test_project/
    │   ├── good_code.py     # Clean code (passes linting)
    │   └── bad_code.py      # Intentional issues (fails linting)
    └── tests/
        ├── test_good_code.py  # Passing tests
        └── test_failing.py    # Failing tests
```

## What Gets Tested

### Actions (test-actions.yml)

1. ✅ **python-lint** - Validates linting on good and bad code
2. ✅ **python-test** - Tests with passing/failing scenarios  
3. ✅ **python-ci** - Combined lint + test pipeline
4. ✅ **check-skip-conditions** - Skip logic ([skip ci], version bumps)
5. ✅ **determine-version-bump** - Semantic version detection
6. ✅ **bump-version** - Version bumping with hatch
7. ✅ **update-changelog** - CHANGELOG.md updates
8. ✅ **extract-version** - Version extraction from commits

### Workflows (test-workflows.yml)

1. ✅ **reusable-tests.yml** - Full lint + test workflow
2. ✅ **reusable-commitlint.yml** - Commit message validation

## Running Tests

### On GitHub (Automatic)

Tests run automatically when you:
- Open a PR that modifies actions or workflows
- Push to main
- Manually trigger via Actions tab

### On GitHub (Manual)

1. Go to **Actions** tab
2. Select **Test Actions** or **Test Reusable Workflows**
3. Click **Run workflow**
4. Choose branch
5. Click **Run workflow** button

### Locally with act

```bash
# Install act (first time only)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Test all actions
act pull_request -W .github/workflows/test-actions.yml

# Test specific action
act pull_request -W .github/workflows/test-actions.yml -j test-python-lint

# Test workflows
act pull_request -W .github/workflows/test-workflows.yml
```

### Test Fixture Standalone

```bash
cd test-fixtures/python-project

# Install hatch
pip install hatch

# Run tests
hatch test

# Run linting
hatch run lint

# Test specific scenarios
hatch test tests/test_good_code.py  # Should pass
hatch test tests/test_failing.py    # Should fail
```

## Test Scenarios

### Good Code Path ✅

- Linting passes
- Type checking passes
- Tests pass
- Coverage meets threshold

### Bad Code Path ❌

- Linting detects issues
- Tests fail intentionally
- Coverage below threshold
- Proper error reporting

### Version Bump Detection

- `feat:` → minor bump
- `fix:` → patch bump
- `feat!:` or `BREAKING CHANGE:` → major bump
- `chore:`, `docs:` → no bump

### Skip Conditions

- `[skip ci]` in commit message → skip
- `chore: bump version` commit → skip
- Merge from `release/*` branch → skip
- Normal commits → don't skip

## Expected Test Results

All tests should **pass** with these characteristics:

| Test | Expected Result | Notes |
|------|----------------|-------|
| test-python-lint (good) | ✅ Pass | Clean code |
| test-python-lint (bad) | ⚠️ Detect issues | Known issues |
| test-python-test (passing) | ✅ Pass | All tests pass |
| test-python-test (failing) | ❌ Detect failures | Intentional failures |
| test-python-ci | ✅ Run both | Full pipeline |
| test-skip-conditions | ✅ Detect skips | [skip ci] |
| test-version-bump | ✅ Detect type | feat/fix/chore |
| test-bump-version | ✅ Bump version | 0.1.0 → 0.1.1 |
| test-update-changelog | ✅ Update file | Add version section |
| test-extract-version | ✅ Extract version | From commit |

## Debugging Failed Tests

1. **Check job logs** - Click on failed job in Actions tab
2. **Look for ❌ markers** - Failed steps are clearly marked
3. **Review step output** - Expand step to see full logs
4. **Check test assertions** - Look for "Expected X but got Y"
5. **Run locally** - Use `act` for faster iteration
6. **Fix and retry** - Push fix and tests re-run automatically

## Adding New Tests

When adding a new action:

```yaml
test-new-action:
  name: Test new-action
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Test action (success case)
      id: test-success
      uses: ./actions/new-action
      with:
        input: "valid-value"
    
    - name: Verify success output
      run: |
        if [ "${{ steps.test-success.outputs.result }}" != "expected" ]; then
          echo "❌ Test failed"
          exit 1
        fi
        echo "✅ Test passed"
    
    - name: Test action (failure case)
      id: test-failure
      uses: ./actions/new-action
      with:
        input: "invalid-value"
      continue-on-error: true
    
    - name: Verify failure detected
      run: |
        if [ "${{ steps.test-failure.outcome }}" != "failure" ]; then
          echo "❌ Expected failure not detected"
          exit 1
        fi
        echo "✅ Failure correctly detected"
```

## CI/CD Integration

Tests are **required** to pass before:
- ✅ Merging PRs to main
- ✅ Creating releases
- ✅ Deploying to production projects

## Test Coverage Status

| Component | Coverage | Status |
|-----------|----------|--------|
| Composite Actions | 8/10 | ✅ 80% |
| Reusable Workflows | 2/4 | ⚠️ 50% |
| Overall | 10/14 | ✅ 71% |

**Not tested** (require production environment):
- `create-version-pr` (needs PAT_TOKEN)
- `create-github-release` (needs release context)
- `reusable-release.yml` (needs merge to main)
- `reusable-create-release.yml` (needs version commit)

These are tested **manually** via StravaAnalyzer and StravaFetcher.

## Success Criteria

✅ All action tests pass
✅ All workflow tests pass
✅ Good code detected as good
✅ Bad code detected as bad
✅ Passing tests succeed
✅ Failing tests detected
✅ Version bumps work correctly
✅ Changelogs update properly
✅ Skip conditions detected accurately

---

**Test Badge**: ![Test Actions](https://github.com/hope0hermes/SharedWorkflows/actions/workflows/test-actions.yml/badge.svg)
