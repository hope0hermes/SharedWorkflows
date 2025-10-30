# Development Guide

## Testing SharedWorkflows Changes

### Current Problem

Currently, testing changes to SharedWorkflows reusable workflows and composite actions requires:
1. Making changes in SharedWorkflows
2. Creating a PR in SharedWorkflows
3. Pushing to another "real" project repository (like StravaFetcher) to trigger the workflows
4. Debugging issues by going back and forth between repositories
5. Polluting the commit history of production repositories with test commits

**This is inefficient and pollutes production repositories with test/debug commits.**

### Proposed Solution: Dedicated Test Repository

Create a dedicated test repository (`SharedWorkflows-TestHarness` or similar) that:

#### Purpose
- **Sole purpose**: Test SharedWorkflows reusable workflows and composite actions
- **Clean separation**: Keep test/debug commits out of production repositories
- **Fast iteration**: Quick feedback loop for workflow development

#### Structure
```
SharedWorkflows-TestHarness/
├── .github/
│   └── workflows/
│       ├── test-reusable-tests.yml      # Tests the reusable-tests workflow
│       ├── test-reusable-release.yml    # Tests the reusable-release workflow
│       ├── test-reusable-create-release.yml  # Tests the create-release workflow
│       └── test-composite-actions.yml   # Tests individual composite actions
├── src/
│   └── test_package/
│       └── __init__.py                  # Dummy Python package with version
├── tests/
│   └── test_dummy.py                    # Simple tests that pass/fail
├── CHANGELOG.md                         # For testing changelog updates
├── pyproject.toml                       # Minimal Python project config
└── README.md                            # Explains the test harness purpose
```

#### Features

1. **Test Different Workflow References**
   - Test with `@main` (latest changes)
   - Test with `@branch-name` (PR branches)
   - Test with `@v1.0.0` (specific versions)

2. **Automated PR Testing**
   - SharedWorkflows PR creates test branch in test harness
   - Automatically triggers test workflows
   - PR shows test results without polluting production repos

3. **Comprehensive Test Scenarios**
   - Test all workflow inputs and configurations
   - Test error handling and edge cases
   - Test conventional commit parsing
   - Test version bumping logic
   - Test PR creation and release creation

4. **Configuration Matrix**
   ```yaml
   # Example: Test different Python versions, coverage thresholds, etc.
   strategy:
     matrix:
       python-version: ['3.10', '3.11', '3.12']
       test-scenario: ['passing-tests', 'failing-tests', 'no-tests']
   ```

#### Implementation Steps

1. **Create the test repository**
   ```bash
   gh repo create SharedWorkflows-TestHarness --public
   ```

2. **Set up minimal Python project**
   - Single source file with version
   - Basic tests (some pass, some can be toggled to fail)
   - Minimal dependencies

3. **Create test workflows**
   - One workflow per reusable workflow
   - Test various input combinations
   - Test error scenarios

4. **Add to SharedWorkflows CI**
   - When PR is created in SharedWorkflows
   - Automatically create branch in test harness
   - Trigger test workflows pointing to PR branch
   - Report results back to SharedWorkflows PR

5. **Document usage**
   - How to run tests locally
   - How to add new test scenarios
   - How to interpret test results

#### Benefits

✅ **No pollution of production repositories**
   - StravaFetcher, StravaAnalyzer, etc. remain clean
   - Only intentional updates, not test commits

✅ **Faster development cycle**
   - Test changes immediately
   - No need to touch production repos
   - Clear test results in one place

✅ **Comprehensive testing**
   - Test all workflow features
   - Test edge cases and error handling
   - Validate before merging to main

✅ **Better CI/CD confidence**
   - Know workflows work before merging
   - Catch issues early
   - Prevent breaking production repos

✅ **Easier debugging**
   - Isolated test environment
   - Can break things without consequences
   - Quick iteration without cleanup

#### Example Test Workflow

```yaml
# .github/workflows/test-reusable-release.yml
name: Test Reusable Release Workflow

on:
  push:
    branches: [ main, test/** ]
  workflow_dispatch:
    inputs:
      workflow-ref:
        description: 'SharedWorkflows branch/tag to test'
        required: false
        default: 'main'

jobs:
  test-release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-release.yml@${{ github.event.inputs.workflow-ref || 'main' }}
    with:
      package-path: "src/test_package/__init__.py"
    secrets:
      PAT_TOKEN: ${{ secrets.PAT_TOKEN }}
```

#### Integration with SharedWorkflows CI

Add a workflow in SharedWorkflows that triggers tests:

```yaml
# .github/workflows/test-in-harness.yml
name: Test in Harness

on:
  pull_request:
    branches: [ main ]

jobs:
  trigger-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger test workflows in test harness
        run: |
          # Use GitHub API to trigger workflow_dispatch in test harness
          # Pass the PR branch name to test the changes
          gh workflow run test-all.yml \
            --repo hope0hermes/SharedWorkflows-TestHarness \
            --ref main \
            --field workflow-ref=${{ github.head_ref }}
```

## Priority

**HIGH** - This will significantly improve development workflow and prevent issues like we experienced during the StravaFetcher integration.

## Action Items

- [ ] Create `SharedWorkflows-TestHarness` repository
- [ ] Set up minimal Python project structure
- [ ] Create test workflows for each reusable workflow
- [ ] Add automated testing to SharedWorkflows PR process
- [ ] Document test harness usage in this file
- [ ] Add examples of different test scenarios

## Related Issues

This addresses the problem of:
- Having to create test PRs in production repositories
- Polluting production repo history with test commits
- Slow feedback loop during workflow development
- Risk of breaking production repositories during testing
