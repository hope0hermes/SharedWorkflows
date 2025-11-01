#!/bin/bash
#
# Verify Branch Rulesets
#
# This script checks that all SharedWorkflows-consuming repositories
# have consistent branch rulesets configured.
#
# Usage: ./verify-rulesets.sh [--compare REPO1 REPO2] [--fix]
#
# Examples:
#   ./verify-rulesets.sh                                    # List all rulesets
#   ./verify-rulesets.sh --compare repo1 repo2             # Compare two rulesets
#   ./verify-rulesets.sh --fix                              # (future) Auto-fix differences

set +e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repositories to verify
REPOS=(
  "hope0hermes/StravaAnalyzer"
  "hope0hermes/SharedWorkflows-TestHarness"
  "hope0hermes/StravaFetcher"
)

# Expected ruleset configuration
EXPECTED_RULESET_NAME="main protection"
EXPECTED_CHECKS=(
  "commitlint / Lint Commit Messages"
  "test / Lint"  # Will check if this pattern matches
  "test / Test"  # Will check if this pattern matches
)

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
  echo -e "${BLUE}=== $1 ===${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# Get ruleset ID by name
get_ruleset_id() {
  local repo="$1"
  local name="$2"
  
  gh api repos/"$repo"/rulesets --jq ".[] | select(.name==\"$name\") | .id" 2>/dev/null || echo ""
}

# Get ruleset details
get_ruleset_details() {
  local repo="$1"
  local ruleset_id="$2"
  
  gh api repos/"$repo"/rulesets/"$ruleset_id" 2>/dev/null || echo ""
}

# Extract status checks from ruleset
get_status_checks() {
  local repo="$1"
  local ruleset_id="$2"
  
  gh api repos/"$repo"/rulesets/"$ruleset_id" \
    --jq '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[] | .context' \
    2>/dev/null || echo ""
}

# Compare two rulesets
compare_rulesets() {
  local repo1="$1"
  local repo2="$2"
  
  local id1=$(get_ruleset_id "$repo1" "$EXPECTED_RULESET_NAME")
  local id2=$(get_ruleset_id "$repo2" "$EXPECTED_RULESET_NAME")
  
  if [ -z "$id1" ] || [ -z "$id2" ]; then
    print_error "One or both rulesets not found"
    return 1
  fi
  
  print_header "Comparing: $repo1 ↔ $repo2"
  
  local checks1=$(get_status_checks "$repo1" "$id1" | sort)
  local checks2=$(get_status_checks "$repo2" "$id2" | sort)
  
  if [ "$checks1" = "$checks2" ]; then
    print_success "Rulesets match!"
    echo ""
    echo "Status checks:"
    echo "$checks1" | while read -r check; do
      [ -n "$check" ] && echo "  - $check"
    done
  else
    print_error "Rulesets differ!"
    echo ""
    echo "In $repo1:"
    echo "$checks1" | while read -r check; do
      [ -n "$check" ] && echo "  - $check"
    done
    echo ""
    echo "In $repo2:"
    echo "$checks2" | while read -r check; do
      [ -n "$check" ] && echo "  - $check"
    done
  fi
}

# ============================================================================
# Main Functions
# ============================================================================

list_all_rulesets() {
  print_header "Verifying Branch Rulesets"
  
  local total_checked=0
  local total_found=0
  local total_missing=0
  
  for repo in "${REPOS[@]}"; do
    echo -e "Repository: ${BLUE}$repo${NC}"
    
    ((total_checked++))
    
    # Get rulesets
    local rulesets=$(gh api repos/"$repo"/rulesets --jq '.[].id' 2>/dev/null)
    
    if [ -z "$rulesets" ]; then
      print_error "No rulesets found"
      ((total_missing++))
    else
      for ruleset_id in $rulesets; do
        local ruleset_name=$(gh api repos/"$repo"/rulesets/"$ruleset_id" --jq '.name' 2>/dev/null)
        local enforcement=$(gh api repos/"$repo"/rulesets/"$ruleset_id" --jq '.enforcement' 2>/dev/null)
        
        if [ "$ruleset_name" = "$EXPECTED_RULESET_NAME" ]; then
          print_success "Ruleset: $ruleset_name (Enforcement: $enforcement)"
          ((total_found++))
        else
          print_warning "Found ruleset: $ruleset_name (not 'main protection')"
        fi
        
        # Show status checks
        local checks=$(get_status_checks "$repo" "$ruleset_id")
        
        if [ -n "$checks" ]; then
          echo "    Status Checks:"
          echo "$checks" | while read -r check; do
            [ -n "$check" ] && echo "      - $check"
          done
        fi
      done
    fi
    
    echo ""
  done
  
  # Summary
  print_header "Summary"
  echo "Repositories checked: $total_checked"
  echo "With main protection ruleset: $total_found"
  echo "Missing rulesets: $total_missing"
}

show_help() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Verify and manage branch rulesets across SharedWorkflows repositories.

OPTIONS:
  --list              List all rulesets (default)
  --compare REPO1 REPO2
                      Compare rulesets between two repositories
                      Example: --compare owner/repo1 owner/repo2
  --check REPO        Check specific repository
  --help              Show this help message

EXAMPLES:
  $(basename "$0") --list
  $(basename "$0") --compare hope0hermes/StravaAnalyzer hope0hermes/SharedWorkflows-TestHarness
  $(basename "$0") --check hope0hermes/StravaAnalyzer

REQUIREMENTS:
  - GitHub CLI (gh) must be installed and authenticated
  - You must have access to the repositories

For more information, see docs/RULESET_CONFIGURATION.md
EOF
}

# ============================================================================
# Main Script
# ============================================================================

main() {
  # Check if gh is installed
  if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed"
    echo "Install it with: sudo apt-get install gh"
    exit 1
  fi
  
  # Check if authenticated
  if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
  fi
  
  # Parse arguments
  case "${1:-}" in
    --list)
      list_all_rulesets
      ;;
    --compare)
      if [ -z "$2" ] || [ -z "$3" ]; then
        print_error "Usage: --compare REPO1 REPO2"
        exit 1
      fi
      compare_rulesets "$2" "$3"
      ;;
    --check)
      if [ -z "$2" ]; then
        print_error "Usage: --check REPO"
        exit 1
      fi
      print_header "Checking: $2"
      local id=$(get_ruleset_id "$2" "$EXPECTED_RULESET_NAME")
      if [ -n "$id" ]; then
        print_success "Ruleset found (ID: $id)"
        echo ""
        get_status_checks "$2" "$id" | while read -r check; do
          [ -n "$check" ] && echo "  - $check"
        done
      else
        print_error "Ruleset '$EXPECTED_RULESET_NAME' not found"
      fi
      ;;
    --help)
      show_help
      ;;
    "")
      list_all_rulesets
      ;;
    *)
      print_error "Unknown option: $1"
      echo "Run: $(basename "$0") --help"
      exit 1
      ;;
  esac
}

main "$@"
