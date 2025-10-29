# SharedWorkflows Test Suite

This directory contains comprehensive tests for all SharedWorkflows actions and reusable workflows.

## Test Strategy

### 1. Unit Tests for Actions (`test-actions.yml`)

Tests each composite action individually using the test fixture project:

- ✅ **python-lint**: Validates linting on good and bad code
- ✅ **python-test**: Runs tests with passing and failing scenarios
- ✅ **python-ci**: Tests combined lint + test pipeline
- ✅ **check-skip-conditions**: Validates skip logic ([skip ci], version bumps)
- ✅ **determine-version-bump**: Tests commit message parsing for semantic versioning
- ✅ **bump-version**: Validates version bumping with hatch
- ✅ **update-changelog**: Tests CHANGELOG.md updates
- ✅ **extract-version**: Validates version extraction from commits

### 2. Integration Tests for Workflows (`test-workflows.yml`)

Tests reusable workflows end-to-end:

- ✅ **reusable-tests.yml**: Full lint + test workflow
- ✅ **reusable-commitlint.yml**: Commit message validation

### 3. Test Fixture (`test-fixtures/python-project/`)

A minimal Python project with known characteristics:

**Good Code** (`good_code.py`):
- ✅ Passes ruff, mypy, pylint, pydocstyle
- ✅ Full type hints
- ✅ Proper docstrings
- ✅ Clean formatting

**Bad Code** (`bad_code.py`):
- ❌ Missing type hints
- ❌ Poor formatting
- ❌ Missing docstrings
- ❌ Unused variables
- ❌ Lines too long

**Passing Tests** (`test_good_code.py`):
- ✅ All assertions pass
- ✅ Good coverage

**Failing Tests** (`test_failing.py`):
- ❌ Intentional failures
- ❌ Failed assertions
- ❌ Expected exceptions not raised

## Running Tests

### Automatically

Tests run automatically on:
- **Pull Requests** that modify actions or workflows
- **Pushes to main**
- **Manual trigger** via workflow_dispatch

### Manually

Trigger tests from GitHub Actions tab:
1. Go to Actions → Test Actions (or Test Reusable Workflows)
2. Click "Run workflow"
3. Select branch
4. Click "Run workflow"

### Locally with `act`

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Test all actions
act pull_request -W .github/workflows/test-actions.yml

# Test specific job
act pull_request -W .github/workflows/test-actions.yml -j test-python-lint
```

## Test Coverage

| Component | Test Coverage | Notes |
|-----------|--------------|-------|
| python-lint | ✅ Full | Tests good and bad code |
| python-test | ✅ Full | Tests passing and failing tests |
| python-ci | ✅ Full | Tests combined pipeline |
| check-skip-conditions | ✅ Full | Tests [skip ci] detection |
| determine-version-bump | ✅ Full | Tests conventional commits |
| bump-version | ✅ Full | Tests hatch version bumping |
| update-changelog | ✅ Full | Tests CHANGELOG updates |
| extract-version | ✅ Full | Tests version extraction |
| create-version-pr | ⚠️ Partial | Requires PAT_TOKEN |
| create-github-release | ⚠️ Partial | Requires release context |
| reusable-tests.yml | ✅ Full | End-to-end test + lint |
| reusable-commitlint.yml | ✅ Full | Commit message validation |
| reusable-release.yml | ⚠️ Manual | Requires main branch merge |
| reusable-create-release.yml | ⚠️ Manual | Requires version commit |

## Test Results

Tests generate a summary report showing:
- ✅ Passing tests
- ❌ Failing tests
- ⚠️ Warnings
- 📊 Coverage percentages
- 🔍 Detailed logs

View in: **Actions → [Workflow Run] → Summary**

## Adding New Tests

When adding a new action or workflow:

1. **Create test job** in `test-actions.yml` or `test-workflows.yml`
2. **Test both success and failure** scenarios
3. **Verify outputs** using assertions
4. **Update this README** with test coverage info

Example test structure:

```yaml
test-new-action:
  name: Test new-action
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Test action
      id: test
      uses: ./actions/new-action
      with:
        input: "value"
      continue-on-error: true

    - name: Verify output
      run: |
        if [ "${{ steps.test.outputs.result }}" != "expected" ]; then
          echo "❌ Test failed"
          exit 1
        fi
        echo "✅ Test passed"
```

## Debugging Failed Tests

1. **Check the job logs** in GitHub Actions
2. **Look for step that failed** (marked with ❌)
3. **Review error messages** and outputs
4. **Run locally with `act`** for faster iteration
5. **Fix the action/workflow**
6. **Push and re-run tests**

## Known Limitations

- **PR creation tests** require PAT_TOKEN secret (not in test environment)
- **GitHub release tests** require actual releases (tested in real projects)
- **Full release workflow** tested manually via StravaAnalyzer/StravaFetcher

## CI/CD Integration

These tests ensure:
- ✅ Actions work correctly before merging
- ✅ No regressions when updating actions
- ✅ All inputs/outputs function as documented
- ✅ Error handling works properly
- ✅ Reusable workflows can be called successfully

## Success Criteria

All tests must pass before merging PRs that affect:
- Action definitions (`actions/*/action.yml`)
- Reusable workflows (`.github/workflows/reusable-*.yml`)
- Test fixtures (`test-fixtures/`)

---

**Test Status**: ![Test Actions](https://github.com/hope0hermes/SharedWorkflows/actions/workflows/test-actions.yml/badge.svg)
