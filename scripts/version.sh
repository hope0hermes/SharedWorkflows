#!/bin/bash
# Version Management Script for SharedWorkflows
#
# This script helps manage versions and changelog entries.
# Since SharedWorkflows is a collection of GitHub Actions (not a Python package),
# version tracking is done via VERSION file and git tags.

set -e

VERSION_FILE="VERSION"
CHANGELOG_FILE="CHANGELOG.md"
README_FILE="README.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Update version in files
update_version_files() {
    local new_version=$1

    echo -e "${GREEN}Updating version to $new_version...${NC}"

    # Update VERSION file
    echo "$new_version" > "$VERSION_FILE"

    # Update README badge
    if [ -f "$README_FILE" ]; then
        sed -i "s/version-[0-9]\+\.[0-9]\+\.[0-9]\+-blue/version-$new_version-blue/g" "$README_FILE"
    fi

    echo -e "${GREEN}✓ Version files updated${NC}"
}

# Update changelog
update_changelog() {
    local new_version=$1
    local date=$(date +%Y-%m-%d)

    echo -e "${GREEN}Updating CHANGELOG.md...${NC}"

    # Replace [Unreleased] with version and date
    sed -i "s/## \[Unreleased\]/## [$new_version] - $date/" "$CHANGELOG_FILE"

    # Add new [Unreleased] section at the top
    sed -i "/## \[$new_version\]/i ## [Unreleased]\n" "$CHANGELOG_FILE"

    # Update comparison links
    sed -i "s|\[Unreleased\]:.*|[Unreleased]: https://github.com/hope0hermes/SharedWorkflows/compare/v$new_version...HEAD\n[$new_version]: https://github.com/hope0hermes/SharedWorkflows/releases/tag/v$new_version|" "$CHANGELOG_FILE"

    echo -e "${GREEN}✓ CHANGELOG.md updated${NC}"
}

# Create git tag
create_tag() {
    local version=$1

    echo -e "${GREEN}Creating git tag v$version...${NC}"
    git tag -a "v$version" -m "Release v$version"
    echo -e "${GREEN}✓ Tag created${NC}"
    echo -e "${YELLOW}Remember to push the tag: git push origin v$version${NC}"
}

# Main command handler
case "$1" in
    current)
        echo "Current version: $(get_current_version)"
        ;;

    bump)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Version number required${NC}"
            echo "Usage: $0 bump <version>"
            echo "Example: $0 bump 1.1.0"
            exit 1
        fi

        new_version=$2
        current_version=$(get_current_version)

        echo -e "${YELLOW}Current version: $current_version${NC}"
        echo -e "${YELLOW}New version: $new_version${NC}"
        echo ""
        read -p "Continue? (y/n) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            update_version_files "$new_version"
            update_changelog "$new_version"

            echo ""
            echo -e "${GREEN}Version bump complete!${NC}"
            echo ""
            echo "Next steps:"
            echo "1. Review the changes: git diff"
            echo "2. Commit: git add VERSION CHANGELOG.md README.md && git commit -m 'chore: bump version to $new_version'"
            echo "3. Create tag: $0 tag $new_version"
            echo "4. Push: git push origin main && git push origin v$new_version"
        else
            echo -e "${YELLOW}Version bump cancelled${NC}"
        fi
        ;;

    tag)
        if [ -z "$2" ]; then
            version=$(get_current_version)
        else
            version=$2
        fi

        create_tag "$version"
        ;;

    *)
        echo "SharedWorkflows Version Management"
        echo ""
        echo "Usage:"
        echo "  $0 current              - Show current version"
        echo "  $0 bump <version>       - Bump version and update files"
        echo "  $0 tag [version]        - Create git tag (uses VERSION file if not specified)"
        echo ""
        echo "Examples:"
        echo "  $0 current"
        echo "  $0 bump 1.1.0"
        echo "  $0 tag"
        exit 1
        ;;
esac
