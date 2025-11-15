# Using SharedWorkflows with Devpi Private Index

## Overview

The SharedWorkflows publishing infrastructure now supports custom package registries like Devpi. This allows you to publish packages to your private PyPI-compatible index.

## Setup

### 1. Add GitHub Secrets

Add the following secrets to your repository:

- **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name | Value | Description |
|------------|-------|-------------|
| `DEVPI_URL` | `http://144.24.233.179/hope0hermes/dev/` | Your Devpi index URL |
| `DEVPI_USERNAME` | `hope0hermes` | Your Devpi username |
| `DEVPI_PASSWORD` | `<your-password>` | Your Devpi password |

### 2. Update Your Workflow

Update your repository's workflow to use the custom registry option.

## Example Workflows

### Option 1: Using Reusable Workflow

Create or update `.github/workflows/publish.yml`:

```yaml
name: Publish to Devpi

on:
  release:
    types: [published]
  workflow_dispatch:  # Manual trigger for testing

jobs:
  publish:
    name: Publish to Private Index
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: custom
      custom-registry-url: ${{ secrets.DEVPI_URL }}
      custom-registry-username: ${{ secrets.DEVPI_USERNAME }}
      python-version: '3.12'
    secrets:
      PUBLISH_TOKEN: ${{ secrets.DEVPI_PASSWORD }}
```

### Option 2: Using Composite Action Directly

If you need more control, use the action directly:

```yaml
name: Publish to Devpi

on:
  release:
    types: [published]
  workflow_dispatch:

jobs:
  publish:
    name: Publish Package
    runs-on: ubuntu-latest

    steps:
      - name: Publish to Devpi
        uses: hope0hermes/SharedWorkflows/actions/python-publish@main
        with:
          token: ${{ secrets.DEVPI_PASSWORD }}
          registry: custom
          custom-registry-url: ${{ secrets.DEVPI_URL }}
          custom-registry-username: ${{ secrets.DEVPI_USERNAME }}
          python-version: '3.12'

      - name: Success message
        run: |
          echo "✅ Package published to Devpi!"
          echo "Install with:"
          echo "pip install --index-url ${{ secrets.DEVPI_URL }}+simple/ --trusted-host 144.24.233.179 ${{ github.event.repository.name }}"
```

### Option 3: Multi-Registry Publishing

Publish to both PyPI and Devpi:

```yaml
name: Publish Package

on:
  release:
    types: [published]

jobs:
  publish-devpi:
    name: Publish to Devpi (Private)
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: custom
      custom-registry-url: ${{ secrets.DEVPI_URL }}
      custom-registry-username: ${{ secrets.DEVPI_USERNAME }}
    secrets:
      PUBLISH_TOKEN: ${{ secrets.DEVPI_PASSWORD }}

  publish-pypi:
    name: Publish to PyPI (Public)
    needs: publish-devpi  # Publish to Devpi first
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: pypi
    secrets:
      PUBLISH_TOKEN: ${{ secrets.PYPI_TOKEN }}
```

## Installing from Devpi

### In Workflows

To install packages from Devpi in your CI/CD workflows:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies from Devpi
        run: |
          pip install \
            --index-url ${{ secrets.DEVPI_URL }}+simple/ \
            --trusted-host 144.24.233.179 \
            -r requirements.txt

      - name: Run tests
        run: pytest
```

### Locally

```bash
# Single package
pip install --index-url http://144.24.233.179/hope0hermes/dev/+simple/ \
    --trusted-host 144.24.233.179 \
    your-package-name

# With requirements.txt
pip install \
    --index-url http://144.24.233.179/hope0hermes/dev/+simple/ \
    --trusted-host 144.24.233.179 \
    -r requirements.txt

# Or configure pip globally
echo "[global]
index-url = http://144.24.233.179/hope0hermes/dev/+simple/
trusted-host = 144.24.233.179" > ~/.pip/pip.conf
```

## Testing the Integration

### 1. Test Manually First

Before committing workflow changes, test locally:

```bash
# Build your package
python -m build

# Upload to Devpi
export TWINE_REPOSITORY_URL=http://144.24.233.179/hope0hermes/dev/
export TWINE_USERNAME=hope0hermes
export TWINE_PASSWORD=<your-password>
twine upload dist/*
```

### 2. Test Workflow with Manual Trigger

Use `workflow_dispatch` to test without creating a release:

```yaml
on:
  workflow_dispatch:  # Adds "Run workflow" button in GitHub UI
  release:
    types: [published]
```

### 3. Create a Test Release

Create a test release to verify end-to-end:

```bash
git tag v0.0.1-test
git push origin v0.0.1-test
gh release create v0.0.1-test --title "Test Release" --notes "Testing Devpi integration"
```

## Migration from PyPI

If you're migrating from PyPI to Devpi:

### Before (PyPI)
```yaml
jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: pypi
    secrets:
      PUBLISH_TOKEN: ${{ secrets.PYPI_TOKEN }}
```

### After (Devpi)
```yaml
jobs:
  publish:
    uses: hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main
    with:
      registry: custom
      custom-registry-url: ${{ secrets.DEVPI_URL }}
      custom-registry-username: ${{ secrets.DEVPI_USERNAME }}
    secrets:
      PUBLISH_TOKEN: ${{ secrets.DEVPI_PASSWORD }}
```

## Troubleshooting

### Publish fails with authentication error

- Verify `DEVPI_PASSWORD` secret is set correctly
- Test authentication manually:
  ```bash
  ssh oci-vm
  source ~/devpi-venv/bin/activate
  devpi use http://127.0.0.1:3141
  devpi login hope0hermes --password=<your-password>
  ```

### Package upload succeeds but can't install

- Check the URL includes trailing `/` : `http://144.24.233.179/hope0hermes/dev/`
- For pip installs, add `+simple/` suffix: `http://144.24.233.179/hope0hermes/dev/+simple/`
- Ensure `--trusted-host 144.24.233.179` is included

### Workflow can't reach Devpi server

- Verify OCI Security List allows port 80 from GitHub's IP ranges
- Test external connectivity: `curl http://144.24.233.179`
- Check Devpi service: `ssh oci-vm "sudo systemctl status devpi"`

## References

- **Action**: `hope0hermes/SharedWorkflows/actions/python-publish@main`
- **Reusable Workflow**: `hope0hermes/SharedWorkflows/.github/workflows/reusable-publish.yml@main`
- **Devpi Server**: http://144.24.233.179

## Example Repositories

Once set up, these repositories will use Devpi:

- StravaFetcher
- StravaAnalyzer
- SharedWorkflows-TestHarness (if made publishable)
