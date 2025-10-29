# Usage Guide

This guide shows you how to use SharedWorkflows in your Python projects.

## Table of Contents

- [Basic Setup](#basic-setup)
- [Reusable Workflows](#reusable-workflows)
- [Composite Actions](#composite-actions)
- [Configuration Options](#configuration-options)
- [Secrets](#secrets)

---

## Basic Setup

### 1. Create Workflow Files

Create these files in your repository's `.github/workflows/` directory:

**tests.yml** - Run tests on PRs and pushes
**commitlint.yml** - Validate commit messages
**release.yml** - Automated version bumping
**create-release.yml** - Create GitHub releases

### 2. Configure Secrets

Add these secrets to your repository:
- `PAT_TOKEN` - Personal Access Token with `repo` and `pull_request` scopes

### 3. Update Your Code

Ensure your project uses:
- Hatch for package management
- `__version__` in `__init__.py`
- `CHANGELOG.md` with `## [Unreleased]` section
- Conventional commit messages

---

## Reusable Workflows

### reusable-tests.yml

Runs linting and testing with coverage.

**Minimal Usage:**
```yaml
jobs:
  test:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@main
    with:
      package-name: "my_package"
```

**Full Options:**
```yaml
jobs:
  test:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@main
    with:
      python-version: "3.12"           # Python version
      package-name: "my_package"        # Package name (for display)
      coverage-threshold: 80            # Minimum coverage % (0 = no check)
      run-lint: true                    # Run linting
      run-tests: true                   # Run tests
      working-directory: "."            # Project directory
      pytest-args: ""                   # Additional pytest arguments (e.g., "tests/test_specific.py")
```

**Features:**
- Runs linting first (fail fast)
- Only runs tests if linting passes
- Skips tests on version bump merges
- Uploads coverage artifacts
- Cancels outdated runs
- Supports selective test execution via pytest-args

---

### reusable-commitlint.yml

Validates PR titles and commit messages.

**Usage:**
```yaml
jobs:
  commitlint:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-commitlint.yml@main
```

**What It Checks:**
- PR title follows conventional commits
- All commit messages follow conventional commits
- Case-insensitive matching

**Valid Formats:**
- `feat: add new feature`
- `fix: correct bug`
- `docs: update README`
- `chore: update dependencies`
- `feat!: breaking change`

---

### reusable-release.yml

Automates version bumping and changelog updates.

**Usage:**
```yaml
jobs:
  release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-release.yml@main
    with:
      package-path: "src/my_package/__init__.py"
    secrets:
      PAT_TOKEN: ${{ secrets.PAT_TOKEN }}
```

**What It Does:**
1. Analyzes commits since last release
2. Determines version bump (major/minor/patch/none)
3. Bumps version in `__init__.py`
4. Updates `CHANGELOG.md`
5. Creates a PR with changes

**Version Bump Rules:**
- `feat!:` or `BREAKING CHANGE:` → **major** (1.0.0 → 2.0.0)
- `feat:` → **minor** (1.0.0 → 1.1.0)
- `fix:`, `perf:`, `refactor:` → **patch** (1.0.0 → 1.0.1)
- Other types → **no bump**

**Skip Conditions:**
- Commits with `[skip ci]`
- Commits starting with `chore: bump version`
- Merge commits from `release/v*` branches

---

### reusable-create-release.yml

Creates GitHub releases after version bump PRs are merged.

**Usage:**
```yaml
jobs:
  create-release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-create-release.yml@main
```

**What It Does:**
1. Detects version bump merge commits
2. Extracts version number
3. Creates git tag (`v1.0.0`)
4. Creates GitHub Release with changelog notes

---

## Composite Actions

For more control, use individual actions in your custom workflows.

### python-lint

```yaml
- uses: hope0hermes/SharedWorkflows/actions/python-lint@main
  with:
    python-version: "3.12"
    working-directory: "."
```

### python-test

```yaml
- uses: hope0hermes/SharedWorkflows/actions/python-test@main
  with:
    python-version: "3.12"
    coverage-threshold: 80
    upload-coverage: true
    pytest-args: "tests/test_specific.py -v"  # Optional: run specific tests
```

### python-ci

```yaml
- uses: hope0hermes/SharedWorkflows/actions/python-ci@main
  with:
    python-version: "3.12"
    run-lint: true
    run-tests: true
    coverage-threshold: 80
```

See individual action files in the `actions/` directory for complete action documentation.

---

## Configuration Options

### Python Version

All actions support custom Python versions:
```yaml
with:
  python-version: "3.11"
```

### Working Directory

For monorepos or non-standard layouts:
```yaml
with:
  working-directory: "packages/my-package"
```

### Coverage Threshold

Enforce minimum coverage:
```yaml
with:
  coverage-threshold: 90  # Fail if coverage < 90%
```

### Skip Tests

Skip tests but run linting:
```yaml
with:
  run-tests: false
  run-lint: true
```

### Selective Test Execution

Run only specific tests:
```yaml
with:
  pytest-args: "tests/test_integration.py -v -k test_specific"
```

---

## Secrets

### GITHUB_TOKEN

Automatically provided by GitHub Actions. No configuration needed!

**Used for:**
- Reading repository content
- Creating releases (via reusable-create-release.yml)
- Uploading artifacts

**Note:** The `reusable-tests.yml` and `reusable-create-release.yml` workflows use `GITHUB_TOKEN` automatically - you don't need to pass it explicitly.

### PAT_TOKEN

Personal Access Token required for PR creation.

**Why needed?**
- `GITHUB_TOKEN` can't create PRs that trigger workflows
- PAT_TOKEN allows release PRs to trigger tests

**How to create:**
1. Go to https://github.com/settings/tokens/new
2. Select scopes: `repo`, `workflow`
3. Generate token
4. Add to repository secrets as `PAT_TOKEN`

**Security note:** Use a bot account or dedicated automation account for PAT_TOKEN.

---

## Troubleshooting

### Tests not running

Check:
- Workflow file is in `.github/workflows/`
- File has `.yml` extension
- Secrets are configured
- Branch protection allows workflows

### Release PR not created

Check:
- `PAT_TOKEN` is configured with correct scopes
- Commit messages follow conventional format
- Project uses hatch for versioning
- `__version__` exists in `__init__.py`

### Coverage check failing

Check:
- Tests generate `coverage.xml`
- Hatch is configured for coverage
- `coverage-threshold` is reasonable

---

---

## Advanced Usage

For advanced patterns like matrix testing, parallel execution, custom workflows, and monorepo support, check the examples in the repository or refer to the GitHub Actions documentation.

````
