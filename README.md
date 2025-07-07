# Unity VRChat Package Template Builder

A template system for quickly setting up Unity packages for VRChat with automated CI/CD workflows, following the structure of the imscaler repository.

## Features

- **Automated Setup**: Transform any Unity plugin folder into a release-ready repository
- **GitHub Actions Integration**: Automated builds and releases
- **VCC Compatibility**: Generates VPM-compatible packages for VRChat Creator Companion
- **Version Management**: Semantic versioning with automated bumping
- **Interactive Mode**: Step-by-step configuration wizard
- **Customizable Templates**: All templates can be modified to fit your needs

## Quick Start

1. Clone this template builder:
   ```bash
   git clone <repository-url> unity-template
   cd unity-template/toolkit-template
   ```

2. Run the template builder on your Unity plugin:
   ```bash
   ./template-builder.sh -i /path/to/your/unity-plugin
   ```

3. Follow the interactive prompts to configure your package

4. The script will create all necessary files and initialize a git repository

## Usage

### Basic Usage

```bash
./template-builder.sh [options] <plugin-directory>
```

### Options

- `-c, --config <file>` - Path to configuration file (default: template-config.json)
- `-o, --output <dir>` - Output directory (default: same as plugin directory)
- `-i, --interactive` - Interactive mode - prompts for configuration values
- `-f, --force` - Overwrite existing files without prompting
- `-h, --help` - Show help message

### Examples

**Interactive mode (recommended for first-time setup):**
```bash
./template-builder.sh -i ./MyUnityPlugin
```

**Using a custom configuration file:**
```bash
./template-builder.sh -c my-config.json ./MyUnityPlugin
```

**Force overwrite existing files:**
```bash
./template-builder.sh -f ./MyUnityPlugin
```

## Configuration

The template uses a JSON configuration file to define package settings. You can either:

1. Use interactive mode (`-i`) to create configuration on the fly
2. Edit `template-config.json` before running the script
3. Create your own configuration file

### Configuration Structure

```json
{
  "package": {
    "name": "com.example.mypackage",
    "displayName": "My Unity Package",
    "version": "1.0.0",
    "description": "A Unity package for VRChat",
    "author": {
      "name": "Your Name",
      "email": "email@example.com",
      "url": "https://github.com/yourusername"
    }
  },
  "repository": {
    "owner": "yourusername",
    "name": "mypackage",
    "defaultBranch": "main"
  },
  "build": {
    "rootDirectory": "MyPackage",
    "assemblyDefinitions": {
      "editor": {
        "name": "MyPackage.Editor",
        "rootNamespace": "MyPackage.Editor"
      },
      "runtime": {
        "name": "MyPackage.Runtime",
        "rootNamespace": "MyPackage"
      }
    }
  },
  "features": {
    "ndmf": false,
    "harmony": false,
    "separateRuntimeAssembly": false
  }
}
```

## Generated Files

The template builder creates:

- **GitHub Actions Workflow** (`.github/workflows/release.yml`)
  - Automated package building on release
  - VPM listing generation
  - GitHub Pages deployment

- **Build Script** (`build.sh`)
  - Version bumping (major/minor/patch)
  - Package creation
  - Git tagging
  - GitHub release creation

- **Package Metadata**
  - `package.json` - Unity package manifest
  - `source.json` - VPM repository metadata
  - Assembly definition files

- **Documentation**
  - README.md template
  - .gitignore for Unity projects

## Workflow After Template Generation

1. **Review Generated Files**
   ```bash
   cd /path/to/your/unity-plugin
   # Review and customize the generated files
   ```

2. **Add Your Unity Content**
   - Place your scripts in the appropriate folders (Editor/Runtime)
   - Add any additional assets

3. **Commit Initial Changes**
   ```bash
   git add .
   git commit -m "Initial commit"
   ```

4. **Create GitHub Repository**
   - Go to https://github.com/new
   - Create a new repository (don't initialize with README)

5. **Push to GitHub**
   ```bash
   git remote add origin git@github.com:yourusername/your-repo.git
   git push -u origin main
   ```

6. **Enable GitHub Pages**
   - Go to Settings → Pages
   - Source: Deploy from branch
   - Branch: gh-pages
   - Folder: / (root)

7. **Create Your First Release**
   ```bash
   ./build.sh patch  # or major/minor/1.0.0
   ```

## Creating Releases

The included `build.sh` script handles the entire release process:

```bash
# Bump patch version (1.0.0 → 1.0.1)
./build.sh patch

# Bump minor version (1.0.1 → 1.1.0)
./build.sh minor

# Bump major version (1.1.0 → 2.0.0)
./build.sh major

# Set specific version
./build.sh 2.5.0
```

The script will:
1. Update version in package.json
2. Create zip packages
3. Commit changes
4. Create git tag
5. Push to GitHub
6. Create GitHub release with assets

## VCC Integration

Users can add your package to VRChat Creator Companion:

1. Open VCC
2. Click "Manage Project"
3. Add repository: `https://yourusername.github.io/your-repo/index.json`
4. Find your package in the list
5. Click "Add"

## Customizing Templates

All templates are in the `templates/` directory and can be modified:

- `release.yml.template` - GitHub Actions workflow
- `build.sh.template` - Build script
- `package.json.template` - Unity package manifest
- `source.json.template` - VPM repository metadata
- `editor.asmdef.template` - Editor assembly definition
- `runtime.asmdef.template` - Runtime assembly definition
- `gitignore.template` - Git ignore file
- `README.md.template` - Project README

Templates use `{{PLACEHOLDER}}` syntax for variable substitution.

## Requirements

- **Local Development**
  - Bash shell
  - Git
  - GitHub CLI (`gh`) for release creation
  - Python 3 (for JSON parsing)
  - zip command

- **Unity Requirements**
  - Unity 2019.4.31f1 or later
  - VRChat SDK 3.7.0 or later

## Troubleshooting

**"You have uncommitted changes" error**
- Commit or stash your changes before running build.sh

**GitHub Pages not working**
- Ensure GitHub Pages is enabled for gh-pages branch
- Wait a few minutes for deployment

**Package not showing in VCC**
- Check the repository URL ends with `/index.json`
- Verify GitHub Pages is deployed
- Check browser console for errors

## License

MIT License - feel free to use this template for your own projects!