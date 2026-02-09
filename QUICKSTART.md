# Quick Start: Using the GFX Assets

This guide shows you how to immediately start using the Zelda-like tileset assets in your FarmHouse Stories project.

## What You Have

✅ **8 PNG files in `/gfx/` folder:**
- `Overworld.png` - Main outdoor tileset (640×576)
- `Inner.png` - Building interiors (640×400)
- `cave.png` - Mining/cave areas (640×400)
- `character.png` - Player character animations (272×256)
- `objects.png` - Tools, furniture, items (528×320)
- `NPC_test.png` - Sample NPC (64×128)
- `log.png` - Dialog boxes (192×128)
- `font.png` - Game font (240×144)

**Total:** 192 KB of high-quality pixel art, perfect for a farming game!

## Step 1: Import into Godot (5 minutes)

### 1.1 Open Project in Godot 4.6

```bash
# If not already open
cd /path/to/FarmHouse-Stories
godot project.godot
```

### 1.2 Configure Import Settings

In Godot Editor:

1. Click on `gfx/` folder in FileSystem dock
2. Select ALL .png files (Ctrl+A or Cmd+A)
3. In the **Import** dock (right side), set:
   - **Compress → Mode:** Lossless
   - **Process → Fix Alpha Border:** Enabled
   - **Process → Size Limit:** 0
   - **Filter:** **Nearest** (CRITICAL for pixel art!)
   - **Mipmaps → Generate:** Disabled
   - **Repeat:** Disabled
4. Click **Reimport**

✅ Your sprites are now properly imported!

## Step 2: Create Your First Scene (10 minutes)

### 2.1 Create Main Farm Scene

1. **Scene → New Scene**
2. Add **Node2D** as root, rename to "Farm"
3. **Save Scene** as `scenes/Farm.tscn`

### 2.2 Add TileMap for Terrain

1. Add **TileMap** node to Farm
2. In Inspector:
   - **Tile Set → [New TileSet]**
   - Click the new TileSet to edit it
3. In TileSet editor (bottom panel):
   - Click "+" to add a new atlas
   - **Texture:** Select `gfx/Overworld.png`
   - **Texture Region Size:** 16×16
   - **Use Texture Padding:** Disabled
4. Click "Setup" to create the tiles automatically

### 2.3 Paint Your Farm!

1. Select the TileMap node
2. In the TileMap editor (bottom panel):
   - Choose tiles from the palette
   - Paint grass, dirt, paths, trees, water
3. Create your farm layout!

Example layout:
```
🌳🌳🌳🌳🌳🌳🌳🌳
🌳🟫🟫🟫🟫🟫🟫🌳
🌳🟫🌱🌱🌱🌱🟫🌳
🌳🟫🌱🌱🌱🌱🟫🌳
🌳🟫🟫🟫🟫🟫🟫🌳
🌳🏠🏠🟩🟩💧💧🌳
🌳🌳🌳🌳🌳🌳🌳🌳
```

## Step 3: Add Player Character (10 minutes)

### 3.1 Create Player Scene

1. **Scene → New Scene**
2. Add **CharacterBody2D** as root
3. Rename to "Player"
4. **Save as** `scenes/Player.tscn`

### 3.2 Add Sprite and Collision

1. Add **AnimatedSprite2D** as child of Player
2. In Inspector:
   - **Sprite Frames → [New SpriteFrames]**
   - Click the SpriteFrames to edit
3. In SpriteFrames editor (bottom):
   - Add new animation: "walk_down"
   - Click "Add frames from sprite sheet"
   - Select `gfx/character.png`
   - **Horizontal:** 17 frames, **Vertical:** 16 frames
   - Select frames for walking down animation
   - **FPS:** 10

4. Add **CollisionShape2D** as child of Player
   - **Shape → [New CircleShape2D]**
   - Adjust size to fit character (radius ~6-8)

### 3.3 Add Basic Movement Script

Add script to Player node:

```gdscript
extends CharacterBody2D

@export var speed: float = 100.0
@onready var anim_sprite = $AnimatedSprite2D

func _physics_process(delta):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * speed
    
    if direction != Vector2.ZERO:
        anim_sprite.play("walk_down")  # Add more directions later
    else:
        anim_sprite.stop()
    
    move_and_slide()
```

### 3.4 Add Player to Farm Scene

1. Open `Farm.tscn`
2. Right-click Farm node → Instance Child Scene
3. Select `Player.tscn`
4. Position player in the farm
5. **Save** the scene

## Step 4: Test the Game! (2 minutes)

1. **Project → Project Settings → General → Run**
   - Set **Main Scene:** `scenes/Farm.tscn`
2. Press **F5** or click ▶ to run

✅ You should see your farm with a moving character!

## Step 5: Add Cell Shading (Optional, 15 minutes)

### 5.1 Create Shader

1. Create folder: `shaders/`
2. **Right-click → New Shader**
3. Name it `cell_shader.gdshader`
4. Paste this code:

```gdshader
shader_type canvas_item;

uniform int color_steps : hint_range(2, 8) = 4;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float brightness = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    float quantized = floor(brightness * float(color_steps)) / float(color_steps);
    COLOR.rgb = tex.rgb * (quantized / max(brightness, 0.001));
    COLOR.a = tex.a;
}
```

### 5.2 Create Shader Material

1. Create folder: `resources/materials/`
2. **Right-click → New ShaderMaterial**
3. Save as `cell_shader_material.tres`
4. In Inspector:
   - **Shader:** Select `cell_shader.gdshader`
   - **Shader Param/color_steps:** 4

### 5.3 Apply to Sprites

1. Open `Player.tscn`
2. Select AnimatedSprite2D
3. In Inspector:
   - **CanvasItem → Material:** Select `cell_shader_material.tres`
4. **Save**

Run the game (F5) - your character now has cell shading! 🎨

## Quick Tips

### For Farming Mechanics

Use `objects.png` for:
- Crop sprites (modify grid coordinates)
- Tool icons (hoe, watering can)
- Chests and storage
- Decorations

### For Buildings

Use `Inner.png` to create:
- Player's house interior
- Barn interior
- Shop interior
- Storage sheds

### For Mining

Use `cave.png` for:
- Underground mine levels
- Cave exploration
- Resource gathering areas

## Next Steps

Now that you have the basics working:

1. ✅ Add more character animations (up, left, right)
2. ✅ Create crop planting system
3. ✅ Add tool switching
4. ✅ Build interior scenes
5. ✅ Implement day/night cycle

See **[docs/07_ImplementationGuide.md](docs/07_ImplementationGuide.md)** for complete development roadmap!

## Common Issues

**Problem:** Sprites look blurry
**Solution:** Check Import settings, ensure Filter is set to "Nearest"

**Problem:** Character animation not playing
**Solution:** Verify sprite frame coordinates match the sprite sheet layout

**Problem:** Tiles not aligning
**Solution:** Confirm tile size is 16×16 in TileSet settings

## Resources

- **Complete Analysis:** [docs/GFX_ANALYSIS_COMPLETE.md](docs/GFX_ANALYSIS_COMPLETE.md)
- **Implementation Guide:** [docs/07_ImplementationGuide.md](docs/07_ImplementationGuide.md)
- **Cell Shading Guide:** [docs/02_CellShadingTechniques.md](docs/02_CellShadingTechniques.md)

---

**You're ready to start building! Happy farming! 🎮🌾**
