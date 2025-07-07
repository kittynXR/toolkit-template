#!/bin/bash

# Unity VRChat Package Template Builder
# This script transforms a Unity plugin folder into a release-ready repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    echo "Unity VRChat Package Template Builder"
    echo ""
    echo "Usage: $0 [options] <plugin-directory>"
    echo ""
    echo "Options:"
    echo "  -c, --config <file>    Path to configuration file (default: template-config.json)"
    echo "  -o, --output <dir>     Output directory (default: same as plugin directory)"
    echo "  -i, --interactive      Interactive mode - prompts for configuration values"
    echo "  -f, --force           Overwrite existing files without prompting"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 ./MyUnityPlugin"
    echo "  $0 -c my-config.json -o ./output ./MyUnityPlugin"
    echo "  $0 -i ./MyUnityPlugin"
    exit 1
}

# Parse command line arguments
CONFIG_FILE="$SCRIPT_DIR/template-config.json"
OUTPUT_DIR=""
INTERACTIVE=false
FORCE=false
PLUGIN_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            PLUGIN_DIR="$1"
            shift
            ;;
    esac
done

# Validate arguments
if [ -z "$PLUGIN_DIR" ]; then
    print_error "Plugin directory not specified"
    usage
fi

if [ ! -d "$PLUGIN_DIR" ]; then
    print_error "Plugin directory does not exist: $PLUGIN_DIR"
    exit 1
fi

# Set default output directory if not specified
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$PLUGIN_DIR"
fi

# Function to read JSON value
read_json_value() {
    local file=$1
    local key=$2
    python3 -c "import json; print(json.load(open('$file'))$key)" 2>/dev/null || echo ""
}

# Function to prompt for value
prompt_value() {
    local prompt=$1
    local default=$2
    local value=""
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " value
        value=${value:-$default}
    else
        read -p "$prompt: " value
    fi
    
    echo "$value"
}

# Function to create configuration interactively
create_interactive_config() {
    local temp_config="/tmp/template-config-$$.json"
    
    print_info "Interactive configuration mode"
    echo ""
    
    # Package information
    echo "=== Package Information ==="
    
    # Validate package suffix
    while true; do
        PACKAGE_SUFFIX=$(prompt_value "Package name suffix (will be prefixed with cat.kittyn.)" "")
        if [ -n "$PACKAGE_SUFFIX" ]; then
            break
        else
            print_error "Package suffix cannot be empty. Please enter a valid package name."
        fi
    done
    
    PACKAGE_NAME="cat.kittyn.$PACKAGE_SUFFIX"
    
    # Generate default display name by capitalizing and removing hyphens
    DEFAULT_DISPLAY_NAME=$(echo "$PACKAGE_SUFFIX" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
    
    # Validate display name
    while true; do
        DISPLAY_NAME=$(prompt_value "Display name" "$DEFAULT_DISPLAY_NAME")
        if [ -n "$DISPLAY_NAME" ]; then
            break
        else
            print_error "Display name cannot be empty. Please enter a valid display name."
            DEFAULT_DISPLAY_NAME="My Unity Package"  # Fallback default
        fi
    done
    VERSION=$(prompt_value "Initial version" "1.0.0")
    DESCRIPTION=$(prompt_value "Description" "A Unity package for VRChat")
    
    echo ""
    echo "=== Author Information ==="
    AUTHOR_NAME=$(prompt_value "Author name" "kittyn")
    AUTHOR_EMAIL=$(prompt_value "Author email" "cat@kittyn.cat")
    AUTHOR_URL=$(prompt_value "Author URL" "https://kittyn.cat")
    
    echo ""
    echo "=== Repository Information ==="
    
    # Validate repo owner
    while true; do
        REPO_OWNER=$(prompt_value "GitHub username/organization" "kittynXR")
        if [ -n "$REPO_OWNER" ]; then
            break
        else
            print_error "Repository owner cannot be empty. Please enter a valid GitHub username/organization."
        fi
    done
    
    # Validate repo name  
    while true; do
        REPO_NAME=$(prompt_value "Repository name" "$(basename "$PLUGIN_DIR")")
        if [ -n "$REPO_NAME" ]; then
            break
        else
            print_error "Repository name cannot be empty. Please enter a valid repository name."
        fi
    done
    
    # Validate default branch
    while true; do
        DEFAULT_BRANCH=$(prompt_value "Default branch" "main")
        if [ -n "$DEFAULT_BRANCH" ]; then
            break
        else
            print_error "Default branch cannot be empty. Please enter a valid branch name."
        fi
    done
    
    echo ""
    echo "=== Build Configuration ==="
    echo "Your package will be organized as follows:"
    echo "  Repository: $PACKAGE_SUFFIX/"
    echo "  ├── kittyncat_tools/"
    echo "  │   └── cat.kittyn.$PACKAGE_SUFFIX/    ← Package directory (VPM path)"
    echo "  └── Other files (build scripts, etc.)"
    echo ""
    echo "When installed via UnityPackage, this becomes:"
    echo "  Assets/"
    echo "  └── kittyncat_tools/"
    echo "      └── cat.kittyn.$PACKAGE_SUFFIX/"
    echo ""
    
    # Unity convention: use package name as directory
    ROOT_DIR=$(prompt_value "Package directory name (usually keep default)" "$PACKAGE_NAME")
    
    # Unity-friendly package name (for UnityPackage builds)
    DEFAULT_UNITY_NAME=$(echo "$PACKAGE_SUFFIX" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | sed 's/ //g')
    UNITY_PACKAGE_NAME=$(prompt_value "Unity package name (for UnityPackage builds)" "$DEFAULT_UNITY_NAME")
    
    echo ""
    echo "=== Features ==="
    read -p "Does this package use NDMF? (y/n) [n]: " USE_NDMF
    USE_NDMF=${USE_NDMF:-n}
    USE_NDMF=$([ "$USE_NDMF" = "y" ] && echo "true" || echo "false")
    
    read -p "Does this package use Harmony? (y/n) [n]: " USE_HARMONY
    USE_HARMONY=${USE_HARMONY:-n}
    USE_HARMONY=$([ "$USE_HARMONY" = "y" ] && echo "true" || echo "false")
    
    read -p "Does this package need separate Runtime assembly? (y/n) [n]: " SEPARATE_RUNTIME
    SEPARATE_RUNTIME=${SEPARATE_RUNTIME:-n}
    SEPARATE_RUNTIME=$([ "$SEPARATE_RUNTIME" = "y" ] && echo "true" || echo "false")
    
    echo ""
    echo "=== VCC Project Type ==="
    echo "Choose the VCC project type compatibility:"
    echo "  Any - Works with any Unity project (no VRChat dependency)"
    echo "  VRC - Works with all VRChat project types (Avatar and World)"
    echo "  Avatar - Only for Avatar projects"
    echo "  World - Only for World projects"
    VCC_PROJECT_TYPE=$(prompt_value "VCC Project Type [Any, VRC, Avatar, World]" "Any")
    
    # Validate VCC project type
    if [[ ! "$VCC_PROJECT_TYPE" =~ ^(Any|VRC|Avatar|World)$ ]]; then
        print_warning "Invalid VCC project type '$VCC_PROJECT_TYPE'. Using 'Any'."
        VCC_PROJECT_TYPE="Any"
    fi
    
    # Set VPM dependencies based on project type
    case "$VCC_PROJECT_TYPE" in
        "Avatar")
            VPM_DEPENDENCIES='"com.vrchat.avatars": ">=3.7.0"'
            ;;
        "World")
            VPM_DEPENDENCIES='"com.vrchat.worlds": ">=3.7.0"'
            ;;
        "VRC")
            VPM_DEPENDENCIES='"com.vrchat.base": ">=3.7.0"'
            ;;
        *)
            VPM_DEPENDENCIES='{}'
            ;;
    esac

    # Create configuration JSON
    cat > "$temp_config" <<EOF
{
  "package": {
    "name": "$PACKAGE_NAME",
    "displayName": "$DISPLAY_NAME",
    "version": "$VERSION",
    "description": "$DESCRIPTION",
    "type": "$VCC_PROJECT_TYPE",
    "author": {
      "name": "$AUTHOR_NAME",
      "email": "$AUTHOR_EMAIL",
      "url": "$AUTHOR_URL"
    },
    "unity": "2019.4",
    "unityRelease": "31f1",
    "vpmDependencies": {
      $VPM_DEPENDENCIES
    },
    "dependencies": {},
    "keywords": ["vrchat", "unity", "tool"],
    "license": "MIT",
    "documentationUrl": "https://github.com/$REPO_OWNER/$REPO_NAME#readme",
    "changelogUrl": "https://github.com/$REPO_OWNER/$REPO_NAME/releases",
    "samples": []
  },
  "repository": {
    "owner": "$REPO_OWNER",
    "name": "$REPO_NAME",
    "defaultBranch": "$DEFAULT_BRANCH",
    "ghPagesUrl": "https://$REPO_NAME.kittyn.cat/index.json"
  },
  "build": {
    "rootDirectory": "$ROOT_DIR",
    "unityPackageName": "$UNITY_PACKAGE_NAME",
    "excludePatterns": [
      "*.meta",
      ".git*",
      "*.md",
      "*.yml",
      "*.sh",
      "package-lock.json",
      "node_modules",
      "scripts",
      ".github",
      "source.json"
    ],
    "assemblyDefinitions": {
      "editor": {
        "name": "${ROOT_DIR}.Editor",
        "rootNamespace": "${ROOT_DIR}.Editor",
        "references": [
          "VRC.SDK3A",
          "VRC.SDK3A.Editor"
        ]
      },
      "runtime": {
        "name": "${ROOT_DIR}.Runtime",
        "rootNamespace": "$ROOT_DIR",
        "references": [
          "VRC.SDKBase"
        ]
      }
    }
  },
  "vpm": {
    "id": "$PACKAGE_NAME",
    "url": "https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/v{VERSION}/$PACKAGE_NAME-{VERSION}.zip",
    "includeInVRCListing": true
  },
  "features": {
    "ndmf": $USE_NDMF,
    "harmony": $USE_HARMONY,
    "separateRuntimeAssembly": $SEPARATE_RUNTIME,
    "samples": false
  },
  "automation": {
    "createGitTags": true,
    "createGitHubReleases": true,
    "deployToGitHubPages": true,
    "preserveVersionHistory": true
  }
}
EOF
    
    CONFIG_FILE="$temp_config"
}

# Interactive mode
if $INTERACTIVE; then
    create_interactive_config
fi

# Validate configuration file
if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Read configuration values (skip if interactive mode already set them)
if ! $INTERACTIVE; then
    print_info "Reading configuration from: $CONFIG_FILE"
fi

# Function to replace placeholders in a file
replace_placeholders() {
    local file=$1
    local temp_file="${file}.tmp"
    
    cp "$file" "$temp_file"
    
    # Replace all placeholders
    sed -i "s|{{PACKAGE_NAME}}|$PACKAGE_NAME|g" "$temp_file"
    sed -i "s|{{DISPLAY_NAME}}|$DISPLAY_NAME|g" "$temp_file"
    sed -i "s|{{VERSION}}|$VERSION|g" "$temp_file"
    sed -i "s|{{DESCRIPTION}}|$DESCRIPTION|g" "$temp_file"
    sed -i "s|{{AUTHOR_NAME}}|$AUTHOR_NAME|g" "$temp_file"
    sed -i "s|{{AUTHOR_EMAIL}}|$AUTHOR_EMAIL|g" "$temp_file"
    sed -i "s|{{AUTHOR_URL}}|$AUTHOR_URL|g" "$temp_file"
    sed -i "s|{{REPO_OWNER}}|$REPO_OWNER|g" "$temp_file"
    sed -i "s|{{REPO_NAME}}|$REPO_NAME|g" "$temp_file"
    sed -i "s|{{DEFAULT_BRANCH}}|$DEFAULT_BRANCH|g" "$temp_file"
    sed -i "s|{{ROOT_DIR}}|$ROOT_DIR|g" "$temp_file"
    sed -i "s|{{UNITY_PACKAGE_NAME}}|$UNITY_PACKAGE_NAME|g" "$temp_file"
    sed -i "s|{{GH_PAGES_URL}}|$GH_PAGES_URL|g" "$temp_file"
    sed -i "s|{{VPM_ID}}|$VPM_ID|g" "$temp_file"
    sed -i "s|{{VPM_URL}}|$VPM_URL|g" "$temp_file"
    sed -i "s|{{VCC_PROJECT_TYPE}}|$VCC_PROJECT_TYPE|g" "$temp_file"
    sed -i "s|{{VPM_DEPENDENCIES}}|$VPM_DEPENDENCIES|g" "$temp_file"
    
    mv "$temp_file" "$file"
}

# Read configuration values from JSON (only if not in interactive mode)
if ! $INTERACTIVE; then
    PACKAGE_NAME=$(read_json_value "$CONFIG_FILE" "['package']['name']")
    DISPLAY_NAME=$(read_json_value "$CONFIG_FILE" "['package']['displayName']")
    VERSION=$(read_json_value "$CONFIG_FILE" "['package']['version']")
    DESCRIPTION=$(read_json_value "$CONFIG_FILE" "['package']['description']")
    AUTHOR_NAME=$(read_json_value "$CONFIG_FILE" "['package']['author']['name']")
    AUTHOR_EMAIL=$(read_json_value "$CONFIG_FILE" "['package']['author']['email']")
    AUTHOR_URL=$(read_json_value "$CONFIG_FILE" "['package']['author']['url']")
    REPO_OWNER=$(read_json_value "$CONFIG_FILE" "['repository']['owner']")
    REPO_NAME=$(read_json_value "$CONFIG_FILE" "['repository']['name']")
    DEFAULT_BRANCH=$(read_json_value "$CONFIG_FILE" "['repository']['defaultBranch']")
    ROOT_DIR=$(read_json_value "$CONFIG_FILE" "['build']['rootDirectory']")
    UNITY_PACKAGE_NAME=$(read_json_value "$CONFIG_FILE" "['build']['unityPackageName']")
    
    # Set default Unity package name if not provided
    if [ -z "$UNITY_PACKAGE_NAME" ]; then
        UNITY_PACKAGE_NAME=$(echo "$PACKAGE_NAME" | sed 's/cat\.kittyn\.//' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | sed 's/ //g')
    fi
    GH_PAGES_URL=$(read_json_value "$CONFIG_FILE" "['repository']['ghPagesUrl']")
    VPM_ID=$(read_json_value "$CONFIG_FILE" "['vpm']['id']")
    VPM_URL=$(read_json_value "$CONFIG_FILE" "['vpm']['url']")

    # Feature flags
    USE_NDMF=$(read_json_value "$CONFIG_FILE" "['features']['ndmf']")
    USE_HARMONY=$(read_json_value "$CONFIG_FILE" "['features']['harmony']")
    SEPARATE_RUNTIME=$(read_json_value "$CONFIG_FILE" "['features']['separateRuntimeAssembly']")
    
    # VCC project type
    VCC_PROJECT_TYPE=$(read_json_value "$CONFIG_FILE" "['package']['type']")
    VCC_PROJECT_TYPE=${VCC_PROJECT_TYPE:-"Any"}  # Default to "Any" if not set
else
    # In interactive mode, set missing values that aren't prompted for
    GH_PAGES_URL="https://$REPO_NAME.kittyn.cat/index.json"
    VPM_ID="$PACKAGE_NAME"  
    VPM_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/v{VERSION}/$PACKAGE_NAME-{VERSION}.zip"
fi

# Set VPM dependencies based on project type
case "$VCC_PROJECT_TYPE" in
    "Avatar")
        VPM_DEPENDENCIES='{"com.vrchat.avatars": ">=3.7.0"}'
        ;;
    "World")
        VPM_DEPENDENCIES='{"com.vrchat.worlds": ">=3.7.0"}'
        ;;
    "VRC")
        VPM_DEPENDENCIES='{"com.vrchat.base": ">=3.7.0"}'
        ;;
    *)
        VPM_DEPENDENCIES='{}'
        ;;
esac


print_info "Building template for: $DISPLAY_NAME ($PACKAGE_NAME)"

# Create output directories with kittyncat_tools structure
mkdir -p "$OUTPUT_DIR/.github/workflows"
mkdir -p "$OUTPUT_DIR/scripts"
mkdir -p "$OUTPUT_DIR/kittyncat_tools/$ROOT_DIR"

# Function to copy template file
copy_template() {
    local template=$1
    local destination=$2
    
    if [ -f "$destination" ] && ! $FORCE; then
        print_warning "File exists: $destination"
        read -p "Overwrite? (y/n) [n]: " overwrite
        if [ "$overwrite" != "y" ]; then
            print_info "Skipping: $destination"
            return
        fi
    fi
    
    cp "$TEMPLATES_DIR/$template" "$destination"
    replace_placeholders "$destination"
    print_success "Created: $destination"
}

# Function to copy template file with force overwrite
copy_template_force() {
    local template=$1
    local destination=$2
    
    if [ -f "$destination" ]; then
        print_warning "Overwriting existing file: $destination"
    fi
    
    cp "$TEMPLATES_DIR/$template" "$destination"
    replace_placeholders "$destination"
    print_success "Created: $destination"
}

# Copy and process templates
print_info "Creating GitHub Actions workflows..."
copy_template "release.yml.template" "$OUTPUT_DIR/.github/workflows/release.yml"
copy_template "update-vpm.yml.template" "$OUTPUT_DIR/.github/workflows/update-vpm.yml"

print_info "Creating build scripts..."
copy_template "build.sh.template" "$OUTPUT_DIR/build.sh"
chmod +x "$OUTPUT_DIR/build.sh"

copy_template "build-index.js.template" "$OUTPUT_DIR/scripts/build-index.js"

print_info "Creating package metadata..."
# Always overwrite package.json to ensure VPM compatibility
copy_template_force "package.json.template" "$OUTPUT_DIR/kittyncat_tools/$ROOT_DIR/package.json"
copy_template "source.json.template" "$OUTPUT_DIR/source.json"

# Create directories for manual assembly definition copying
mkdir -p "$OUTPUT_DIR/kittyncat_tools/$ROOT_DIR/Editor"
if [ "$SEPARATE_RUNTIME" = "true" ]; then
    mkdir -p "$OUTPUT_DIR/kittyncat_tools/$ROOT_DIR/Runtime"
fi

# Create .gitignore if it doesn't exist
if [ ! -f "$OUTPUT_DIR/.gitignore" ]; then
    copy_template "gitignore.template" "$OUTPUT_DIR/.gitignore"
fi

# Create README if it doesn't exist
if [ ! -f "$OUTPUT_DIR/README.md" ]; then
    copy_template "README.md.template" "$OUTPUT_DIR/README.md"
fi

# Initialize git repository if needed
if [ ! -d "$OUTPUT_DIR/.git" ]; then
    print_info "Initializing git repository..."
    cd "$OUTPUT_DIR"
    git init
    git branch -M "$DEFAULT_BRANCH"
    cd - > /dev/null
fi

print_success "Template building complete!"
echo ""

# Automated GitHub setup
print_info "Setting up GitHub repository..."

# Commit everything
cd "$OUTPUT_DIR"
git add .
git commit -m "Initial commit - $DISPLAY_NAME"

# Create and push repository
print_info "Creating GitHub repository..."
gh repo create "$REPO_OWNER/$REPO_NAME" --public --source=. --remote=origin --push

# Create gh-pages branch with initial VPM listing
print_info "Setting up VPM repository..."
git checkout --orphan gh-pages

# Create initial index.json
cat > index.json <<EOF
{
  "name": "$DISPLAY_NAME VPM Repository",
  "author": "$AUTHOR_NAME",
  "url": "https://$REPO_NAME.kittyn.cat/index.json",
  "id": "$PACKAGE_NAME",
  "packages": {}
}
EOF

# Add CNAME for custom domain
echo "$REPO_NAME.kittyn.cat" > CNAME

git add index.json CNAME
git commit -m "Initial VPM listing"
git push -u origin gh-pages

# Switch back to main branch
git checkout "$DEFAULT_BRANCH"

cd - > /dev/null

# GitHub Pages will auto-enable when gh-pages branch is created
# Custom domain is configured via CNAME file in gh-pages branch

print_success "Setup complete!"
echo ""
echo -e "${BLUE}[INFO]${NC} Repository created at: ${GREEN}https://github.com/$REPO_OWNER/$REPO_NAME${NC}"
echo -e "${BLUE}[INFO]${NC} VPM Repository URL: ${GREEN}https://$REPO_NAME.kittyn.cat/index.json${NC}"
echo ""
print_warning "Configure DNS: CNAME record for $REPO_NAME.kittyn.cat → kittynXR.github.io"
echo ""
print_info "Next steps:"
echo "  1. Configure the DNS CNAME record"
echo "  2. Wait for DNS propagation (5-10 minutes)"
echo -e "  3. Run ${GREEN}./build.sh patch${NC} to create your first release!"
echo ""
print_warning "To enable automatic VPM updates:"
echo "  1. Create a Personal Access Token with 'repo' scope at https://github.com/settings/tokens"
echo "  2. Add it as KITTYN_VPM_TOKEN secret in Settings → Secrets → Actions"
echo "  3. This will allow releases to automatically update the main VPM at vpm.kittyn.cat"

# Clean up temporary config if created
if $INTERACTIVE && [ -f "/tmp/template-config-$$.json" ]; then
    rm -f "/tmp/template-config-$$.json"
fi