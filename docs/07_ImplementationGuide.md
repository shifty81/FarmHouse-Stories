# Implementation Guide - Building FarmHouse Stories

## Overview

This guide provides a step-by-step approach to implementing FarmHouse Stories, a Stardew Valley-inspired farming game in Godot 4.6. Follow these phases sequentially for best results.

## Prerequisites

### Required Software
- **Godot Engine 4.6 beta1** (Windows 64-bit) or later
- **Code Editor:** VS Code with Godot extension (optional but recommended)
- **Git:** For version control

### Recommended Knowledge
- Basic GDScript programming
- Understanding of nodes and scenes in Godot
- Familiarity with 2D game development concepts

### Setup Steps

1. **Download Godot 4.6:**
   - Get from [godotengine.org](https://godotengine.org/download)
   - Extract and run the executable

2. **Clone Repository:**
   ```bash
   git clone https://github.com/shifty81/FarmHouse-Stories.git
   cd FarmHouse-Stories
   ```

3. **Open Project in Godot:**
   - Launch Godot 4.6
   - Import the project
   - Let Godot import all assets

## Phase 1: Foundation (Week 1-2)

### 1.1 Project Structure Setup

Create the basic folder structure:

```bash
mkdir -p assets/{gfx,audio,fonts}
mkdir -p assets/gfx/{characters,crops,tiles,objects,ui,animals,effects}
mkdir -p scenes/{player,farm,ui,systems}
mkdir -p scripts/{player,farm,ui,systems}
mkdir -p shaders
mkdir -p resources/{crops,items,recipes,animals}
mkdir -p addons
```

### 1.2 Project Settings Configuration

**Display Settings:**
```
Project -> Project Settings -> Display -> Window
- Width: 1280
- Height: 720
- Stretch Mode: canvas_items
- Stretch Aspect: keep
```

**Input Map:**
```
Project -> Project Settings -> Input Map
Add actions:
- move_up: W, Arrow Up
- move_down: S, Arrow Down
- move_left: A, Arrow Left
- move_right: D, Arrow Right
- interact: E, Space
- use_tool: Left Mouse Button
- cancel: Escape
- inventory: Tab, I
```

**Layer Names:**
```
Project -> Project Settings -> Layer Names -> 2D Physics
- Layer 1: World (walls, obstacles)
- Layer 2: Player
- Layer 3: NPCs
- Layer 4: Crops
- Layer 5: Interactables
- Layer 6: Items
```

### 1.3 Create Autoload Scripts

**EventBus.gd** (Global signals):
```gdscript
extends Node

# Time signals
signal day_started(day: int, season: String)
signal day_ended
signal hour_changed(hour: int)

# Player signals
signal player_energy_changed(energy: int, max_energy: int)
signal player_money_changed(money: int)
signal player_position_changed(position: Vector2)

# Farm signals
signal crop_planted(position: Vector2i, crop_type: String)
signal crop_watered(position: Vector2i)
signal crop_harvested(position: Vector2i, crop_type: String, quality: int)

# UI signals
signal inventory_opened
signal inventory_closed
signal dialogue_started
signal dialogue_ended

# Global game state
var current_day: int = 1
var current_season: String = "Spring"
var current_hour: int = 6
var player_money: int = 500
var player_energy: int = 100
var player_max_energy: int = 100
```

Add to **Project -> Project Settings -> Autoload:**
- Name: `EventBus`, Path: `res://scripts/systems/EventBus.gd`

**SaveSystem.gd** (Save/Load):
```gdscript
extends Node

const SAVE_FILE = "user://farmhouse_save.json"

func save_game():
    var save_data = {
        "version": "1.0",
        "timestamp": Time.get_datetime_string_from_system(),
        "player": {
            "position": {"x": 0, "y": 0},  # Will be filled by player
            "money": EventBus.player_money,
            "energy": EventBus.player_energy,
        },
        "calendar": {
            "day": EventBus.current_day,
            "season": EventBus.current_season,
            "hour": EventBus.current_hour,
        },
        "farm": {
            # Will be filled by farm system
        }
    }
    
    var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data, "\t"))
        file.close()
        print("Game saved successfully!")
        return true
    else:
        print("Failed to save game!")
        return false

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_FILE):
        print("No save file found")
        return {}
    
    var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
    if not file:
        print("Failed to open save file")
        return {}
    
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        print("Failed to parse save file")
        return {}
    
    print("Game loaded successfully!")
    return json.data

func has_save_file() -> bool:
    return FileAccess.file_exists(SAVE_FILE)
```

Add to Autoload: `SaveSystem`, Path: `res://scripts/systems/SaveSystem.gd`

## Phase 2: Player Character (Week 2-3)

### 2.1 Create Player Scene

**Player.tscn structure:**
```
Player (CharacterBody2D)
├── CollisionShape2D
├── AnimatedSprite2D
├── Camera2D
└── InteractionArea (Area2D)
    └── CollisionShape2D
```

**Player.gd:**
```gdscript
extends CharacterBody2D

@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

var last_direction: Vector2 = Vector2.DOWN

func _ready():
    camera.enabled = true

func _physics_process(delta):
    var input_direction = get_input_direction()
    
    if input_direction != Vector2.ZERO:
        apply_movement(input_direction, delta)
        last_direction = input_direction
        update_animation("walk")
    else:
        apply_friction(delta)
        update_animation("idle")
    
    move_and_slide()

func get_input_direction() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func apply_movement(direction: Vector2, delta: float):
    velocity = velocity.move_toward(direction * speed, acceleration * delta)

func apply_friction(delta: float):
    velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func update_animation(state: String):
    var direction_suffix = get_direction_suffix()
    var animation_name = state + "_" + direction_suffix
    
    if animated_sprite.sprite_frames.has_animation(animation_name):
        animated_sprite.play(animation_name)

func get_direction_suffix() -> String:
    if abs(last_direction.x) > abs(last_direction.y):
        return "right" if last_direction.x > 0 else "left"
    else:
        return "down" if last_direction.y > 0 else "up"

func _input(event):
    if event.is_action_pressed("interact"):
        attempt_interaction()

func attempt_interaction():
    # Will be implemented when we add interactable objects
    print("Interact!")
```

### 2.2 Create Placeholder Animations

Create a simple colored square sprite temporarily:

1. In Godot, create a 32x32 colored square PNG
2. Import into `assets/gfx/characters/player/`
3. Setup AnimatedSprite2D with animations:
   - idle_down, idle_up, idle_left, idle_right
   - walk_down, walk_up, walk_left, walk_right

## Phase 3: World and TileMap (Week 3-4)

### 3.1 Create Farm Scene

**Farm.tscn structure:**
```
Farm (Node2D)
├── GroundTileMap (TileMap) - Layer 0: Base ground
├── PathsTileMap (TileMap) - Layer 1: Paths, decorations  
├── PlantableArea (TileMap) - Layer 2: Where crops can grow
├── ObjectsTileMap (TileMap) - Layer 3: Trees, rocks, etc.
├── Player (instance of Player.tscn)
└── CropManager (Node)
```

**Farm.gd:**
```gdscript
extends Node2D

@onready var plantable_tilemap = $PlantableArea
@onready var crop_manager = $CropManager

func _ready():
    setup_farm()

func setup_farm():
    # Initialize farm state
    pass

func get_tile_at_position(world_pos: Vector2) -> Vector2i:
    return plantable_tilemap.local_to_map(plantable_tilemap.to_local(world_pos))

func is_plantable(tile_pos: Vector2i) -> bool:
    # Check if this tile can have crops
    var tile_data = plantable_tilemap.get_cell_tile_data(0, tile_pos)
    return tile_data != null
```

### 3.2 Create Simple Tileset

For prototyping, create colored tiles:
- Green = Grass (passable)
- Brown = Dirt/Farmland (plantable)
- Gray = Stone path (passable, not plantable)
- Dark Gray = Walls/obstacles (impassable)

Create a 16x16 or 32x32 tileset PNG and import into Godot.

## Phase 4: Basic Farming System (Week 4-5)

### 4.1 Create Crop Resource

**CropData.gd:**
```gdscript
class_name CropData extends Resource

@export var crop_name: String = ""
@export var growth_days: int = 4
@export var valid_seasons: Array[String] = ["Spring"]
@export var sell_price: int = 35
@export var seed_price: int = 20
@export var regrows: bool = false
@export var regrow_days: int = 0
@export_range(0, 4) var growth_stages: int = 3

# Textures for each growth stage
@export var stage_textures: Array[Texture2D] = []
```

Create crop resources:
- `resources/crops/parsnip.tres`
- `resources/crops/cauliflower.tres`
- etc.

### 4.2 Create Crop Node

**Crop.tscn structure:**
```
Crop (Node2D)
└── Sprite2D
```

**Crop.gd:**
```gdscript
extends Node2D

var crop_data: CropData
var current_day: int = 0
var is_watered: bool = false
var current_stage: int = 0

@onready var sprite = $Sprite2D

signal harvest_ready(crop: Node2D)

func initialize(data: CropData):
    crop_data = data
    update_visual()

func water():
    if not is_watered:
        is_watered = true
        # Add visual feedback (e.g., color modulation)
        sprite.modulate = Color(0.8, 0.8, 1.0)

func advance_day():
    if is_watered:
        current_day += 1
        is_watered = false
        sprite.modulate = Color.WHITE
        
        # Check for growth
        var days_per_stage = float(crop_data.growth_days) / crop_data.growth_stages
        var new_stage = int(current_day / days_per_stage)
        
        if new_stage != current_stage and new_stage <= crop_data.growth_stages:
            current_stage = new_stage
            update_visual()
            
            if is_mature():
                harvest_ready.emit(self)

func is_mature() -> bool:
    return current_stage >= crop_data.growth_stages

func harvest() -> Dictionary:
    if not is_mature():
        return {}
    
    var result = {
        "crop_name": crop_data.crop_name,
        "value": crop_data.sell_price,
        "quality": 1  # Normal quality for now
    }
    
    if crop_data.regrows:
        # Reset for regrowth
        current_day = crop_data.growth_days - crop_data.regrow_days
        current_stage = crop_data.growth_stages - 1
        update_visual()
    else:
        queue_free()
    
    return result

func update_visual():
    if crop_data and crop_data.stage_textures.size() > current_stage:
        sprite.texture = crop_data.stage_textures[current_stage]
```

### 4.3 Create Crop Manager

**CropManager.gd:**
```gdscript
extends Node

var planted_crops: Dictionary = {}  # {Vector2i: Crop}

const CROP_SCENE = preload("res://scenes/farm/Crop.tscn")

func plant_crop(tile_pos: Vector2i, crop_data: CropData):
    if planted_crops.has(tile_pos):
        return false
    
    var crop = CROP_SCENE.instantiate()
    add_child(crop)
    
    # Position crop at tile center
    var world_pos = get_parent().plantable_tilemap.map_to_local(tile_pos)
    crop.position = world_pos
    
    crop.initialize(crop_data)
    crop.harvest_ready.connect(_on_crop_ready_to_harvest)
    
    planted_crops[tile_pos] = crop
    EventBus.crop_planted.emit(tile_pos, crop_data.crop_name)
    
    return true

func water_crop(tile_pos: Vector2i):
    if planted_crops.has(tile_pos):
        planted_crops[tile_pos].water()
        EventBus.crop_watered.emit(tile_pos)

func harvest_crop(tile_pos: Vector2i) -> Dictionary:
    if not planted_crops.has(tile_pos):
        return {}
    
    var crop = planted_crops[tile_pos]
    if not crop.is_mature():
        return {}
    
    var result = crop.harvest()
    
    if not crop.crop_data.regrows:
        planted_crops.erase(tile_pos)
    
    EventBus.crop_harvested.emit(tile_pos, result.crop_name, result.quality)
    return result

func advance_all_crops():
    for crop in planted_crops.values():
        crop.advance_day()

func _on_crop_ready_to_harvest(crop: Node2D):
    print("Crop ready to harvest at: ", crop.position)
```

## Phase 5: Time and Calendar System (Week 5-6)

### 5.1 Create Calendar System

**CalendarSystem.gd:**
```gdscript
extends Node

const SEASONS = ["Spring", "Summer", "Fall", "Winter"]
const DAYS_PER_SEASON = 28
const HOURS_PER_DAY = 24
const MINUTES_PER_HOUR = 60

# Time passes faster in-game (1 real second = X game minutes)
@export var time_scale: float = 60.0  # 1 real second = 60 game seconds = 1 game minute

var current_season_index: int = 0
var current_day: int = 1
var current_year: int = 1
var current_hour: int = 6
var current_minute: int = 0

var time_paused: bool = false
var time_accumulator: float = 0.0

func _ready():
    EventBus.current_day = current_day
    EventBus.current_season = SEASONS[current_season_index]
    EventBus.current_hour = current_hour

func _process(delta):
    if time_paused:
        return
    
    time_accumulator += delta * time_scale
    
    # Each accumulator unit = 1 game second
    while time_accumulator >= 60.0:  # 60 seconds = 1 minute
        time_accumulator -= 60.0
        advance_minute()

func advance_minute():
    current_minute += 1
    
    if current_minute >= MINUTES_PER_HOUR:
        current_minute = 0
        advance_hour()

func advance_hour():
    current_hour += 1
    EventBus.hour_changed.emit(current_hour)
    
    # Force sleep at 2 AM
    if current_hour >= 26:  # 2 AM next day
        end_day()

func end_day():
    EventBus.day_ended.emit()
    
    # Reset to next morning
    current_day += 1
    current_hour = 6
    current_minute = 0
    
    if current_day > DAYS_PER_SEASON:
        advance_season()
    
    EventBus.current_day = current_day
    EventBus.current_hour = current_hour
    EventBus.day_started.emit(current_day, SEASONS[current_season_index])
    
    # Advance farm crops
    get_tree().call_group("crops", "advance_day")

func advance_season():
    current_day = 1
    current_season_index = (current_season_index + 1) % SEASONS.size()
    
    if current_season_index == 0:  # Back to Spring
        current_year += 1
    
    EventBus.current_season = SEASONS[current_season_index]

func get_time_string() -> String:
    var hour_12 = current_hour % 12
    if hour_12 == 0:
        hour_12 = 12
    var am_pm = "AM" if current_hour < 12 else "PM"
    return "%02d:%02d %s" % [hour_12, current_minute, am_pm]

func get_date_string() -> String:
    return "%s %d, Year %d" % [SEASONS[current_season_index], current_day, current_year]
```

Add to Autoload as `Calendar`.

## Phase 6: Basic UI (Week 6-7)

### 6.1 Create HUD

**HUD.tscn structure:**
```
HUD (CanvasLayer)
└── MarginContainer
    └── VBoxContainer
        ├── TimeLabel
        ├── DateLabel
        ├── MoneyLabel
        └── EnergyBar (ProgressBar)
```

**HUD.gd:**
```gdscript
extends CanvasLayer

@onready var time_label = $MarginContainer/VBoxContainer/TimeLabel
@onready var date_label = $MarginContainer/VBoxContainer/DateLabel
@onready var money_label = $MarginContainer/VBoxContainer/MoneyLabel
@onready var energy_bar = $MarginContainer/VBoxContainer/EnergyBar

func _ready():
    EventBus.hour_changed.connect(_on_hour_changed)
    EventBus.day_started.connect(_on_day_started)
    EventBus.player_money_changed.connect(_on_money_changed)
    EventBus.player_energy_changed.connect(_on_energy_changed)
    
    update_display()

func _process(_delta):
    time_label.text = Calendar.get_time_string()

func update_display():
    date_label.text = Calendar.get_date_string()
    money_label.text = "Gold: %d" % EventBus.player_money
    energy_bar.max_value = EventBus.player_max_energy
    energy_bar.value = EventBus.player_energy

func _on_hour_changed(_hour):
    update_display()

func _on_day_started(_day, _season):
    update_display()

func _on_money_changed(_money):
    update_display()

func _on_energy_changed(_energy, _max_energy):
    update_display()
```

## Phase 7: Tool System (Week 7-8)

### 7.1 Create Tool System

**Tool.gd (base class):**
```gdscript
class_name Tool extends Resource

@export var tool_name: String = ""
@export var tool_type: String = ""  # "hoe", "watering_can", "axe", "pickaxe"
@export var energy_cost: int = 2
@export var use_range: float = 40.0
@export var upgrade_level: int = 0  # 0=basic, 1=copper, 2=iron, 3=gold, 4=iridium

func use(user: CharacterBody2D, target_position: Vector2) -> bool:
    if EventBus.player_energy < energy_cost:
        print("Not enough energy!")
        return false
    
    EventBus.player_energy -= energy_cost
    EventBus.player_energy_changed.emit(EventBus.player_energy, EventBus.player_max_energy)
    
    return perform_action(user, target_position)

func perform_action(_user: CharacterBody2D, _target_position: Vector2) -> bool:
    # Override in specific tool classes
    return false
```

Create specific tool scripts (HoeTool.gd, WateringCanTool.gd, etc.) that extend Tool.

## Phase 8: Cell Shading Implementation (Week 8)

### 8.1 Create Cell Shader

See `02_CellShadingTechniques.md` for detailed shader code.

Apply to sprites:
```gdscript
# In Player._ready() or Farm._ready()
func apply_cell_shading():
    var shader_material = preload("res://shaders/materials/cell_shader_material.tres")
    $AnimatedSprite2D.material = shader_material
```

## Testing Checklist

After each phase, verify:

- [ ] No console errors
- [ ] Player moves smoothly
- [ ] Crops plant and grow correctly
- [ ] Time advances properly
- [ ] UI updates correctly
- [ ] Save/load works
- [ ] Performance is acceptable (60 FPS)

## Next Steps

Once foundation is complete:
1. Add inventory system
2. Implement NPCs and dialogue
3. Add fishing mini-game
4. Create mining system
5. Add crafting stations
6. Implement shop and economy
7. Create save/load UI
8. Add sound effects and music
9. Polish and optimize

---

**Related Documentation:**
- `01_ProjectOverview.md` - Project vision
- `03_StardewValleyMechanics.md` - Feature reference
- `06_GodotResources.md` - Godot guides
