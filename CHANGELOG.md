# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Reverted to using remote action references (owner/repo/path@ref format) as GitHub Actions requires this format for composite actions in reusable workflows

## [1.0.0] - 2025-10-30

### Fixed
- Fixed reusable workflows to use absolute paths for actions (hope0hermes/SharedWorkflows/actions/*@main) instead of relative paths (./actions/*)

### Added
- Documentation updates for pytest-args parameter
- Clarified GITHUB_TOKEN automatic availability

## [1.0.0] - 2025-10-29

### Added
- Initial release of SharedWorkflows
- 10 composite actions for Python CI/CD:
  - `python-lint` - Run Python linting (ruff, mypy, pylint, pydocstyle)
  - `python-test` - Run pytest with coverage reporting
  - `python-ci` - Combined linting and testing
  - `check-skip-conditions` - Check if CI should be skipped
  - `determine-version-bump` - Determine semantic version bump type
  - `bump-version` - Bump version using hatch
  - `update-changelog` - Update CHANGELOG.md with new version
  - `create-version-pr` - Create PR for version bump
  - `extract-version` - Extract version from commit messages
  - `create-github-release` - Create GitHub release
- 4 reusable workflows:
  - `reusable-tests.yml` - Complete testing pipeline with linting and coverage
  - `reusable-commitlint.yml` - Conventional commit validation
  - `reusable-release.yml` - Automated version bumping and changelog updates
  - `reusable-create-release.yml` - Automated GitHub release creation
- Comprehensive test suite:
  - `test-actions.yml` - Tests for all composite actions
  - `test-workflows.yml` - Tests for reusable workflows
  - Test fixtures with passing and failing scenarios
- Complete documentation:
  - Usage guide with examples
  - Migration guide for existing projects
  - Testing guide
  - Setup instructions

### Features
- Support for Python 3.10+
- Hatch build system integration
- Conventional commit parsing for semantic versioning
- Smart skip conditions ([skip ci], version bump commits)
- Coverage threshold enforcement
- Artifact uploads for coverage reports
- Concurrency control to cancel outdated runs
- Working directory support for monorepos
- Selective test execution via pytest-args
- Local action paths for reliable workflow composition

### Fixed
- GITHUB_TOKEN automatically provided (no need to pass as secret)
- Local action paths (`./actions/`) instead of remote references
- pytest-args support for selective test execution
- Linter exclusions for intentionally bad test code
- Working directory support in version bump actions

[Unreleased]: https://github.com/hope0hermes/SharedWorkflows/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/hope0hermes/SharedWorkflows/releases/tag/v1.0.0
