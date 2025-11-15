# SharedWorkflows

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/hope0hermes/SharedWorkflows/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Reusable GitHub Actions workflows and composite actions for Python projects. Provides a complete CI/CD pipeline with testing, linting, automated releases, and more.

## 🚀 Quick Start

### For Python Projects Using Hatch

Replace your existing workflows with these simple calls:

**`.github/workflows/tests.yml`**
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
      package-name: "my_package"
      coverage-threshold: 80
```

**`.github/workflows/commitlint.yml`**
```yaml
name: Lint Commit Messages

on:
  pull_request:
    branches: [ main ]

jobs:
  commitlint:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-commitlint.yml@main
```

**`.github/workflows/release.yml`**
```yaml
name: Release

on:
  push:
    branches: [ main ]

jobs:
  release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-release.yml@main
    with:
      package-path: "src/my_package/__init__.py"
    secrets:
      PAT_TOKEN: ${{ secrets.PAT_TOKEN }}
```

**`.github/workflows/create-release.yml`**
```yaml
name: Create Release

on:
  push:
    branches: [ main ]

jobs:
  create-release:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-create-release.yml@main
```

**`.github/workflows/publish.yml`**
```yaml
name: Publish Package

on:
  release:
    types: [published]

jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: custom  # Options: github, pypi, custom
      custom-registry-url: ${{ secrets.DEVPI_URL }}  # For custom registries
      custom-registry-username: ${{ secrets.DEVPI_USERNAME }}
    secrets:
      PUBLISH_TOKEN: ${{ secrets.DEVPI_PASSWORD }}
```

> **💡 New**: Custom registry support! Publish to private PyPI-compatible indexes like Devpi.
> See [Devpi Integration Guide](docs/DEVPI_INTEGRATION.md) for setup instructions.

**Result**: Complete CI/CD automation from code to published package in ~50 lines total! 🎉

---

## 📦 What's Included

### Reusable Workflows

| Workflow | Purpose | Lines Saved |
|----------|---------|-------------|
| `reusable-tests.yml` | Run linting and tests with coverage | ~60 lines |
| `reusable-commitlint.yml` | Validate conventional commits | ~80 lines |
| `reusable-release.yml` | Automated version bumping | ~150 lines |
| `reusable-create-release.yml` | Create GitHub releases | ~70 lines |
| `reusable-publish.yml` | Publish to PyPI or custom registries | ~80 lines |

### Composite Actions

**Testing Actions:**
- `python-lint` - Ruff, mypy, pylint, pydocstyle
- `python-test` - Pytest with coverage
- `python-ci` - Combined linting + testing

**Release & Publishing Actions:**
- `check-skip-conditions` - Skip logic for version bumps
- `determine-version-bump` - Semantic version analysis
- `bump-version` - Version bumping with hatch
- `update-changelog` - CHANGELOG.md updates
- `create-version-pr` - PR creation for version bumps
- `extract-version` - Extract version from commits
- `create-github-release` - GitHub release creation
- `python-publish` - Build and publish to PyPI or custom registries

---

## 🎯 Features

✅ **Zero Configuration** - Works out of the box for Python/hatch projects
✅ **Fully Automated** - Version bumping, changelog updates, releases
✅ **Conventional Commits** - Semantic versioning from commit messages
✅ **Flexible** - Use complete workflows OR individual actions
✅ **Efficient** - Smart skip logic, concurrency control
✅ **Well Documented** - Every action and workflow documented
✅ **Battle Tested** - Used in production by StravaAnalyzer and StravaFetcher

---

## 📚 Documentation

- [Usage Guide](docs/USAGE.md) - Detailed usage examples
- [Migration Guide](docs/MIGRATION.md) - Migrate existing projects
- [Publishing Guide](docs/PUBLISHING.md) - Package publishing & distribution
- [Devpi Integration](docs/DEVPI_INTEGRATION.md) - Private package index setup
- [Ruleset Configuration](docs/RULESET_CONFIGURATION.md) - Branch protection and ruleset setup
- [Testing Guide](TESTING.md) - How to test the workflows
- [Version Management](docs/VERSION_MANAGEMENT.md) - How to release new versions
- [Changelog](CHANGELOG.md) - Version history and changes

> **💡 For Contributors**: Test workflow changes in [SharedWorkflows-TestHarness](https://github.com/hope0hermes/SharedWorkflows-TestHarness) to avoid polluting production repos.

---

## 🔧 Requirements

- Python 3.10+
- Hatch for package management
- Conventional commit messages
- PAT_TOKEN secret for PR creation (release workflow)

---

## 💡 Examples

### Use Individual Actions

```yaml
jobs:
  custom-ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Custom pre-check
      - name: Verify dependencies
        run: ./scripts/check-deps.sh

      # Reusable linting action
      - name: Lint code
        uses: hope0hermes/SharedWorkflows/actions/python-lint@main
        with:
          python-version: "3.12"

      # Custom validation
      - name: Validate schemas
        run: python scripts/validate.py

      # Reusable testing action
      - name: Run tests
        uses: hope0hermes/SharedWorkflows/actions/python-test@main
        with:
          coverage-threshold: 90
```

### Parallel Testing

```yaml
jobs:
  lint:
    uses: hope0hermes/SharedWorkflows/actions/python-lint@main

  test:
    uses: hope0hermes/SharedWorkflows/actions/python-test@main
```

### Matrix Testing

```yaml
jobs:
  test:
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    steps:
      - uses: actions/checkout@v4
      - uses: hope0hermes/SharedWorkflows/actions/python-test@main
        with:
          python-version: ${{ matrix.python-version }}
```

---

## 🤝 Contributing

Contributions welcome! Please:
1. Follow conventional commits
2. Add tests for new actions
3. Update documentation
4. Test with real projects

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 🙏 Acknowledgments

Built to support StravaAnalyzer and StravaFetcher projects, designed to be useful for the wider Python community.

---

## 📮 Support

- Issues: [GitHub Issues](https://github.com/hope0hermes/SharedWorkflows/issues)
- Discussions: [GitHub Discussions](https://github.com/hope0hermes/SharedWorkflows/discussions)

---

**Made with ❤️ for the Python community**
