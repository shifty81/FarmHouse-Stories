# Echo Ridge Inheritance: Starting Story & Asset Guide

## Overview

This document presents an alternative starting story concept for FarmHouse Stories, featuring the **"Echo Ridge Inheritance"** narrative. This cozy, nature-focused approach can be used as an alternative or complementary introduction to the existing Aethelgard Valley storyline.

---

## 1. The Starting Story: "Echo Ridge Inheritance"

### 1.1 The Premise

Instead of a corporate job, your story begins with a letter from your eccentric, late **Aunt Elara**, who was known as a local protector of nature.

**The Setting:** You inherit **"Echo Ridge Farm"** — not just a farm, but an old, magical sanctuary that has fallen into disrepair because the **"Nature Spirits"** (Echoes) have grown weak due to neglect.

**The Goal:** You are not just making money; you are restoring the land's ecological balance and bringing life back to the valley.

### 1.2 The Initial Conflict

The valley's nearby town, **Havenport**, has become obsessed with industrial, fast-paced agriculture, and wants to buy your land to turn it into a concrete processing plant. You have **one year** to prove the farm's value and demonstrate that sustainable, spirit-connected farming can thrive.

### 1.3 The First Scene

**You arrive at a dilapidated cabin.** Inside, on a dust-covered table, lies a glowing, ancient journal with pages missing. A tiny, shy spirit (a small orb of light) nudges you to start working.

**Opening Dialogue:**

```
SPIRIT ORB (flickering): "Welcome... inheritor. The land... remembers Elara. 
Will you... help us bloom again?"

[OPTION 1] "I'll do my best." → Spirit becomes companion
[OPTION 2] "What happened here?" → Lore exposition
[OPTION 3] "I'm not sure I can..." → Reassurance from spirit
```

### 1.4 Story Beats (First Season)

| Day | Event | Gameplay Impact |
|-----|-------|-----------------|
| **Day 1** | Arrive at cabin, meet first spirit | Tutorial: Movement, interaction |
| **Day 3** | Clear first debris, plant first seed | Tutorial: Tools, farming basics |
| **Day 7** | First harvest, spirit grows brighter | Unlock: Spirit dialogue, farm expansion |
| **Day 14** | Havenport representative visits | Quest: "Prove Your Worth" (earn 1000g) |
| **Day 21** | Echo Tree shows first leaves | Unlock: Nature magic basics |
| **Day 28** | Spirit festival, meet town NPCs | Social system introduction |

### 1.5 Integration with Existing Lore

This story can **complement** the existing Aethelgard Valley narrative:
- **Aunt Elara** could be related to **Elara the Myth-Keeper** in Hearthhaven
- **Echo Ridge Farm** could be the player's starting location before discovering Hearthhaven
- **Nature Spirits** could be related to the **Rift energy** in the main story
- **Havenport** could be a neighboring industrial town threatening the valley

---

## 2. The Farm: Echo Ridge — Detailed Breakdown

Echo Ridge is a 2D top-down, grid-based area (recommended: **50x50 tiles** at 16x16 pixels = 800x800 pixels), heavily overgrown and requiring significant cleanup.

### 2.1 Starting Layout

```
╔═══════════════════════════════════════════════════════╗
║  🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳  [Dense Forest Border]            ║
║  🌳🪨🪵🌿🌿🪨🪵🌿🪨🌳                                 ║
║  🌳🌿🏠🏠🌿🪨🪵🌿🪨🌳  🏠 = Dilapidated Cabin         ║
║  🌳🌿🏠🏠🪨🌿🌿🪨🌿🌳  🌳 = Trees / Dense vegetation  ║
║  🌳🪨🪨🪨🌿🌿🪵🌿🪨🌳  🪨 = Large stones              ║
║  🌳🌿🪵🪵🪨🌿🌿🪨🌿🌳  🪵 = Log stumps               ║
║  🌳🪨🌿🌿🌿🪨🪨🌿🪨🌳  🌿 = Dense weeds               ║
║  🌳🌿🪨🪵🌳🌳🌳🪨🌿🌳  🌊 = Creek (murky water)       ║
║  🌳🌿🪨🌿🌳🌳🌳🌿🪨🌳                                 ║
║  🌳🌿🌿🪨🌳🌳🌳🪨🌿🌳  [Center: Echo Tree area]       ║
║  🌳🪨🌿🪨🌳🌳🌳🌿🪨🌳                                 ║
║  🌳🌿🪨🌿🪨🌳🪨🌿🪨🌳                                 ║
║  🌳🪵🌿🪨🌿🪨🌿🪨🌿🌳                                 ║
║  🌳🌿🪨🌿🪵🌿🪨🌿🪨🌳  [Southwest: Creek area]        ║
║  🌳🪨🌿🌊🌊🌊🪨🌿🪨🌳                                 ║
║  🌳🌿🌊🌊🌊🌊🌊🪨🌿🌳                                 ║
║  🌳🌳🌳🌳🌳🌳🌳🌳🌳🌳  [Border]                       ║
╚═══════════════════════════════════════════════════════╝
```

### 2.2 Key Locations

#### The Cabin (Player Home)
**Initial State:**
- Small, one-room cottage (3x4 tiles, 48x64 pixels at 16px/tile)
- Sagging roof tiles (visual detail)
- Ivy growing on walls
- Broken porch step (interaction point for repair)

**Interior Features:**
- Small fireplace (warmth, cooking later)
- Bed (saves game, restores energy)
- Rustic table (holds Aunt Elara's journal)
- Storage chest (2x1 tiles, initially locked)

**Upgrades (Future):**
- Repair roof (500g, 50 wood)
- Fix porch (200g, 20 wood)
- Expand interior (2000g, unlock kitchen)

#### The Overgrown Fields
**Coverage:** Approximately 60% of the farmable area (30x40 tiles)

**Obstacle Distribution:**
- **30% Sticks/Twigs** — 1 hit with axe, drops 1 wood
- **30% Large Stones** — 2-3 hits with pickaxe, drops 1-2 stone
- **20% Dense Weeds** — 1 hit with scythe, drops fiber/seeds
- **20% Log Stumps** — 3-5 hits with axe, drops 3-5 wood

**Clearing Progression:**
| Area Cleared | Spirit Orb Grows | Unlocks |
|--------------|------------------|---------|
| 20% (Day 3-5) | Dim glow → Soft glow | First dialogue |
| 40% (Day 7-10) | Soft glow → Bright glow | Crop blessing ability |
| 60% (Day 14-18) | Bright glow → Radiant | Echo Tree awakens |
| 80% (Day 21+) | Radiant → Golden | Nature magic tutorial |

#### The "Echo" Tree
**Location:** Center of the farm (occupies 3x3 tiles)

**Description:** A giant, ancient, leafless tree that dominates the landscape. Its bark is silvery-gray with faint, glowing runes.

**Stages of Growth:**
1. **Initial (Day 1-20):** Completely leafless, dark
2. **First Awakening (Day 21):** Small green buds appear
3. **Budding (Day 35):** Quarter-covered in leaves
4. **Blooming (Day 50):** Half-covered, small flowers
5. **Radiant (Day 70):** Full foliage, glowing blossoms
6. **Spirit Sanctuary (Year 2+):** Spirits visibly gather here

**Interactions:**
- Touch tree → Spirit dialogue and lore
- Seasonal festivals held under tree
- Late-game: Tree produces rare "Echo Fruit" (once per season)

#### The Broken Greenhouse
**Location:** Northeast corner (occupies 6x4 tiles)

**Initial State:**
- Partially shattered glass (50% intact)
- Filled with rubble (20+ debris items)
- Overgrown with vines
- Door is off hinges

**Restoration Quest:**
| Phase | Cost | Gameplay Benefit |
|-------|------|------------------|
| **Phase 1: Clear Debris** | 0g (manual labor) | Access interior |
| **Phase 2: Repair Structure** | 5,000g, 100 wood, 50 stone | Functional space |
| **Phase 3: Replace Glass** | 3,000g, 50 quartz | Year-round growing |
| **Phase 4: Upgrade Systems** | 10,000g, special items | Ancient crops, spirits |

**Once Restored:**
- Grow crops year-round (ignores seasons)
- Rift-touched seeds grow faster
- Special "Ancient Seeds" can be planted (produce rare materials)

#### The Creek
**Location:** Southwest corner (flows 2-3 tiles wide)

**Initial State:**
- Murky, slow-moving water
- Littered with debris (old boots, bottles)
- Fish are scarce

**Stages of Restoration:**
1. **Polluted (Day 1-30):** No fishing possible
2. **Clearing (Day 31-50):** Remove 20+ trash items
3. **Purified (Day 51+):** Clear water, fish return

**Uses (Once Purified):**
- **Fishing:** Common creek fish (bass, catfish)
- **Irrigation:** Unlock sprinkler upgrades (auto-water nearby crops)
- **Spirit Gathering:** Spirits bathe here at night (aesthetic, lore)
- **Rare Spawn:** During full moon, "Lunar Carp" appear (valuable)

---

## 3. Essential Asset Breakdown

To create this in a **2D pixel-art style** (16x16 or 32x32 tiles), you will need the following asset categories:

### 3.1 Environment Tileset

**Recommended Size:** 16x16 pixels per tile (or 32x32 for higher detail)

| Tile Type | Variations | Purpose |
|-----------|-----------|---------|
| **Grass** | Normal, Dark, Long (3 variants) | Ground cover |
| **Dirt** | Tilled, Untilled, Dry, Wet (4 variants) | Farmland |
| **Water** | Flowing, Shallow, Deep, Creek (4 variants) | Creek system |
| **Paths** | Dirt, Stone, Wood (3 types) | Navigation |
| **Borders** | Forest edge, cliff edge (2 types) | Map boundaries |

**Spritesheet Layout Example:**
```
[grass_1][grass_2][grass_3][dirt_1][dirt_2][...]
[water_1][water_2][path_1][path_2][path_3][...]
```

### 3.2 Environmental Objects (Interactable)

These are **individual sprites** placed on the TileMap as objects:

#### Trees
- **Oak Tree:** Sapling (16x16) → Young (16x24) → Mature (32x32)
- **Maple Tree:** Sapling → Young → Mature (same sizes)
- **Pine Tree:** Sapling → Young → Mature (same sizes)
- **Echo Tree:** Special 3x3 tile object (48x48 @ 16px, or 96x96 @ 32px)

**Animation:** Gentle sway (2-3 frames, loops every 2 seconds)

#### Rocks & Obstacles
- **Small Rocks:** 4 visual variants (16x16 each)
- **Large Rocks:** 4 visual variants (32x32 each)
- **Stumps/Logs:** 3 variants (16x16 stumps, 32x16 logs)
- **Weeds:** Grass patches (8 variants, 16x16 each)

**Tool Response:**
- Hit animation (2-3 frames)
- Break animation (3-4 frames, object disappears)
- Drop items (wood, stone, fiber icons)

#### Buildings & Structures

| Building | Size (tiles) | Size (pixels @ 16px) | Purpose |
|----------|--------------|----------------------|---------|
| **Player Cabin** | 3x4 (exterior) | 48x64 | Home, save point |
| **Shipping Bin** | 2x1 | 32x16 | Sell items |
| **Chicken Coop** | 6x3 | 96x48 | Animal housing |
| **Basic Shed** | 7x3 | 112x48 | Storage |
| **Greenhouse** | 6x4 (interior: 5x3) | 96x64 | Year-round crops |

**Interior Tiles (for cabin/building interiors):**
- Wooden floor (4 variants)
- Stone floor (2 variants)
- Walls (with windows, doors)
- Furniture (bed, table, chairs, chests)

### 3.3 Character & Tools

#### Player Character
**Spritesheets Required:**

| Animation | Frames | Size per Frame | Grid Layout |
|-----------|--------|----------------|-------------|
| **Idle** (4 directions) | 1 per direction | 16x24 or 32x32 | 4x1 |
| **Walk** (4 directions) | 4 per direction | 16x24 or 32x32 | 4x4 |
| **Tool Use** (8 directions) | 3 per direction | 16x24 or 32x32 | 8x3 |
| **Interact** (4 directions) | 2 per direction | 16x24 or 32x32 | 4x2 |

**Total Sprites:** ~60 frames

#### Tools
**Icon Size:** 16x16 pixels

| Tool | Use Animation Frames | Drop Item |
|------|----------------------|-----------|
| **Watering Can** | 3 frames (fill, pour, empty) | Water splash VFX |
| **Hoe** | 3 frames (raise, swing, impact) | Tilled dirt tile |
| **Axe** | 3 frames (raise, swing, chop) | Wood (item drop) |
| **Pickaxe** | 3 frames (raise, swing, smash) | Stone (item drop) |
| **Scythe** | 2 frames (swing arc) | Fiber/seeds |

### 3.4 Crops & Items

#### Seeds & Crops
**Growth Stages:** 4-5 stages per crop

| Crop | Stages | Total Frames | Harvest Item Icon |
|------|--------|--------------|-------------------|
| **Turnips** | Seed → Sprout → Growth → Mature | 4 | 16x16 icon |
| **Wheat** | Seed → Sprout → Growth → Tall → Mature | 5 | 16x16 icon |
| **Tomatoes** | Seed → Sprout → Vine → Budding → Ripe | 5 | 16x16 icon |
| **Ancient Seeds** | Mystical glow variants (5 stages) | 5 | 16x16 animated icon |

**Spritesheet Layout:**
```
[turnip_1][turnip_2][turnip_3][turnip_4]
[wheat_1][wheat_2][wheat_3][wheat_4][wheat_5]
```

#### Forage Items
**Locations:** Found in forest, near creek, under trees

| Item | Icon Size | Rarity | Spawn Condition |
|------|-----------|--------|-----------------|
| **Wild Berries** | 16x16 | Common | Spring/Summer, bushes |
| **Mushrooms** | 16x16 | Uncommon | Fall, near stumps |
| **Wild Flowers** | 16x16 | Common | Spring, grass areas |
| **Echo Fruit** | 16x16 (glowing) | Rare | From Echo Tree (seasonal) |

### 3.5 UI Elements

#### HUD Components
- **Energy Bar:** 100x10 pixels (frame + fill)
- **Money Display:** Coin icon (16x16) + text
- **Time Display:** Clock icon (16x16) + text (e.g., "10:30 AM")
- **Date Display:** Calendar icon (16x16) + text (e.g., "Spring 15")
- **Tool Hotbar:** 5 slots (40x40 each) with tool icons

#### Spirit Orb (HUD Companion)
- **Idle Animation:** 3 frames, 24x24 pixels
- **Dialogue Portrait:** 64x64 pixels (for speech bubbles)
- **Emotions:** Happy, Sad, Excited, Worried (4 portraits)

---

## 4. How to Integrate and Add Assets (Godot Implementation)

This section provides **step-by-step instructions** for integrating assets into **Godot 4.6** (the engine this project uses).

### 4.1 Phase 1: Importing and Setup

#### Step 1: Prepare Assets
1. **Format:** Ensure all images are **PNG** with transparent backgrounds
2. **Organization:** Place images in appropriate folders:
   ```
   gfx/
   ├── terrain/          # Ground tiles
   ├── objects/          # Trees, rocks, stumps
   ├── buildings/        # Cabin, greenhouse, etc.
   ├── characters/       # Player spritesheet
   ├── tools/            # Tool icons and animations
   ├── crops/            # Crop growth stages
   ├── items/            # Forage items, materials
   ├── ui/               # HUD elements, icons
   └── spirits/          # Spirit orb animations
   ```

#### Step 2: Import into Godot
1. Place PNG files into `gfx/` subfolders
2. Godot will auto-import (watch for import completion)

#### Step 3: Configure Import Settings (CRITICAL for Pixel Art)
**Select all sprite images** in FileSystem dock, then in Import dock:

| Setting | Value | Purpose |
|---------|-------|---------|
| **Compress → Mode** | Lossless | Preserve pixel detail |
| **Filter** | **Nearest** | Prevent blur (critical!) |
| **Mipmaps** | Disabled | Avoid scaling artifacts |
| **Repeat** | Disabled | Tiles use TileSet instead |

Click **Reimport** after changes.

### 4.2 Phase 2: Creating the Farm TileMap

#### Step 1: Create Farm Scene
1. **Scene → New Scene**
2. Add **Node2D** as root, rename to `"Farm"`
3. Save as `scenes/farm/EchoRidgeFarm.tscn`

#### Step 2: Add TileMap Node
1. Right-click `Farm` → **Add Child Node** → **TileMapLayer**
2. Rename to `"GroundLayer"`
3. In Inspector:
   - **Tile Set → [New TileSet]**
   - Click the TileSet to open TileSet editor (bottom panel)

#### Step 3: Create TileSet
1. In TileSet editor, click **"+"** to add atlas
2. **Texture:** Select `gfx/terrain/terrain.png` (or your ground tileset)
3. **Texture Region Size:** 16x16 (match your tile size)
4. Click **"Setup"** to auto-create tiles

#### Step 4: Add Collision (for obstacles)
For **objects** like trees/rocks that block player movement:
1. Create a new TileMapLayer named `"ObstaclesLayer"` (above GroundLayer)
2. Add TileSet with obstacle sprites (trees, rocks, stumps)
3. In TileSet editor:
   - Select a tree tile
   - Go to **Physics Layer 0**
   - Click **"Paint Collision"** and draw a collision box
   - Repeat for all obstacle tiles

#### Step 5: Paint the Farm
1. Select `GroundLayer` in Scene tree
2. In TileMap editor (bottom):
   - Choose grass tiles and paint the base
   - Add dirt paths, water for the creek
3. Select `ObstaclesLayer`
   - Paint trees, rocks, stumps according to the layout diagram
   - Place cabin, Echo Tree (3x3 tiles)

### 4.3 Phase 3: Implementing Y-Sorting (Depth)

**Why:** You want the player to appear **behind** a tree when walking north (up), and **in front** of it when walking south (down).

#### Godot 4.6 Y-Sorting:
1. Select the root `Farm` node
2. In Inspector:
   - Enable **CanvasItem → Y Sort Enabled**
3. For all child nodes that need sorting (player, trees as Sprite2D, etc.):
   - Set **Ordering → Z Index** appropriately (e.g., player = 0, trees = 0)
   - Enable **Y Sort Enabled** if needed

#### Testing:
- Run scene (F5)
- Walk around trees — player should go behind/in front correctly

### 4.4 Phase 4: Adding Interactive Objects

#### Example: Interactable Tree
1. **Create Scene:** `scenes/farm/objects/Tree.tscn`
2. **Root Node:** `StaticBody2D` (or `Area2D` if not blocking movement)
3. **Add Children:**
   - **Sprite2D** (display tree image)
   - **CollisionShape2D** (interaction area)
4. **Attach Script:** `scripts/farm/objects/Tree.gd`

```gdscript
extends StaticBody2D

@export var health: int = 5  # Hits needed to chop down
@export var wood_drop: int = 3  # Wood dropped

func _ready():
    add_to_group("interactables")

func interact_with_tool(tool_name: String):
    if tool_name == "axe":
        health -= 1
        play_hit_animation()
        
        if health <= 0:
            drop_wood()
            queue_free()  # Remove tree

func play_hit_animation():
    # TODO: Play shake animation
    pass

func drop_wood():
    for i in range(wood_drop):
        # Spawn wood item
        var wood = preload("res://scenes/items/Wood.tscn").instantiate()
        wood.position = position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
        get_parent().add_child(wood)
```

#### Integration with Player Tool Use:
In `Player.gd`, when using axe:

```gdscript
func use_tool():
    var tool_name = current_tool.name.to_lower()  # e.g., "axe"
    
    # Raycast or Area2D check for nearby objects
    var interactables = get_tree().get_nodes_in_group("interactables")
    for obj in interactables:
        if obj.global_position.distance_to(global_position) < 32:  # 2 tiles
            if obj.has_method("interact_with_tool"):
                obj.interact_with_tool(tool_name)
```

### 4.5 Phase 5: Implementing the Spirit Orb Companion

#### Create Spirit Scene
1. **New Scene:** `scenes/spirits/SpiritOrb.tscn`
2. **Root:** `Node2D`
3. **Add Children:**
   - **AnimatedSprite2D** (for idle glow animation)
   - **Label** (for dialogue hints)

#### Script: `scripts/spirits/SpiritOrb.gd`

```gdscript
extends Node2D

enum State { DIM, SOFT, BRIGHT, RADIANT, GOLDEN }
var current_state: State = State.DIM

@onready var anim_sprite = $AnimatedSprite2D
@onready var dialogue_label = $Label

func _ready():
    update_appearance()

func update_state(farm_clear_percentage: float):
    if farm_clear_percentage >= 0.8:
        current_state = State.GOLDEN
    elif farm_clear_percentage >= 0.6:
        current_state = State.RADIANT
    elif farm_clear_percentage >= 0.4:
        current_state = State.BRIGHT
    elif farm_clear_percentage >= 0.2:
        current_state = State.SOFT
    else:
        current_state = State.DIM
    
    update_appearance()

func update_appearance():
    match current_state:
        State.DIM:
            anim_sprite.modulate = Color(0.3, 0.3, 0.3)
        State.SOFT:
            anim_sprite.modulate = Color(0.6, 0.6, 0.6)
        State.BRIGHT:
            anim_sprite.modulate = Color(1.0, 1.0, 1.0)
        State.RADIANT:
            anim_sprite.modulate = Color(1.2, 1.2, 1.0)
        State.GOLDEN:
            anim_sprite.modulate = Color(1.5, 1.4, 0.8)

func show_dialogue(text: String):
    dialogue_label.text = text
    dialogue_label.visible = true
    await get_tree().create_timer(3.0).timeout
    dialogue_label.visible = false
```

#### Integration:
Add to `Farm.tscn` as a child, position near player spawn point.

---

## 5. Quick Development Tips

### 5.1 Start with MVP (Minimum Viable Product)

**Week 1 Goals:**
- [ ] Player can move around farm (WASD controls)
- [ ] Player can swing axe (left-click)
- [ ] One tree can be chopped down (drops wood item)
- [ ] Wood item displays in simple inventory

**Implementation Order:**
1. Create Farm scene with basic grass TileMap
2. Import player character sprite (even placeholder)
3. Write basic movement script (see existing `scripts/player/PlayerController.gd`)
4. Add one tree as interactable object
5. Create simple "Wood" item scene
6. Test: Can I move and chop a tree?

### 5.2 Use Existing Assets as Starting Point

This project already has assets in `gfx/` folder. You can:
- **Overworld.png:** Use for base terrain
- **objects.png:** Extract tool sprites
- **character.png:** Player animations
- **crops_spritesheet.png:** Crop stages

To extract specific sprites from a spritesheet:
```gdscript
# In Godot, use AtlasTexture to slice spritesheets
var atlas = AtlasTexture.new()
atlas.atlas = preload("res://gfx/objects.png")
atlas.region = Rect2(0, 0, 16, 16)  # First 16x16 sprite
sprite.texture = atlas
```

### 5.3 Organize Folders Properly

Recommended structure (extends existing):
```
FarmHouse-Stories/
├── scenes/
│   ├── farm/
│   │   ├── EchoRidgeFarm.tscn       # NEW: Main Echo Ridge farm
│   │   ├── objects/
│   │   │   ├── Tree.tscn
│   │   │   ├── Rock.tscn
│   │   │   └── Stump.tscn
│   │   └── buildings/
│   │       ├── Cabin.tscn
│   │       └── Greenhouse.tscn
│   ├── spirits/
│   │   └── SpiritOrb.tscn           # NEW: Spirit companion
│   └── items/
│       ├── Wood.tscn
│       └── Stone.tscn
├── scripts/
│   ├── farm/
│   │   ├── objects/
│   │   │   ├── Tree.gd
│   │   │   └── Rock.gd
│   │   └── EchoRidgeFarmManager.gd  # NEW: Manages farm state
│   └── spirits/
│       └── SpiritOrb.gd              # NEW: Spirit logic
└── gfx/
    └── (existing assets + new Echo Ridge assets)
```

### 5.4 Free Asset Recommendations

If creating all assets is overwhelming, consider these free resources:

| Asset Pack | Source | License | Best For |
|------------|--------|---------|----------|
| **LPC Base Assets** | OpenGameArt.org | CC-BY-SA 3.0 | Characters, terrain |
| **Sproutlands** | Cup Nooble (itch.io) | Free (with credit) | Cute farm aesthetic |
| **Pixel Farm** | Cainos (itch.io) | Free | Buildings, crops |
| **Toon UI** | Crusenho (itch.io) | Free (attribution) | HUD elements (already in project!) |

**Already in this project:**
- `gfx/terrain/terrain.png` — LPC tileset (licensed)
- `gfx/ui/` — Complete UI pack (TravelBook theme)

### 5.5 Testing Checklist

After implementing each feature:
- [ ] Does it run without errors? (F5 in Godot)
- [ ] Are sprites showing correctly? (check import settings if blurry)
- [ ] Does collision work? (player can't walk through trees)
- [ ] Are items dropping properly? (wood appears when tree breaks)
- [ ] Is Y-sorting working? (player goes behind/in front correctly)

---

## 6. Integration with Existing FarmHouse Stories Systems

This Echo Ridge story can **enhance** the existing game:

### 6.1 Calendar System Integration

Use existing `CalendarSystem.gd`:
```gdscript
# In EchoRidgeFarmManager.gd
func _ready():
    Calendar.day_changed.connect(_on_day_changed)

func _on_day_changed(day: int, season: String):
    if day == 14 and season == "spring":
        trigger_havenport_visit()  # Story event
    
    if day == 21:
        echo_tree.start_awakening()  # Tree gets leaves
```

### 6.2 Event System Integration

Use existing `EventBus.gd`:
```gdscript
# Signal definitions to add to EventBus.gd:
signal spirit_orb_state_changed(new_state: int)
signal echo_tree_awakened()
signal farm_cleared_percentage(percent: float)

# In Tree.gd when chopped:
EventBus.emit_signal("farm_cleared_percentage", calculate_clear_percent())

# In EchoRidgeFarmManager.gd:
EventBus.farm_cleared_percentage.connect(_update_spirit_orb)
```

### 6.3 Save System Integration

Extend `SaveSystem.gd` to include Echo Ridge data:
```gdscript
# Add to save_game() function:
save_data["echo_ridge"] = {
    "spirit_orb_state": spirit_orb.current_state,
    "echo_tree_stage": echo_tree.growth_stage,
    "farm_clear_percent": farm_manager.get_clear_percentage(),
    "cabin_upgrades": cabin.upgrades_completed,
    "greenhouse_restored": greenhouse.is_restored
}
```

### 6.4 NPC Database Integration

Add Havenport NPCs to `NPCDatabase.gd`:
```gdscript
# In _initialize_npcs():
_npcs["havenport_rep"] = {
    "name": "Marcus Ironwood",
    "role": "Industrial Representative",
    "location": "Havenport (visits farm Day 14)",
    "dialogue": {
        "first_visit": "Your aunt's land... perfect for our processing plant.",
        "after_proof": "I see you've made progress. We'll... revisit this later."
    },
    "quest": "prove_farm_worth"
}
```

---

## 7. Story-Driven Gameplay Loop

### Week 1 (Days 1-7): Discovery
**Theme:** Learning and Exploration

| Day | Morning | Afternoon | Evening |
|-----|---------|-----------|---------|
| 1 | Arrive, meet Spirit Orb | Clear 5 debris | Read Aunt's journal |
| 2-3 | Clear more debris | Plant first seeds | Spirit teaches basics |
| 4-6 | Water crops | Explore farm edges | Discover Echo Tree |
| 7 | **First harvest!** | Spirit grows brighter | Unlock farm expansion |

### Week 2 (Days 8-14): Challenge
**Theme:** Pressure and Proof

- **Day 10:** Spirit warns of Havenport's interest
- **Day 12:** Find torn journal page (lore about Nature Spirits)
- **Day 14:** **Havenport Rep visits** — "Prove farm worth or sell" quest
  - Goal: Earn 1000g by Day 28 (Spring)
  - Penalty: Lose farm (non-canon game over)

### Week 3-4 (Days 15-28): Growth
**Theme:** Community and Connection

- **Day 18:** Creek starts clearing (aesthetic change)
- **Day 21:** **Echo Tree awakens** (first leaves appear)
  - Spirit Orb reaches Radiant state
  - Unlock nature magic tutorial (crop blessing)
- **Day 25:** Discover greenhouse (locked, requires quest)
- **Day 28:** **Spirit Festival** — Meet town NPCs, prove farm's value
  - If 1000g earned: Havenport backs off (for now)
  - Unlock Hearthhaven travel

---

## 8. Dialogue Examples

### Spirit Orb Progression

**Dim State (0-20% cleared):**
```
"The land... so tired. Help us... bloom again."
"Each stick you clear... brings warmth back."
```

**Soft Glow (20-40% cleared):**
```
"I can feel it! The earth remembers joy."
"You work like Elara did... with love."
```

**Bright State (40-60% cleared):**
```
"The Echo Tree stirs! Can you feel it?"
"Nature Spirits are returning to the valley."
```

**Radiant State (60-80% cleared):**
```
"You've done it! The balance is restoring!"
"I can teach you the old magics now."
```

**Golden State (80%+ cleared):**
```
"The land sings your name, friend."
"Elara would be so proud. You are the true inheritor."
```

### Aunt Elara's Journal Entries

**Entry 1 (Day 1, on table):**
```
"Spring 3rd — The Spirits grow weaker each year. 
The town doesn't understand what we're losing. 
If something happens to me, I pray my inheritor 
sees what I saw: this land is alive."
```

**Entry 2 (Day 12, found in debris):**
```
"Fall 18th — The Echo Tree remembers everything. 
When it blooms again, the valley will heal. 
But it needs belief. It needs care. 
Industrial farming killed the Spirits elsewhere. 
Never let that happen here."
```

**Entry 3 (Day 25, in greenhouse rubble):**
```
"Winter 2nd — I've sealed the greenhouse. 
Inside are Ancient Seeds from the first Bloom. 
Only someone who loves this land should open it. 
Restore the greenhouse. Restore the valley's heart."
```

### Havenport Representative Dialogue

**Day 14 (First Visit):**
```
MARCUS: "You must be Elara's... inheritor. 
I represent Havenport Development Corp. 
This land is wasted on one person. 
We can offer you 10,000 gold. Walk away."

[OPTION 1] "This farm is not for sale."
  → MARCUS: "Sentiment doesn't pay bills. Prove it's worth keeping."

[OPTION 2] "Why do you want it so badly?"
  → MARCUS: "Efficiency. Progress. The future."

[OPTION 3] "Give me time to decide."
  → MARCUS: "Fine. One season. If you can't make this work, sell."
```

**Day 28 (Festival, if 1000g earned):**
```
MARCUS: "I see you've... made progress. 
The town seems to like what you're doing. 
We'll revisit this conversation another time."
(Marcus leaves, but quest updates: "He'll be back...")
```

---

## 9. Debugging & Performance Tips

### Common Issues

| Problem | Solution |
|---------|----------|
| **Sprites are blurry** | Set Filter to "Nearest" in Import settings |
| **Player walks through trees** | Add CollisionShape2D to tree's StaticBody2D |
| **Y-sorting not working** | Enable Y Sort on parent Node2D and relevant children |
| **Crops won't water** | Check if crop has "watered" boolean and collision area |
| **Spirit Orb doesn't update** | Verify `farm_cleared_percentage` signal is emitting |
| **Game freezes when chopping** | Reduce tree health or optimize `interact_with_tool()` |

### Performance Optimization

**For large farms (50x50+ tiles):**
- Use TileMap layers instead of individual Sprite2D nodes for obstacles
- Limit active Area2D nodes (only check nearby objects)
- Use object pooling for dropped items (wood, stone)
- Cull off-screen objects:
  ```gdscript
  func _process(delta):
      visible = get_viewport_rect().intersects(get_rect())
  ```

---

## 10. Conclusion & Next Steps

### Summary

You now have:
- ✅ **Complete starting story** ("Echo Ridge Inheritance")
- ✅ **Detailed farm layout** (Echo Ridge with all key locations)
- ✅ **Comprehensive asset list** (tiles, objects, characters, UI)
- ✅ **Step-by-step integration guide** (Godot 4.6 specific)
- ✅ **Code examples** (Spirit Orb, Trees, Player interaction)
- ✅ **Development tips** (MVP approach, asset sources, testing)

### Recommended Implementation Order

**Phase 1 (Week 1-2):** Foundation
1. Set up EchoRidgeFarm.tscn with basic tilemap
2. Import and configure all sprites (Filter: Nearest!)
3. Place cabin, Echo Tree, obstacles

**Phase 2 (Week 3-4):** Interactivity
4. Implement Tree.gd (choppable, drops wood)
5. Create SpiritOrb.gd (state progression)
6. Add farm clearing percentage tracker

**Phase 3 (Week 5-6):** Story Events
7. Implement Day 14 Havenport visit cutscene
8. Add Echo Tree awakening (Day 21)
9. Create journal item (readable lore)

**Phase 4 (Week 7-8):** Polish
10. Add greenhouse restoration quest
11. Implement creek purification
12. Create Spirit Festival scene

### Further Reading

- **Existing Project Docs:**
  - `docs/07_ImplementationGuide.md` — Core gameplay systems
  - `docs/03_StardewValleyMechanics.md` — Farming mechanics
  - `docs/01_ProjectOverview.md` — Main storyline (Aethelgard Valley)

- **Godot Resources:**
  - [Official TileMap Tutorial](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)
  - [Signals & EventBus Pattern](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

### Questions?

This story concept complements the existing Aethelgard Valley narrative. Think of Echo Ridge as the "tutorial zone" before players discover the larger world of Hearthhaven, Echo Ridge Mountains, and Mythic Rifts.

---

**Happy farming! 🌾✨**

*Document Version: 1.0*  
*Last Updated: February 2026*  
*Compatible with: Godot 4.6, FarmHouse Stories v0.3+*
