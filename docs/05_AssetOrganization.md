# Asset Organization and Graphics Guide

## Overview

This document outlines how to organize game assets (graphics, sounds, etc.) for the FarmHouse Stories project, with a focus on the `gfx/` folder structure and best practices for Godot 4.6.

## Folder Structure

### Recommended Asset Organization

```
FarmHouse-Stories/
├── assets/                    # Main assets folder
│   ├── gfx/                  # Graphics folder (sprites, textures, etc.)
│   │   ├── characters/       # Character sprites
│   │   │   ├── player/
│   │   │   │   ├── idle.png
│   │   │   │   ├── walk.png
│   │   │   │   └── tool_use.png
│   │   │   └── npcs/
│   │   │       ├── npc_001.png
│   │   │       └── npc_002.png
│   │   ├── crops/            # Crop growth stages
│   │   │   ├── parsnip/
│   │   │   │   ├── stage_0.png
│   │   │   │   ├── stage_1.png
│   │   │   │   └── stage_2.png
│   │   │   └── strawberry/
│   │   ├── tiles/            # Tileset images
│   │   │   ├── farm_tiles.png
│   │   │   ├── interior_tiles.png
│   │   │   └── nature_tiles.png
│   │   ├── objects/          # Interactive objects
│   │   │   ├── tools/
│   │   │   ├── furniture/
│   │   │   └── decorations/
│   │   ├── ui/               # User interface elements
│   │   │   ├── buttons/
│   │   │   ├── icons/
│   │   │   ├── frames/
│   │   │   └── fonts/
│   │   ├── animals/          # Animal sprites
│   │   │   ├── chicken/
│   │   │   ├── cow/
│   │   │   └── pig/
│   │   ├── effects/          # Visual effects
│   │   │   ├── particles/
│   │   │   └── animations/
│   │   └── portraits/        # Character portraits for dialogue
│   │       ├── player_portrait.png
│   │       └── npc_portraits/
│   ├── audio/                # Sound effects and music
│   │   ├── sfx/
│   │   └── music/
│   └── fonts/                # Custom fonts
└── resources/                # Godot resource files (.tres, .res)
    ├── crops/
    ├── items/
    └── recipes/
```

## Graphics Asset Guidelines

### Sprite Specifications

#### Character Sprites
- **Size:** 32x32 or 48x48 pixels per frame
- **Format:** PNG with transparency
- **Animation:** Sprite sheets with consistent frame sizes
- **Directions:** 4-directional (down, up, left, right)

**Example Character Sprite Sheet Layout:**
```
[Idle_Down] [Idle_Up] [Idle_Left] [Idle_Right]
[Walk_Down1][Walk_Down2][Walk_Down3][Walk_Down4]
[Walk_Up1]  [Walk_Up2]  [Walk_Up3]  [Walk_Up4]
[Walk_Left1][Walk_Left2][Walk_Left3][Walk_Left4]
[Walk_Right1][Walk_Right2][Walk_Right3][Walk_Right4]
```

#### Crop Sprites
- **Size:** 16x16 or 32x32 pixels
- **Format:** PNG with transparency
- **Stages:** Minimum 3-5 growth stages per crop
- **Alignment:** Bottom-center aligned for ground placement

**Growth Stage Example:**
```
Stage 0: Seed (barely visible)
Stage 1: Sprout
Stage 2: Small plant
Stage 3: Medium plant
Stage 4: Mature/harvestable
```

#### Tileset Requirements
- **Tile Size:** 16x16, 32x32, or 64x64 (consistent throughout)
- **Format:** PNG
- **Autotile Support:** Include 47-tile autotile sets for Godot
- **Layers:** Separate ground, overlay, and collision tiles

### Color Palette

For cell-shaded aesthetic:
- Use vibrant, saturated colors
- Limit palette per sprite (4-8 colors)
- Clear value separation (light/mid/dark tones)
- Consistent color theory across all assets

**Recommended Palette Structure:**
```
Base Colors:
- Grass Green: #7CBF7B
- Dirt Brown: #8B6F47
- Water Blue: #4A9EDD
- Sky Blue: #A8DDFF

Accent Colors:
- Crop Green: #5FCF5F
- Flower Colors: #FF6B9D, #FFD93D, #C896FF
- Wood: #9B7653
```

## Godot Import Settings

### For Pixel Art (Recommended for FarmHouse Stories)

**In Godot Import Dock:**
```
Filter: Nearest (for crisp pixels)
Mipmaps: Disabled
Repeat: Disabled (unless tiling)
VRAM Compression: Disabled (for quality)
```

### For HD Graphics

```
Filter: Linear
Mipmaps: Enabled
Repeat: As needed
VRAM Compression: VRAM Compressed
```

## Asset Naming Conventions

### File Naming Rules

1. **Use lowercase with underscores:** `player_walk_left.png`
2. **Be descriptive:** `oak_tree_autumn.png` not `tree2.png`
3. **Include state/variant:** `npc_farmer_happy.png`
4. **Number sequences:** `crop_growth_01.png`, `crop_growth_02.png`

### Examples

```
✅ Good Names:
- player_idle_down.png
- crop_wheat_stage_03.png
- ui_button_normal.png
- tile_grass_corner_nw.png

❌ Bad Names:
- char1.png
- image_final_final2.png
- temp.png
- Untitled-1.png
```

## Working with the GFX Folder

### Initial Setup

When the `gfx/` folder is added to the project:

1. **Review Contents:**
   ```bash
   # List all files in gfx folder
   find gfx/ -type f -name "*.png" -o -name "*.jpg"
   ```

2. **Organize by Type:**
   - Group similar assets together
   - Create subfolders if needed
   - Remove duplicate or unused files

3. **Set Import Settings:**
   - Select all pixel art sprites
   - Set to "Nearest" filter mode
   - Disable mipmaps

4. **Create Atlas Textures:**
   - For sprite sheets, use Godot's AtlasTexture
   - Define regions for each frame
   - Save as .tres resources

### Converting Graphics to Godot Resources

#### Creating a Sprite Sheet Resource

```gdscript
# Script to automatically create AtlasTextures from sprite sheet
extends EditorScript

func _run():
    var sprite_sheet = load("res://assets/gfx/characters/player/walk.png")
    var frame_width = 32
    var frame_height = 32
    var frames_per_row = 4
    var total_frames = 16
    
    for i in range(total_frames):
        var atlas = AtlasTexture.new()
        atlas.atlas = sprite_sheet
        
        var x = (i % frames_per_row) * frame_width
        var y = (i / frames_per_row) * frame_height
        
        atlas.region = Rect2(x, y, frame_width, frame_height)
        
        var save_path = "res://resources/sprites/player_walk_%02d.tres" % i
        ResourceSaver.save(atlas, save_path)
    
    print("Created %d atlas textures" % total_frames)
```

## Integrating with Cell Shading

### Preparing Assets for Cell Shading

1. **High Contrast:** Ensure sprites have clear light/dark areas
2. **Clean Edges:** Sharp outlines work best with toon shaders
3. **Flat Colors:** Minimize gradients in base sprites
4. **Separation:** Keep foreground and background distinct

### Testing Cell Shader on Assets

```gdscript
# Quick test script to apply cell shader to all sprites in gfx/
extends Node2D

func _ready():
    var shader = preload("res://shaders/cell_shader.gdshader")
    var material = ShaderMaterial.new()
    material.shader = shader
    material.set_shader_parameter("color_steps", 4)
    
    # Apply to all Sprite2D children
    for child in get_children():
        if child is Sprite2D:
            child.material = material
```

## Asset Checklist

### Before Adding New Graphics

- [ ] Correct size and format (PNG with transparency)
- [ ] Properly named following conventions
- [ ] Organized in appropriate subfolder
- [ ] Optimized file size (use PNG compression)
- [ ] Has consistent style with existing assets
- [ ] Tested in Godot with cell shader

### After Adding Graphics

- [ ] Import settings configured (Nearest filter for pixel art)
- [ ] Created necessary .tres resources (AtlasTextures, etc.)
- [ ] Updated relevant scenes to use new graphics
- [ ] Tested in-game appearance
- [ ] Committed to version control with descriptive message

## Performance Considerations

### Texture Atlases

For better performance, combine small sprites into texture atlases:

```
Instead of:
- item_001.png (16x16)
- item_002.png (16x16)
- item_003.png (16x16)
... (100 separate files)

Use:
- items_atlas.png (256x256 containing all items)
- Define regions in Godot
```

### Texture Size Limits

- **Mobile:** Keep individual textures under 2048x2048
- **Desktop:** Can use up to 4096x4096
- **General:** Use power-of-two sizes when possible (512, 1024, 2048)

### Compression

For release builds:
- Enable VRAM compression for non-pixel-art
- Use lossless PNG compression
- Consider WebP for web exports

## Attribution and Licensing

### If Using Third-Party Assets

Create `assets/gfx/CREDITS.md`:

```markdown
# Graphics Credits

## Character Sprites
- Artist: [Name]
- License: [License Type]
- Source: [URL]
- Modifications: [List any changes made]

## Tileset
- Artist: [Name]
- License: [License Type]
- Source: [URL]

## Icons
- Source: [Icon Pack Name]
- License: [License Type]
```

### License Compatibility

Ensure all assets are compatible with your project's license:
- ✅ CC0 (Public Domain)
- ✅ CC BY (with attribution)
- ✅ CC BY-SA (with attribution, share-alike)
- ⚠️ CC BY-NC (non-commercial only)
- ❌ All Rights Reserved (requires permission)

## GFX Folder Analysis Script

When the gfx folder is available, use this script to analyze it:

```gdscript
# Script to analyze gfx folder contents
extends EditorScript

func _run():
    var dir = DirAccess.open("res://assets/gfx/")
    if dir:
        analyze_directory(dir, "res://assets/gfx/", 0)

func analyze_directory(dir: DirAccess, path: String, depth: int):
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    var stats = {
        "images": 0,
        "total_size": 0,
        "formats": {}
    }
    
    while file_name != "":
        var full_path = path + "/" + file_name
        
        if dir.current_is_dir():
            if file_name != "." and file_name != "..":
                print("  ".repeat(depth) + "📁 " + file_name)
                var subdir = DirAccess.open(full_path)
                analyze_directory(subdir, full_path, depth + 1)
        else:
            var ext = file_name.get_extension().to_lower()
            if ext in ["png", "jpg", "jpeg", "webp", "svg"]:
                stats.images += 1
                if not stats.formats.has(ext):
                    stats.formats[ext] = 0
                stats.formats[ext] += 1
                print("  ".repeat(depth) + "🖼️  " + file_name)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    if depth == 0:
        print("\n=== Summary ===")
        print("Total images: %d" % stats.images)
        print("Formats: %s" % str(stats.formats))
```

## Next Steps for GFX Integration

Once the gfx folder is uploaded:

1. **Run analysis script** to inventory assets
2. **Organize files** into proper structure
3. **Configure import settings** for all sprites
4. **Create resource files** for sprite sheets
5. **Test with cell shader** to ensure compatibility
6. **Document asset sources** in CREDITS.md
7. **Update scenes** to use new graphics

---

**Related Documentation:**
- `02_CellShadingTechniques.md` - Shader setup for graphics
- `05_GodotResources.md` - Godot-specific asset handling
- `07_ImplementationGuide.md` - Using assets in scenes
