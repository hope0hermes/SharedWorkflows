# Version Management Guide

This guide explains how to manage versions and releases for SharedWorkflows.

## Overview

SharedWorkflows uses **manual tagging** with semantic versioning:
- **VERSION file** - Contains current version (e.g., `1.0.0`)
- **CHANGELOG.md** - Tracks all changes
- **Git tags** - Mark releases (e.g., `v1.0.0`)
- **GitHub Releases** - Published releases with notes

## Semantic Versioning

SharedWorkflows follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0) - Breaking changes to action inputs/outputs or workflow behavior
- **MINOR** (1.0.0 → 1.1.0) - New actions, new workflow features (backward compatible)
- **PATCH** (1.0.0 → 1.0.1) - Bug fixes, documentation updates (backward compatible)

### Examples

**Breaking Changes (Major):**
- Remove an input parameter from an action
- Change required inputs
- Change output format
- Remove an action or workflow

**New Features (Minor):**
- Add new action
- Add optional input parameter
- Add new workflow
- Add new output (doesn't break existing usage)

**Bug Fixes (Patch):**
- Fix action behavior
- Fix documentation
- Fix test failures
- Security patches

## Release Process

### 1. Check Current Version

```bash
./scripts/version.sh current
```

Or:
```bash
cat VERSION
```

### 2. Update CHANGELOG.md

Before bumping version, document all changes under `## [Unreleased]`:

```markdown
## [Unreleased]

### Added
- New `python-format` action for code formatting
- Support for Python 3.13

### Changed
- Improved error messages in python-test action

### Fixed
- Fixed coverage threshold check in python-test
- Corrected documentation typos

### Removed
- Deprecated `old-action` (use `new-action` instead)
```

**Important:** Always update CHANGELOG.md BEFORE running version bump!

### 3. Decide Version Number

Based on changes:
- Breaking changes? → Major bump (e.g., 1.2.3 → 2.0.0)
- New features? → Minor bump (e.g., 1.2.3 → 1.3.0)
- Only fixes? → Patch bump (e.g., 1.2.3 → 1.2.4)

### 4. Bump Version

```bash
./scripts/version.sh bump 1.1.0
```

This will:
- Update `VERSION` file
- Update version badge in `README.md`
- Move `[Unreleased]` section to `[1.1.0] - YYYY-MM-DD` in CHANGELOG.md
- Add new empty `[Unreleased]` section
- Update comparison links at bottom of CHANGELOG.md

### 5. Review Changes

```bash
git diff
```

Check that:
- ✅ VERSION file has new version
- ✅ README.md badge updated
- ✅ CHANGELOG.md has dated version section
- ✅ CHANGELOG.md has new [Unreleased] section

### 6. Commit Version Bump

```bash
git add VERSION CHANGELOG.md README.md
git commit -m "chore: bump version to 1.1.0"
```

**Important:** Use conventional commit format with `chore:` type.

### 7. Push to Main

```bash
git push origin main
```

Or if on a branch, create PR and merge first.

### 8. Create Git Tag

```bash
./scripts/version.sh tag
```

Or manually:
```bash
git tag -a v1.1.0 -m "Release v1.1.0"
```

### 9. Push Tag

```bash
git push origin v1.1.0
```

**Important:** Don't forget this step! Tags are not pushed by default.

### 10. Create GitHub Release

1. Go to: https://github.com/hope0hermes/SharedWorkflows/releases/new
2. Click "Choose a tag" → select `v1.1.0`
3. Set "Release title" to `Release v1.1.0` or just `v1.1.0`
4. Copy the version section from CHANGELOG.md into description
5. Check "Set as the latest release"
6. Click "Publish release"

### 11. Verify

Check that users can now reference:
```yaml
uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@v1.1.0
```

## Quick Reference Commands

```bash
# Show current version
./scripts/version.sh current

# Bump to new version
./scripts/version.sh bump 1.2.0

# Create and push tag
./scripts/version.sh tag
git push origin v1.2.0

# Or specify version
./scripts/version.sh tag 1.2.0
git push origin v1.2.0
```

## How Users Reference Versions

After releasing, users can reference SharedWorkflows in multiple ways:

### By Branch (Development)
```yaml
uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@main
```
- ✅ Always gets latest changes
- ❌ May break if you make breaking changes
- **Use for:** Testing, development

### By Tag (Recommended for Production)
```yaml
uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@v1.0.0
```
- ✅ Stable, won't change
- ✅ Can track which version projects use
- ❌ Must manually update to get new features
- **Use for:** Production workflows

### By Major Version (If You Maintain Major Version Tags)
```yaml
uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@v1
```
- ✅ Gets latest v1.x.x automatically
- ❌ Requires you to update v1 tag after each release
- **Use for:** Projects that want latest non-breaking updates
- **Note:** Not currently implemented

### By Commit SHA (Maximum Stability)
```yaml
uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@a1b2c3d4
```
- ✅ Completely immutable
- ❌ Hard to track what version it is
- **Use for:** Maximum reproducibility

## Common Scenarios

### Hotfix Release

If you need to quickly fix a bug in production:

```bash
# 1. Fix the bug, commit, push to main
git add .
git commit -m "fix: correct critical bug in python-test action"
git push origin main

# 2. Update CHANGELOG.md with fix under [Unreleased]
# Edit CHANGELOG.md, add to ### Fixed section

# 3. Bump patch version
./scripts/version.sh bump 1.0.1

# 4. Commit, push, tag
git add VERSION CHANGELOG.md README.md
git commit -m "chore: bump version to 1.0.1"
git push origin main
./scripts/version.sh tag
git push origin v1.0.1

# 5. Create GitHub Release
```

### Pre-release Testing

If you want to test changes before official release:

```bash
# 1. Create a release branch
git checkout -b release/v1.1.0

# 2. Bump version with beta suffix (manually edit VERSION file)
echo "1.1.0-beta.1" > VERSION

# 3. Commit and push
git commit -am "chore: prepare v1.1.0-beta.1"
git push origin release/v1.1.0

# 4. Test using branch reference
uses: hope0hermes/SharedWorkflows/...@release/v1.1.0

# 5. When ready, merge to main and release normally
```

### Fixing Version Mistakes

If you pushed the wrong version:

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0

# Create correct version and tag again
```

## Best Practices

1. ✅ **Always update CHANGELOG.md before bumping version**
2. ✅ **Use conventional commits** (`feat:`, `fix:`, `chore:`)
3. ✅ **Test on a real project** before releasing
4. ✅ **Review diff** before committing version bump
5. ✅ **Push tag immediately** after creating it
6. ✅ **Create GitHub Release** for visibility
7. ✅ **Update migration projects** (StravaAnalyzer, StravaFetcher) to use new version
8. ❌ **Don't skip versions** (go 1.0.0 → 1.1.0, not 1.0.0 → 1.5.0)
9. ❌ **Don't delete tags** unless absolutely necessary
10. ❌ **Don't reuse version numbers**

## Troubleshooting

### Version script not found
```bash
chmod +x scripts/version.sh
```

### Tag already exists
```bash
# Delete tag locally and remotely
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# Create correct tag
./scripts/version.sh tag 1.0.0
git push origin v1.0.0
```

### Forgot to push tag
```bash
git push origin v1.0.0
```

### Need to update a release
Go to GitHub Releases, click "Edit" on the release, update description, save.

## Checklist Template

Copy this checklist when doing a release:

```markdown
## Release Checklist for v1.x.x

- [ ] All changes merged to main
- [ ] CHANGELOG.md updated with all changes
- [ ] Version number decided (major/minor/patch)
- [ ] Ran: ./scripts/version.sh bump 1.x.x
- [ ] Reviewed diff (VERSION, CHANGELOG.md, README.md)
- [ ] Committed: git commit -m "chore: bump version to 1.x.x"
- [ ] Pushed: git push origin main
- [ ] Tagged: ./scripts/version.sh tag
- [ ] Pushed tag: git push origin v1.x.x
- [ ] Created GitHub Release
- [ ] Verified tag works in a workflow
- [ ] Updated dependent projects (optional)
```

## Questions?

- Check [SETUP.md](../SETUP.md) for repository setup
- Check [CHANGELOG.md](../CHANGELOG.md) for version history
- See [USAGE.md](USAGE.md) for how users reference versions
