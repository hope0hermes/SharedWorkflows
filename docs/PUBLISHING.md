# Publishing Guide: From Code to Package Distribution

This guide covers everything you need to know about publishing Python packages using SharedWorkflows. It includes a crash tutorial for the complete release process.

## Table of Contents

1. [Publishing Crash Tutorial](#publishing-crash-tutorial)
2. [Concepts & Terminology](#concepts--terminology)
3. [GitHub Packages vs PyPI](#github-packages-vs-pypi)
4. [Setup & Configuration](#setup--configuration)
5. [How Publishing Works](#how-publishing-works)
6. [User Installation Guide](#user-installation-guide)
7. [Troubleshooting](#troubleshooting)
8. [Migrating to PyPI](#migrating-to-pypi-future)

---

## Publishing Crash Tutorial

### The 60-Second Version

**What happens when you make a commit?**

```
You make code changes
    ↓
Commit with conventional message: "feat: new feature"
    ↓
Push to main (after PR merge)
    ↓
SharedWorkflows CI runs tests
    ↓
Version automatically bumped: 1.2.0 → 1.3.0
    ↓
GitHub Release created: v1.3.0
    ↓
📦 Package built and published to GitHub Packages
    ↓
✅ Users can install: pip install your-package==1.3.0
```

**You don't do anything special for publishing** - it's completely automated after you merge to main!

### Complete Release Process (Step by Step)

#### Step 1: Make Code Changes

```bash
# Make changes to your code
nano src/my_package/core.py

# Commit with conventional message
git commit -m "feat: add new metric calculator

This adds a new calculator for analyzing performance metrics."
```

#### Step 2: Create a Pull Request

```bash
git push origin feature-branch
# Create PR on GitHub, get it reviewed and approved
```

#### Step 3: Merge to Main

- Click "Merge" on the PR
- SharedWorkflows automatically kicks in:
  - ✓ Runs tests
  - ✓ Runs linting
  - ✓ Validates conventional commits
  - ✓ Bumps version (based on conventional commit type)
  - ✓ Updates CHANGELOG.md
  - ✓ Creates GitHub Release

#### Step 4: Automatic Publishing

When the GitHub Release is created:
- ✓ Package is built with `hatch build`
- ✓ Distributions created (`.whl` and `.tar.gz`)
- ✓ Published to GitHub Packages using `twine`
- ✓ Available for installation

**All automatic** - you don't need to do anything! 🎉

### How Version Bumping Works

SharedWorkflows uses conventional commits to determine version bumps:

| Commit Type | Version Change | Example |
|------------|---|---|
| `fix:` | Patch (1.2.0 → 1.2.1) | `fix: resolve rendering bug` |
| `feat:` | Minor (1.2.0 → 1.3.0) | `feat: add dark mode support` |
| `feat!:` or `fix!:` | Major (1.2.0 → 2.0.0) | `feat!: redesign API` |
| `chore:`, `docs:`, `style:` | No version bump | `docs: update README` |

**TL;DR:** Use `fix:` for bug fixes, `feat:` for new features, add `!` for breaking changes.

---

## Concepts & Terminology

### Essential Terms

| Term | Meaning | Example |
|------|---------|---------|
| **Package** | Your Python code/library | `strava_analyzer` |
| **Version** | Release identifier (semantic) | `1.2.3` or `v1.2.3` |
| **Build** | Create distributable files | `hatch build` creates `.whl` and `.tar.gz` |
| **Wheel** | Binary distribution (pre-compiled) | `strava_analyzer-1.2.3-py3-none-any.whl` |
| **Source Distribution** | Source code archive | `strava_analyzer-1.2.3.tar.gz` |
| **Registry** | Storage for packages | GitHub Packages or PyPI |
| **Publish** | Upload to registry | Make available for `pip install` |
| **Token** | Authentication credential | Used by automated workflows |
| **GitHub Release** | Tagged version in git | "v1.2.3" with release notes |

### The Publishing Flow

```
Source Code
    ↓
  Build (hatch build)
    ↓
Distribution Files (.whl + .tar.gz)
    ↓
Validation (twine check)
    ↓
Registry Upload (twine upload)
    ↓
Available on GitHub Packages / PyPI
    ↓
Users can pip install
```

### What Gets Published

When you publish `strava-analyzer v1.2.3`, two files are created and uploaded:

1. **Wheel** (Binary distribution)
   - File: `strava_analyzer-1.2.3-py3-none-any.whl`
   - Size: Smaller (~500 KB)
   - Install time: Faster (no compilation)
   - Preferred format

2. **Source Distribution** (Source archive)
   - File: `strava_analyzer-1.2.3.tar.gz`
   - Size: Larger (~2 MB)
   - Install time: Slower (must compile)
   - Fallback if wheel unavailable

Both are uploaded automatically; `pip` picks the best one.

---

## GitHub Packages vs PyPI

### Quick Comparison

| Feature | GitHub Packages | PyPI |
|---------|-----------------|------|
| **Authentication** | Uses `GITHUB_TOKEN` (automatic) | Requires manual token setup |
| **Scope** | Private to your GitHub (user/org) | Global namespace (must be unique) |
| **Discovery** | Private by default | Public & searchable |
| **Installation** | Requires pip config | Works out of the box |
| **Cost** | Free for all repos | Free for public packages |
| **Best for** | Private/personal projects | Public open-source projects |
| **Learning curve** | Easier (already on GitHub) | More complex (separate account) |

### GitHub Packages: Perfect for Your Use Case

**Advantages:**
- ✅ No additional account needed (use GitHub)
- ✅ Integrated with your existing repos
- ✅ Private by default (you control visibility)
- ✅ Authentication automatic in CI/CD
- ✅ Zero cost
- ✅ Easy to set up

**When to use:**
- Internal projects for your organization
- Personal packages
- Pre-release testing
- Private dependencies

### PyPI: For Public Open-Source

**Advantages:**
- ✅ Globally discoverable (`pip search`)
- ✅ Community-standard registry
- ✅ Single global namespace
- ✅ More exposure

**When to use:**
- Public open-source projects
- Want maximum discoverability
- Plan to become popular

**Note:** You can always start with GitHub Packages and migrate to PyPI later!

---

## Setup & Configuration

### For Package Maintainers

If you're using SharedWorkflows, you need to:

#### 1. Add Publish Workflow to Your Repository

Create `.github/workflows/publish.yml`:

```yaml
name: Publish to GitHub Packages

on:
  release:
    types: [published]

jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: github
    secrets:
      PUBLISH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**That's it!** No additional configuration needed.

#### 2. Configure Personal Access Token (PAT) for Release Automation

**Important:** GitHub Actions using `GITHUB_TOKEN` cannot trigger other workflows (this prevents infinite loops). To enable the automatic publish workflow after releases are created, you need to use a Personal Access Token.

**Steps to set up PAT:**

1. **Create a Personal Access Token (Classic)**:
   - Go to GitHub Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Name: `<YourRepo> Release Automation`
   - Expiration: No expiration (or set as preferred)
   - Select scopes:
     - ✓ `repo` (full control of private repositories)
     - ✓ `workflow` (update GitHub Action workflows)
   - Click "Generate token" and copy it

2. **Add PAT as Repository Secret**:
   - Go to your repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `PAT_TOKEN`
   - Value: Paste your PAT
   - Click "Add secret"

3. **Update Create Release Workflow**:

Edit `.github/workflows/create-release.yml` to use the PAT:

```yaml
name: Create Release

on:
  push:
    branches: [ main ]

jobs:
  create-release:
    permissions:
      contents: write
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-create-release.yml@main
    secrets:
      github-token: ${{ secrets.PAT_TOKEN }}  # Use PAT instead of GITHUB_TOKEN
```

**Why is this needed?**
- Using `GITHUB_TOKEN`: Release is created but publish workflow doesn't trigger
- Using `PAT_TOKEN`: Release is created AND publish workflow triggers automatically

**Security Note:** PATs have broader permissions than `GITHUB_TOKEN`. Store them securely as repository secrets and never commit them to code.

#### 3. Verify Your `pyproject.toml`

Ensure your project is configured for publishing:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "your-package-name"
version = "1.0.0"  # Managed by hatch
description = "Your package description"
readme = "README.md"
requires-python = ">=3.11"
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]
```

#### 3. (Optional) Configure Future PyPI Publishing

When you're ready, create a PyPI account and add this to your repository secrets:
- Go to https://pypi.org and create an account
- Create an API token
- Add as GitHub secret: `PYPI_API_TOKEN`

Then update `.github/workflows/publish.yml`:

```yaml
jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: pypi  # Changed
    secrets:
      PUBLISH_TOKEN: ${{ secrets.PYPI_API_TOKEN }}  # Changed
```

### For Package Users

You need to configure pip to find packages on GitHub Packages.

#### One-Time Setup

Create or edit `~/.pip/pip.conf`:

```ini
[global]
# Primary index: GitHub Packages (for your packages)
index-url = https://pip.pkg.github.com/hope0hermes/simple/

# Fallback: PyPI (for public packages)
extra-index-url = https://pypi.org/simple/
```

**What this does:**
- pip searches GitHub Packages first (for packages by hope0hermes)
- Falls back to PyPI for everything else
- You can install both private and public packages seamlessly

#### Install Packages Normally

Once configured, installing is normal:

```bash
# Install your package
pip install strava-analyzer

# Install specific version
pip install strava-analyzer==1.2.3

# Install with constraints
pip install strava-analyzer>=1.2.0,<2.0.0

# Install in project
pip install -e .  # Current project
pip install strava-analyzer pandas requests  # Multiple packages
```

#### Authentication for Private Packages

If you need to install a private package:

```bash
# Option 1: Use GitHub token (recommended)
export GITHUB_TOKEN=your_github_token
pip install --index-url https://__token__:$GITHUB_TOKEN@pip.pkg.github.com/hope0hermes/simple/ strava-analyzer

# Option 2: Configure in pip.conf (less secure)
[global]
index-url = https://__token__:YOUR_TOKEN@pip.pkg.github.com/hope0hermes/simple/
```

---

## How Publishing Works

### Automatic Publishing Flow

When you merge a PR to main:

#### 1. **Conventional Commit Analysis**
   - GitHub Actions examines commit messages
   - Identifies type: `fix`, `feat`, `feat!`, `chore`, etc.
   - Determines version bump: patch, minor, or major

#### 2. **Version Bump**
   - Updates version in `src/your_package/__init__.py`
   - Creates commit: `chore: bump version to 1.3.0`
   - Creates PR with version change
   - **You review and merge** the auto-generated PR

#### 3. **GitHub Release Creation**
   - When version PR is merged
   - Creates git tag: `v1.3.0`
   - Triggers GitHub Release workflow
   - Generates release notes from changelog

#### 4. **Package Publishing**
   - Release creation triggers `reusable-publish.yml`
   - `python-publish` action runs:
     - Builds wheel and source distribution
     - Validates package metadata
     - Uploads to GitHub Packages
   - **Package now available for installation**

### Manual Publishing (If Needed)

If you need to publish manually:

```bash
# 1. Build locally
pip install hatch
hatch build

# 2. Check the build
ls -lh dist/

# 3. Validate
pip install twine
twine check dist/*

# 4. Upload to GitHub Packages
export GITHUB_TOKEN=your_token
twine upload \
  --repository-url https://pip.pkg.github.com/your_username/simple/ \
  dist/*
```

---

## User Installation Guide

### First Time Setup (One-Time)

1. **Create/Edit pip configuration file**

   macOS/Linux:
   ```bash
   nano ~/.pip/pip.conf
   ```

   Windows:
   ```bash
   notepad %APPDATA%\pip\pip.ini
   ```

2. **Add GitHub Packages as primary index**

   ```ini
   [global]
   index-url = https://pip.pkg.github.com/hope0hermes/simple/
   extra-index-url = https://pypi.org/simple/
   ```

3. **Save and close**

   Now pip knows to look on GitHub Packages!

### Installing Packages

#### Standard Installation

```bash
# Latest version
pip install strava-analyzer

# Specific version
pip install strava-analyzer==1.2.3

# Version range
pip install "strava-analyzer>=1.2.0,<2.0.0"

# Pre-release
pip install --pre strava-analyzer
```

#### In Requirements Files

```bash
# requirements.txt
strava-analyzer>=1.2.0
pandas>=2.0.0
requests>=2.31.0
```

```bash
# pyproject.toml
[project]
dependencies = [
    "strava-analyzer>=1.2.0",
    "pandas>=2.0.0",
]
```

#### In Docker

```dockerfile
# Dockerfile
FROM python:3.12-slim

# Copy pip config into image
COPY pip.conf /root/.pip/pip.conf

# Install packages (will find strava-analyzer on GitHub Packages)
RUN pip install strava-analyzer pandas
```

### Checking Available Versions

To see what versions are published:

```bash
# List all versions
pip index versions strava-analyzer

# Output:
# Available versions:
#   1.0.0
#   1.1.0
#   1.2.0
#   1.2.3 (latest)
```

---

## Troubleshooting

### Publishing Issues

#### ❌ Publishing Fails: `403 Forbidden`

**Cause:** Missing permissions or authentication issue

**Solution:**
```yaml
# Ensure permissions are set in workflow
jobs:
  publish:
    permissions:
      packages: write  # Add this!
```

#### ❌ Publishing Fails: `File already exists`

**Cause:** Package with same version already published (can't republish)

**Solution:**
1. Verify version wasn't accidentally published before
2. Bump version and try again
3. Versions are immutable - once published, they can't be changed

#### ❌ Publishing Fails: `401 Unauthorized`

**Cause:** Invalid or missing authentication token

**Solution:**
1. Verify token is passed correctly:
   ```yaml
   secrets:
     PUBLISH_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # Must use GITHUB_TOKEN for GitHub Packages
   ```
2. Check token has correct permissions
3. For PyPI: verify API token is correct

#### ❌ Publishing Fails: `Package validation failed`

**Cause:** Metadata issues in `pyproject.toml`

**Solution:**
```bash
# Check locally first
hatch build
twine check dist/*

# Fix any errors reported, then retry
```

### Installation Issues

#### ❌ Installation Fails: `No matching distribution found`

**Cause:** pip not configured for GitHub Packages OR package doesn't exist

**Solution:**

Check configuration:
```bash
cat ~/.pip/pip.conf
# Should have GitHub Packages index-url
```

Check package name:
```bash
# Verify exact package name on GitHub Packages
# (may use underscores instead of hyphens)
```

#### ❌ Installation Fails: `401 Unauthorized`

**Cause:** Missing GitHub authentication for private packages

**Solution:**

Option 1 - Use GitHub token (recommended):
```bash
export GITHUB_TOKEN=your_token_here
pip install strava-analyzer
```

Option 2 - Configure pip with token (less secure):
```ini
# ~/.pip/pip.conf
[global]
index-url = https://__token__:YOUR_TOKEN@pip.pkg.github.com/hope0hermes/simple/
```

#### ❌ Installation Fails: `ERROR: Could not find a version that matches...`

**Cause:** Version doesn't exist or network issue

**Solution:**
```bash
# Check available versions
pip index versions strava-analyzer

# Try upgrading pip/setuptools
pip install --upgrade pip setuptools

# Try again
pip install strava-analyzer==1.2.3
```

### Debugging

#### View Published Packages

Go to: `https://github.com/hope0hermes?tab=packages`

#### View Package Details

Go to: `https://github.com/hope0hermes/StravaAnalyzer/packages/1234567`

#### Check Workflow Logs

1. Go to your repository
2. Click "Actions"
3. Click "Publish to GitHub Packages" workflow
4. View logs for detailed information

#### Manual Publishing Test

```bash
# Build locally
hatch build

# Validate before uploading
twine check dist/*

# Dry run (don't actually upload)
twine upload --repository testpypi dist/* --verbose

# If successful, upload for real
twine upload --repository github dist/*
```

---

## Migrating to PyPI (Future)

When you're ready to publish on PyPI (the public registry), follow these steps:

### Step 1: Create PyPI Account

1. Go to https://pypi.org
2. Click "Register"
3. Create account (must use globally unique package name)
4. Verify email

### Step 2: Create API Token

1. Go to https://pypi.org/manage/account/
2. Click "Add API token"
3. Choose scope: "Entire account" (recommended for now)
4. Copy token

### Step 3: Add Token to GitHub Secrets

1. Go to your repository Settings
2. Click "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Name: `PYPI_API_TOKEN`
5. Paste your PyPI token
6. Save

### Step 4: Update Publish Workflow

Change `.github/workflows/publish.yml`:

```yaml
# Before (GitHub Packages):
jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: github
    secrets:
      PUBLISH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# After (PyPI):
jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: pypi
    secrets:
      PUBLISH_TOKEN: ${{ secrets.PYPI_API_TOKEN }}
```

### Step 5: Update Installation Instructions

Users can now install without any pip configuration:

```bash
pip install your-package
```

### Important Considerations

⚠️ **PyPI Package Names Are Permanent**
- Once a name is registered, it's yours forever
- Consider naming carefully
- Examples: `strava-analyzer`, `strava_analyzer` (normalized to same)

⚠️ **Versions Are Immutable**
- Once version `1.2.3` is published, you can't change it
- If you find a bug, bump to `1.2.4`

⚠️ **You Can Yank (Hide) Versions**
- If you find critical bugs
- Go to PyPI package page → Version history → Yank version
- Users can still install if they explicitly request it
- Prevents accidental installation of broken version

---

## Best Practices

### Versioning

✅ **Do:**
- Use semantic versioning: Major.Minor.Patch
- Document changes in CHANGELOG.md
- Tag releases with git tags
- Use conventional commits

❌ **Don't:**
- Skip versions
- Use non-standard version formats
- Publish same version twice

### Publishing

✅ **Do:**
- Publish automatically from CI/CD
- Test publishing to GitHub Packages first
- Build locally before pushing
- Validate metadata with `twine check`

❌ **Don't:**
- Publish manually (error-prone)
- Publish from feature branches
- Delete published versions
- Publish without tests passing

### Security

✅ **Do:**
- Use GITHUB_TOKEN for GitHub Packages (automatic)
- Protect PyPI tokens as secrets
- Review code before publishing
- Use token with minimal scope

❌ **Don't:**
- Commit tokens to git
- Use same token everywhere
- Share tokens with other developers
- Publish untested code

---

## FAQ

**Q: Do I need to set up anything to use the publishing workflow?**

A: Just add the `publish.yml` workflow file to your repository. Everything else is automatic!

**Q: What if I want to publish to PyPI instead of GitHub Packages?**

A: Easy! Create PyPI account, add token to secrets, and update the registry in your workflow.

**Q: Can I publish to both GitHub Packages and PyPI?**

A: Yes! Create two workflow files (one for each registry) or duplicate the publish.yml with different triggers.

**Q: What happens if the tests fail?**

A: Publishing only triggers after GitHub Release is created, which only happens after tests pass. Safe!

**Q: Can I manually trigger publishing?**

A: Yes, add `workflow_dispatch` to the workflow, but it's not recommended.

**Q: What if I publish the wrong version by mistake?**

A: For GitHub Packages, delete the package and republish. For PyPI, use the "Yank" feature.

**Q: How do I know which versions are published?**

A: Check GitHub Packages page or use `pip index versions package-name`.

---

## Related Documentation

- [GitHub Packages Python Guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-python-registry)
- [Python Packaging Guide](https://packaging.python.org/)
- [Twine Documentation](https://twine.readthedocs.io/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [PyPI Help](https://pypi.org/help/)
