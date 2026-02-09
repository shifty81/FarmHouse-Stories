# GFX Folder Integration Guide

## Purpose

This guide provides step-by-step instructions for reviewing, organizing, and integrating graphics assets from the `gfx/` folder into the FarmHouse Stories project.

## When to Use This Guide

Use this guide when:
- The `gfx/` folder has been uploaded to the repository
- You receive new graphics assets to integrate
- You need to audit existing graphics
- You want to optimize and organize visual assets

## Step 1: Initial Review

### 1.1 Locate the GFX Folder

```bash
cd /home/runner/work/FarmHouse-Stories/FarmHouse-Stories
find . -type d -name "gfx"
```

### 1.2 Inventory All Assets

Create a comprehensive list of all graphics files:

```bash
# List all image files
find gfx/ -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" -o -name "*.webp" \) -exec ls -lh {} \;

# Count files by type
echo "PNG files:" && find gfx/ -name "*.png" | wc -l
echo "JPG files:" && find gfx/ -name "*.jpg" -o -name "*.jpeg" | wc -l
echo "SVG files:" && find gfx/ -name "*.svg" | wc -l
```

### 1.3 Check File Organization

```bash
# Show directory structure
tree gfx/ -L 3  # Or use: find gfx/ -type d
```

### 1.4 Analyze File Sizes

```bash
# Find large files (over 1MB)
find gfx/ -type f -size +1M -exec ls -lh {} \;

# Calculate total size
du -sh gfx/
```

## Step 2: Categorize Assets

### 2.1 Asset Types to Identify

Create a checklist of what assets you have:

- [ ] **Character Sprites**
  - [ ] Player character
  - [ ] NPCs
  - [ ] Animals

- [ ] **Environment**
  - [ ] Tilesets (ground, walls, paths)
  - [ ] Trees, rocks, plants
  - [ ] Buildings and structures

- [ ] **Crops & Plants**
  - [ ] Growth stages for each crop type
  - [ ] Harvestable items

- [ ] **UI Elements**
  - [ ] Buttons and menus
  - [ ] Icons and inventory items
  - [ ] Portraits
  - [ ] Frames and borders

- [ ] **Tools & Objects**
  - [ ] Farming tools (hoe, watering can, etc.)
  - [ ] Furniture and decorations
  - [ ] Interactive objects

- [ ] **Effects**
  - [ ] Particle effects
  - [ ] Animation frames
  - [ ] Weather effects

### 2.2 Create Asset Inventory Document

```bash
# Create an inventory file
cd gfx/
ls -R > ../docs/GFX_INVENTORY.txt
```

## Step 3: Organize Files

### 3.1 Recommended Structure

If the `gfx/` folder isn't already organized, reorganize it:

```
gfx/
├── characters/
│   ├── player/
│   ├── npcs/
│   └── animals/
├── crops/
│   ├── [crop_name]/
│   │   ├── stage_0.png
│   │   ├── stage_1.png
│   │   └── ...
├── tiles/
│   ├── terrain/
│   ├── paths/
│   └── structures/
├── objects/
│   ├── tools/
│   ├── furniture/
│   └── decorations/
├── ui/
│   ├── buttons/
│   ├── icons/
│   └── portraits/
├── effects/
└── misc/
```

### 3.2 Reorganization Script

If needed, create a reorganization script:

```bash
#!/bin/bash
# reorganize_gfx.sh

# Create target structure
mkdir -p assets/gfx/{characters/{player,npcs,animals},crops,tiles,objects,ui,effects}

# Move files (customize based on actual file names)
# Example:
# mv gfx/player*.png assets/gfx/characters/player/
# mv gfx/npc*.png assets/gfx/characters/npcs/
```

## Step 4: Validate Assets for Godot

### 4.1 Check Image Formats

Godot 4.6 supports:
- ✅ PNG (recommended for sprites with transparency)
- ✅ JPG/JPEG (for backgrounds without transparency)
- ✅ WebP (good compression, transparency support)
- ✅ SVG (vector graphics)
- ❌ BMP, TIFF (need conversion)

### 4.2 Verify Sprite Dimensions

```bash
# Check dimensions of all PNGs (requires ImageMagick)
find gfx/ -name "*.png" -exec identify -format "%f: %wx%h\n" {} \;
```

**Ideal dimensions for pixel art:**
- Character sprites: 16x16, 32x32, or 48x48
- Tiles: 16x16 or 32x32
- UI elements: Multiples of 8 or 16

### 4.3 Check for Transparency

```bash
# Find images with alpha channel (requires ImageMagick)
find gfx/ -name "*.png" -exec identify -format "%f: %[channels]\n" {} \; | grep -i alpha
```

## Step 5: Import into Godot

### 5.1 Move to Assets Folder

```bash
# If gfx is not already in assets/
mv gfx/ assets/gfx/
# Or create symlink if you want to keep it separate
ln -s ../../gfx assets/gfx
```

### 5.2 Configure Import Settings

Open Godot and select all pixel art sprites:

**For Pixel Art (recommended for this project):**
1. Select all sprite images in FileSystem dock
2. In Import dock, set:
   - **Filter:** Nearest
   - **Mipmaps:** Disabled
   - **Repeat:** Disabled
   - **VRAM Compression:** Disabled (for crisp pixels)
3. Click "Reimport"

**For HD Graphics:**
1. Select HD images
2. Set:
   - **Filter:** Linear
   - **Mipmaps:** Enabled
   - **VRAM Compression:** VRAM Compressed

### 5.3 Create Godot Resources

For sprite sheets, create AtlasTexture resources:

```gdscript
# tools/create_atlas_textures.gd
extends EditorScript

func _run():
    var sprite_sheet_path = "res://assets/gfx/characters/player/spritesheet.png"
    var frame_width = 32
    var frame_height = 32
    var columns = 4
    var rows = 4
    
    var sprite_sheet = load(sprite_sheet_path)
    
    for row in range(rows):
        for col in range(columns):
            var atlas = AtlasTexture.new()
            atlas.atlas = sprite_sheet
            atlas.region = Rect2(
                col * frame_width,
                row * frame_height,
                frame_width,
                frame_height
            )
            
            var save_path = "res://resources/sprites/player_frame_%d_%d.tres" % [row, col]
            ResourceSaver.save(atlas, save_path)
    
    print("Created atlas textures!")
```

## Step 6: Test with Cell Shading

### 6.1 Apply Cell Shader to Test Sprite

```gdscript
# Test scene
extends Node2D

func _ready():
    var test_sprite = Sprite2D.new()
    add_child(test_sprite)
    
    # Load a test texture
    test_sprite.texture = load("res://assets/gfx/characters/player/idle.png")
    
    # Apply cell shader
    var material = ShaderMaterial.new()
    material.shader = load("res://shaders/cell_shader.gdshader")
    material.set_shader_parameter("color_steps", 4)
    
    test_sprite.material = material
    test_sprite.position = Vector2(320, 240)
```

### 6.2 Evaluate Visual Quality

Check for:
- ✅ Clear outlines and edges
- ✅ Distinct color bands
- ✅ Readable at game resolution
- ✅ Consistent style across assets
- ❌ Artifacts or unwanted effects
- ❌ Performance issues

## Step 7: Document Assets

### 7.1 Create Credits File

If using third-party assets, create `assets/gfx/CREDITS.md`:

```markdown
# Graphics Credits

## Character Sprites
- **Artist:** [Name]
- **License:** [CC0, CC BY, etc.]
- **Source:** [URL]
- **Modifications:** [None / List changes]

## Tilesets
- **Artist:** [Name]
- **License:** [License type]
- **Source:** [URL]

## UI Elements
- **Source:** [Pack name]
- **License:** [License type]
- **Link:** [URL]

## Additional Notes
[Any additional attribution or licensing information]
```

### 7.2 Create Asset Reference

Create `docs/GFX_REFERENCE.md`:

```markdown
# GFX Asset Reference

## Character Sprites

### Player
- Location: `assets/gfx/characters/player/`
- Size: 32x32 pixels
- Animations: idle, walk (4 directions each)
- Format: PNG with transparency

### NPCs
[List each NPC with details]

## Crops

### Parsnip
- Location: `assets/gfx/crops/parsnip/`
- Growth Stages: 5
- Files: `stage_0.png` through `stage_4.png`

[Continue for each crop type]

## Tilesets

[Document each tileset]
```

## Step 8: Create Helper Scripts

### 8.1 Sprite Sheet Slicer

Create a tool to automatically slice sprite sheets:

```gdscript
# addons/sprite_slicer/sprite_slicer.gd
@tool
extends EditorScript

@export var source_image: Texture2D
@export var tile_width: int = 32
@export var tile_height: int = 32
@export var output_folder: String = "res://resources/sprites/"

func slice_sprite_sheet():
    if not source_image:
        print("No source image specified!")
        return
    
    var image = source_image.get_image()
    var width = image.get_width()
    var height = image.get_height()
    
    var cols = width / tile_width
    var rows = height / tile_height
    
    for y in range(rows):
        for x in range(cols):
            var region = Rect2(
                x * tile_width,
                y * tile_height,
                tile_width,
                tile_height
            )
            
            var atlas = AtlasTexture.new()
            atlas.atlas = source_image
            atlas.region = region
            
            var filename = "%s/tile_%d_%d.tres" % [output_folder, y, x]
            ResourceSaver.save(atlas, filename)
    
    print("Sliced sprite sheet into %d tiles" % (cols * rows))
```

### 8.2 Asset Validator

```gdscript
# tools/validate_assets.gd
extends EditorScript

func _run():
    validate_directory("res://assets/gfx/")

func validate_directory(path: String):
    var dir = DirAccess.open(path)
    if not dir:
        print("Cannot open directory: ", path)
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        var full_path = path + "/" + file_name
        
        if dir.current_is_dir():
            if file_name not in [".", ".."]:
                validate_directory(full_path)
        else:
            validate_file(full_path)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()

func validate_file(file_path: String):
    if file_path.ends_with(".png") or file_path.ends_with(".jpg"):
        var texture = load(file_path) as Texture2D
        if texture:
            var size = texture.get_size()
            
            # Check if dimensions are power of 2
            var is_pot = is_power_of_two(size.x) and is_power_of_two(size.y)
            
            # Check for extremely large textures
            var is_large = size.x > 4096 or size.y > 4096
            
            if is_large:
                print("⚠️  Large texture: ", file_path, " (", size, ")")
            elif not is_pot:
                print("ℹ️  Non-power-of-two: ", file_path, " (", size, ")")
            else:
                print("✅ ", file_path)

func is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0
```

## Step 9: Performance Check

### 9.1 Check Memory Usage

```gdscript
# In your main scene
func _ready():
    print("Memory usage: ", OS.get_static_memory_usage() / 1024 / 1024, " MB")
```

### 9.2 Profile Rendering

- Run game with Godot's profiler enabled
- Check "Rendering" section
- Look for:
  - Draw calls
  - Texture memory
  - FPS consistency

### 9.3 Optimize if Needed

If performance issues:
1. **Reduce texture sizes** for distant/small objects
2. **Use texture atlases** to reduce draw calls
3. **Enable VRAM compression** for non-pixel-art
4. **Limit shader complexity** (test without shaders)

## Step 10: Integration Checklist

Before completing integration:

- [ ] All assets organized in proper folders
- [ ] Import settings configured correctly
- [ ] AtlasTextures created for sprite sheets
- [ ] Cell shader tested on sample sprites
- [ ] Credits and licenses documented
- [ ] Asset reference guide created
- [ ] No performance issues detected
- [ ] Files committed to git with proper .gitignore
- [ ] Large files excluded (>10MB should be optional downloads)

## Common Issues and Solutions

### Issue: Blurry Pixel Art
**Solution:** Set Filter to "Nearest" in import settings

### Issue: Seams in Tiles
**Solution:** Disable filtering, ensure tile sizes are exact

### Issue: Transparent Pixels Have Color Fringe
**Solution:** Pre-multiply alpha or use "Premultiplied Alpha" setting

### Issue: Large Memory Usage
**Solution:** Enable compression for large textures, reduce sizes

### Issue: Shader Not Working on Sprites
**Solution:** Ensure material is assigned to CanvasItem node, check shader compilation

## Next Steps After Integration

1. **Create AnimatedSprite2D scenes** for characters
2. **Setup TileMap scenes** with imported tilesets
3. **Create UI themes** using imported UI elements
4. **Test in-game** with actual gameplay
5. **Iterate and refine** based on visual results

---

**Related Documentation:**
- `05_AssetOrganization.md` - Detailed asset organization guidelines
- `02_CellShadingTechniques.md` - Shader setup for graphics
- `07_ImplementationGuide.md` - Using assets in game scenes

## Ready to Analyze?

Once the `gfx/` folder is available, run through this guide step-by-step to properly integrate all graphics assets into the FarmHouse Stories project!
