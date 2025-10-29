# Test Project

This is a test fixture for validating SharedWorkflows actions and workflows.

## Purpose

This project contains:
- **Good code**: Passes all linting and type checking
- **Bad code**: Has intentional linting issues
- **Passing tests**: All assertions pass
- **Failing tests**: Intentionally fail for testing purposes

## Structure

```
src/test_project/
├── __init__.py           # Version definition
├── good_code.py          # Clean, well-formatted code
└── bad_code.py           # Code with linting issues

tests/
├── test_good_code.py     # Passing tests
└── test_failing.py       # Failing tests
```

## Usage

This fixture is used by the SharedWorkflows test suite to validate that actions correctly:
- Detect linting issues
- Run tests and report failures
- Calculate coverage
- Bump versions
- Update changelogs
