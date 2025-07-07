# Screenshot Organization Guidelines

This document establishes standards for organizing and managing screenshots across all kittyn.cat VRChat tools.

## Directory Structure

### Tool-Specific Screenshots
Each tool should have its own dedicated screenshot directory:

```
/comfi-hierarchy/screenshots/
/enhanced-dynamics/screenshots/
/immersive-scaler/screenshots/
/toolkit-template/screenshots/
```

### Category Organization
Within each tool's screenshot directory, organize by usage type:

```
screenshots/
├── hero-image.png                 # Main README banner
├── interface/                     # UI screenshots
│   ├── main-window.png
│   ├── settings-panel.png
│   └── inspector-enhanced.png
├── features/                      # Feature demonstrations
│   ├── feature-showcase.png
│   ├── workflow-demo.png
│   └── before-after-comparison.png
└── workflow/                      # Step-by-step guides
    ├── step1-setup.png
    ├── step2-configure.png
    └── step3-result.png
```

## File Naming Conventions

### Naming Pattern
Use descriptive, consistent naming with tool prefixes:

```
{tool-name}-{category}-{description}.png
```

### Examples
- `comfi-hierarchy-hero-image.png`
- `enhanced-dynamics-main-interface.png`  
- `immersive-scaler-scaling-demo.png`
- `comfi-hierarchy-settings-window.png`
- `enhanced-dynamics-physics-preview.png`

### Category Prefixes
- `hero-` - Main banner images
- `interface-` - UI/window screenshots
- `feature-` - Feature demonstrations
- `workflow-` - Step-by-step process shots
- `before-after-` - Comparison images

## Size and Format Standards

### Standard Dimensions
- **Hero Images**: 800x400px (2:1 aspect ratio)
- **Interface Screenshots**: 600x400px (3:2 aspect ratio)
- **Feature Demonstrations**: 600x400px or 400x600px (depending on content)
- **Workflow Steps**: 600x400px (consistent sizing for sequences)
- **Before/After Comparisons**: 800x400px (side-by-side layout)

### Format Requirements
- **Primary Format**: PNG (lossless, supports transparency)
- **Alternative**: JPG (for photographic content, smaller file size)
- **Compression**: Optimize for web without quality loss
- **Color Space**: sRGB for web compatibility

### Unity Editor Screenshots
- **Window Chrome**: Include Unity's window frame for context
- **UI Scale**: Use 100% UI scale for consistency
- **Theme**: Prefer Dark theme for professional appearance
- **Resolution**: Capture at high DPI then scale down for sharpness

## Integration with Documentation

### README.md Usage
Reference screenshots using relative paths:

```markdown
![Tool Name Screenshot](./screenshots/hero-image.png)
*Caption describing the screenshot*

![Settings Window](./screenshots/interface/settings-window.png)
*Tool settings window with configuration options*
```

### Placeholder Migration
Replace existing placeholder URLs with local screenshots:

```markdown
<!-- Old placeholder -->
![Screenshot](https://via.placeholder.com/800x400/2D3748/FFFFFF?text=Tool+Screenshot)

<!-- New local reference -->
![Screenshot](./screenshots/hero-image.png)
```

## Screenshot Content Guidelines

### Hero Images
- Show the tool's primary interface or main feature
- Include Unity Editor context when relevant
- Use high-quality, representative content
- Avoid cluttered or confusing layouts

### Interface Screenshots
- Capture clean, organized UI states
- Show realistic usage scenarios
- Include relevant Unity panels/windows
- Ensure text is readable at display size

### Feature Demonstrations
- Focus on the specific feature being showcased
- Show clear before/after states when applicable
- Include relevant context (hierarchy, inspector, etc.)
- Highlight interactive elements with callouts if needed

### Workflow Screenshots
- Maintain consistent UI state across sequence
- Number steps clearly when part of a series
- Show progression naturally
- Include relevant Unity panels for each step

## Technical Considerations

### File Management
- Keep screenshots in version control for consistency
- Use descriptive commit messages when updating images
- Consider file size impact on repository
- Compress images appropriately for web use

### Unity Editor Setup
- Use consistent Unity version (2019.4.31f1 for VRChat)
- Standardize window layouts for consistency
- Use representative test content/avatars
- Ensure proper lighting in Scene view

### Accessibility
- Use sufficient color contrast
- Include alt text in markdown
- Provide captions for complex images
- Consider colorblind-friendly highlighting

## Maintenance Procedures

### Regular Updates
- Update screenshots when UI changes significantly
- Maintain consistency across tool versions
- Review and refresh outdated images quarterly
- Update placeholder references as tools evolve

### Quality Assurance
- Verify all screenshot links work correctly
- Check image quality and readability
- Ensure consistent styling across tools
- Test markdown rendering on different platforms

### Version Control
- Commit screenshots with relevant code changes
- Use meaningful commit messages for image updates
- Consider using Git LFS for large image files
- Tag releases with corresponding screenshot versions

## Tool-Specific Requirements

### ComfiHierarchy
- Show hierarchy window with icons and enhancements
- Include settings window with customization options
- Demonstrate icon system with various components
- Show before/after hierarchy appearance

### Enhanced Dynamics
- Capture physics preview mode in action
- Show enhanced inspector panels
- Include viewport gizmos and handles
- Demonstrate workflow from setup to testing

### Immersive Scaler
- Show measurement interface with avatar
- Include before/after scaling comparisons
- Demonstrate proportioning controls
- Show scene gizmos and measurement visualization

## Best Practices

### Consistency
- Use the same Unity theme across all tools
- Maintain consistent window arrangements
- Use similar avatar/test content when possible
- Apply consistent post-processing/editing

### Quality
- Capture at native resolution, scale down for sharpness
- Use good lighting in Scene view screenshots
- Ensure UI elements are clearly visible
- Avoid visual artifacts or compression issues

### Documentation
- Always include descriptive captions
- Reference screenshots in logical order
- Update documentation when screenshots change
- Maintain screenshot-to-text ratio balance

## Future Considerations

### Template Integration
- Use this structure for new tools in toolkit-template
- Maintain consistency with established patterns
- Update guidelines as standards evolve
- Consider automation for routine screenshot tasks

### Repository Organization
- Evaluate moving to centralized screenshot management
- Consider using external image hosting for large files
- Implement automated screenshot validation
- Develop screenshot update notification system

---

**Note**: This document should be updated whenever screenshot organization standards change. Keep one copy in the main repository and another in the toolkit-template for new tool development.