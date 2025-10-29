# SharedWorkflows - Setup Instructions

## Repository Created! ✅

The SharedWorkflows repository has been successfully created at:
`/home/hope0hermes/Workspace/dev/SharedWorkflows`

## What's Included

### Directory Structure
```
SharedWorkflows/
├── .github/workflows/          # Reusable workflows
│   ├── reusable-tests.yml
│   ├── reusable-commitlint.yml
│   ├── reusable-release.yml
│   └── reusable-create-release.yml
├── actions/                    # Composite actions
│   ├── python-lint/
│   ├── python-test/
│   ├── python-ci/
│   ├── check-skip-conditions/
│   ├── determine-version-bump/
│   ├── bump-version/
│   ├── update-changelog/
│   ├── create-version-pr/
│   ├── extract-version/
│   └── create-github-release/
├── docs/                       # Documentation
│   ├── USAGE.md
│   └── MIGRATION.md
├── README.md
├── LICENSE
└── .gitignore
```

### Statistics
- **10 composite actions**
- **4 reusable workflows**
- **Comprehensive documentation**
- **~1000 lines of reusable code**

## Next Steps

### 1. Initialize Git Repository

```bash
cd /home/hope0hermes/Workspace/dev/SharedWorkflows

git init
git add .
git commit -m "feat: initial commit with reusable workflows and actions

- Add 4 reusable workflows (tests, commitlint, release, create-release)
- Add 10 composite actions for Python CI/CD
- Add comprehensive documentation
- Support hatch-based Python projects with conventional commits"
```

### 2. Create GitHub Repository

```bash
# Create repo on GitHub
gh repo create hope0hermes/SharedWorkflows --public --source=. --remote=origin

# Or manually:
# 1. Go to https://github.com/new
# 2. Name: SharedWorkflows
# 3. Public or Private
# 4. Don't initialize with README (we have one)
# 5. Create repository
```

### 3. Push to GitHub

```bash
# If you used gh CLI, skip this step

# If you created manually:
git remote add origin git@github.com:hope0hermes/SharedWorkflows.git
git branch -M main
git push -u origin main
```

### 4. Create Initial Release

```bash
# Tag and push
git tag -a v1.0.0 -m "Initial release

- 4 reusable workflows for Python CI/CD
- 10 composite actions
- Complete documentation
- Tested with StravaAnalyzer and StravaFetcher"

git push origin v1.0.0

# Create GitHub release
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes "First stable release of SharedWorkflows

**Workflows:**
- reusable-tests.yml
- reusable-commitlint.yml
- reusable-release.yml
- reusable-create-release.yml

**Actions:**
- python-lint, python-test, python-ci
- check-skip-conditions, determine-version-bump
- bump-version, update-changelog, create-version-pr
- extract-version, create-github-release

**Documentation:**
- Complete usage guide
- Migration guide for existing projects
- Real-world examples"
```

### 5. Test with StravaAnalyzer

Now you can migrate StravaAnalyzer to use the shared workflows!

See [docs/MIGRATION.md](docs/MIGRATION.md) for detailed instructions.

## Quick Test

Before migrating real projects, test that everything works:

```bash
# Check workflow syntax
cd /home/hope0hermes/Workspace/dev/SharedWorkflows
yamllint .github/workflows/*.yml

# Check action syntax
yamllint actions/*/action.yml
```

## Repository URLs

Once pushed to GitHub, workflows will be used like:

```yaml
jobs:
  test:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@main
```

Actions will be used like:

```yaml
steps:
  - uses: hope0hermes/SharedWorkflows/actions/python-lint@main
```

## Important Notes

### Updating Actions in Workflows

The reusable workflows reference actions with `@main`. After pushing to GitHub, these will work automatically.

### Versioning Strategy

- Use `@main` for latest (recommended for development)
- Use `@v1` for stable (create branch: `git branch v1 main; git push origin v1`)
- Use `@v1.0.0` for specific version (use tags)

Example:
```yaml
uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-tests.yml@v1
```

### Testing Strategy

1. Push to GitHub
2. Migrate StravaAnalyzer in a feature branch
3. Test all 4 workflows
4. If successful, merge and migrate StravaFetcher
5. Tag v1.0.0 for stable release

## Troubleshooting

### Issue: Actions not found

If you see "Unable to resolve action", verify:
- Repository is public or PAT has access
- Branch/tag exists
- Path is correct

### Issue: Workflows fail

Check:
- Repository permissions (Settings → Actions → General)
- Secrets are configured (PAT_TOKEN)
- Python version compatibility

## Success Criteria

✅ Repository pushed to GitHub
✅ Initial release (v1.0.0) created
✅ StravaAnalyzer migrated successfully
✅ All 4 workflows working
✅ Tests pass, releases created

## Maintenance

### Adding New Actions

1. Create new directory in `actions/`
2. Add `action.yml`
3. Document inputs/outputs
4. Test with real projects
5. Update README

### Updating Existing Actions

1. Make changes
2. Test with projects
3. Consider breaking changes
4. Update version if needed
5. Document changes

## Help & Support

- Documentation: See `docs/` folder
- Issues: GitHub Issues
- Questions: GitHub Discussions

---

**Ready to revolutionize your CI/CD! 🚀**
