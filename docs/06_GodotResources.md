# Godot 4.6 Resources and Learning Guide

## Official Godot Documentation

### Essential Reading

1. **[Godot 4.6 Documentation](https://docs.godotengine.org/en/stable/)**
   - Complete reference for all engine features
   - Tutorials for beginners and advanced users
   - API reference for all nodes and methods

2. **[GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)**
   - Language syntax and features
   - Best practices and style guide
   - Common patterns and anti-patterns

3. **[2D Game Development](https://docs.godotengine.org/en/stable/tutorials/2d/index.html)**
   - 2D-specific features and workflows
   - Physics and collision
   - Lighting and shaders

## Key Godot 4.6 Features for FarmHouse Stories

### 1. TileMap System

**Documentation:** [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)

**Key Improvements in Godot 4.6:**
- Multiple layers per TileMap node
- Enhanced editor with better visibility
- Improved collision and navigation
- Terrain system for auto-tiling
- Physics layers for complex interactions

**Quick Start:**
```gdscript
extends TileMap

func _ready():
    # Get specific tile data
    var tile_data = get_cell_tile_data(0, Vector2i(5, 5))
    
    # Set a tile
    set_cell(0, Vector2i(10, 10), 0, Vector2i(2, 3))
    
    # Clear a tile
    erase_cell(0, Vector2i(10, 10))

func convert_world_to_grid(world_pos: Vector2) -> Vector2i:
    return local_to_map(to_local(world_pos))

func convert_grid_to_world(grid_pos: Vector2i) -> Vector2:
    return to_global(map_to_local(grid_pos))
```

**Learning Resources:**
- [GDQuest TileMap Basics](https://www.gdquest.com/library/cheatsheet_tilemap_basics/)
- [Official TileMap Tutorial](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)

### 2. CharacterBody2D for Player Movement

**Best for:** Top-down player controllers

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta):
    # Get input direction
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Set velocity
    velocity = input_direction * speed
    
    # Move and handle collisions
    move_and_slide()
```

**Advanced Features:**
- Built-in collision detection
- Smooth motion with interpolation
- Platform collision layers
- One-way platforms support

### 3. AnimationPlayer and AnimatedSprite2D

**For Character Animation:**

```gdscript
extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

func update_animation():
    if velocity.length() > 0:
        # Determine direction
        if abs(velocity.x) > abs(velocity.y):
            if velocity.x > 0:
                animated_sprite.play("walk_right")
            else:
                animated_sprite.play("walk_left")
        else:
            if velocity.y > 0:
                animated_sprite.play("walk_down")
            else:
                animated_sprite.play("walk_up")
    else:
        # Play idle animation based on last direction
        animated_sprite.play("idle_down")  # Or remember last direction
```

### 4. Signals and Events

**Core Communication Pattern:**

```gdscript
# Define signal
signal crop_harvested(crop_type: String, quality: int)
signal day_ended
signal energy_changed(new_energy: int)

# Emit signal
crop_harvested.emit("Parsnip", 2)

# Connect in another script
func _ready():
    var farm = get_node("/root/Farm")
    farm.crop_harvested.connect(_on_crop_harvested)

func _on_crop_harvested(crop_type: String, quality: int):
    print("Harvested: ", crop_type, " Quality: ", quality)
```

**Benefits:**
- Decoupled code architecture
- Easy to maintain and extend
- Clear data flow

### 5. Resource System

**For Game Data:**

```gdscript
# Create a crop resource
class_name CropData extends Resource

@export var crop_name: String = ""
@export var growth_time: int = 4
@export var seasons: Array[String] = []
@export var sell_price: int = 50
@export var growth_stages: Array[Texture2D] = []
@export var regrows: bool = false
```

**Save as .tres file and load:**
```gdscript
var parsnip_data = load("res://resources/crops/parsnip.tres") as CropData
print(parsnip_data.crop_name)  # "Parsnip"
```

### 6. Shader Language

**For Cell Shading:**

See `02_CellShadingTechniques.md` for detailed shader examples.

**Quick Reference:**
```gdshader
shader_type canvas_item;

uniform float some_value : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D some_texture;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex;
}
```

## Godot 4.6 Workflow Improvements

### Editor Enhancements

1. **Modern Theme:** Clean, professional interface
2. **Better Debugger:** Enhanced object inspection
3. **Improved Asset Management:** Faster import and organization
4. **Scene Inheritance:** Easier to manage scene variants

### Performance

- **Jolt Physics:** New default physics engine (mainly 3D, but benefits 2D too)
- **Optimized Rendering:** Better 2D batching
- **Faster Compilation:** Quicker iteration times

## Essential Plugins and Add-ons

### For Farming Games

1. **Dialogue Manager**
   - **Link:** [GitHub](https://github.com/nathanhoad/godot_dialogue_manager)
   - **Features:** Visual dialogue editor, branching conversations
   - **License:** MIT

2. **Inventory System Template**
   - Various on GitHub and Godot Asset Library
   - Look for Godot 4.x compatibility

3. **Quest System**
   - Community-developed quest frameworks
   - Can be adapted from RPG templates

### Development Tools

1. **GUT (Godot Unit Testing)**
   - **Link:** [GitHub](https://github.com/bitwes/Gut)
   - **Purpose:** Unit testing framework

2. **Godot Console**
   - In-game debugging console
   - Useful for testing and cheats

## Learning Path for Godot 4.6

### Week 1-2: Fundamentals

**Focus:** Basic Godot concepts
- [ ] Complete "Your First 2D Game" tutorial
- [ ] Learn scene system and node hierarchy
- [ ] Practice GDScript basics
- [ ] Understand signals and connections

**Resources:**
- [Official Getting Started](https://docs.godotengine.org/en/stable/getting_started/introduction/index.html)
- [GDQuest's Free Godot Course](https://www.gdquest.com/tutorial/godot/learning-paths/beginner/)

### Week 3-4: 2D Specific

**Focus:** 2D game development
- [ ] TileMap creation and usage
- [ ] Character controller implementation
- [ ] Collision and physics
- [ ] Camera2D setup and limits

**Resources:**
- [2D Movement Tutorial](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
- [TileMap Guide](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)

### Week 5-6: Game Systems

**Focus:** Core game mechanics
- [ ] Inventory system
- [ ] Save/load functionality
- [ ] UI design and menus
- [ ] State machines

**Resources:**
- Godot Demo Projects (study the examples)
- Community tutorials on YouTube

### Week 7-8: Advanced Topics

**Focus:** Polish and optimization
- [ ] Shader creation and effects
- [ ] Particle systems
- [ ] Audio management
- [ ] Performance optimization

**Resources:**
- [Shading Language](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html)
- GDQuest shader tutorials

## Code Patterns and Best Practices

### Scene Organization

```
Game/
├── Main.tscn (root scene)
├── Player/
│   └── Player.tscn (player character)
├── Farm/
│   ├── Farm.tscn (main farm area)
│   ├── Crops/
│   │   └── Crop.tscn (generic crop scene)
│   └── Animals/
│       └── Animal.tscn (generic animal scene)
├── UI/
│   ├── HUD.tscn
│   ├── Inventory.tscn
│   └── Menus/
└── Systems/
    ├── TimeSystem.tscn
    ├── SaveSystem.gd (autoload)
    └── EventBus.gd (autoload)
```

### Autoload (Singleton) Pattern

**For Global Systems:**

```gdscript
# Create EventBus.gd
extends Node

# Global signals
signal day_changed(day: int)
signal season_changed(season: String)
signal player_energy_changed(energy: int)

# Global state
var current_day: int = 1
var current_season: String = "Spring"
var player_money: int = 500

# Add to Project -> Project Settings -> Autoload
```

**Usage:**
```gdscript
# From anywhere in the game
EventBus.player_money += 100
EventBus.day_changed.emit(EventBus.current_day)
```

### Save/Load System

```gdscript
# SaveSystem.gd (autoload)
extends Node

const SAVE_PATH = "user://savegame.save"

func save_game():
    var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if save_file == null:
        print("Error opening save file!")
        return
    
    var save_data = {
        "player": {
            "position": get_node("/root/Main/Player").position,
            "money": EventBus.player_money,
        },
        "farm": {
            "crops": get_farm_crop_data(),
        },
        "calendar": {
            "day": EventBus.current_day,
            "season": EventBus.current_season,
        }
    }
    
    save_file.store_line(JSON.stringify(save_data))
    save_file.close()

func load_game():
    if not FileAccess.file_exists(SAVE_PATH):
        print("No save file found!")
        return
    
    var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var json_string = save_file.get_line()
    save_file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_string)
    if parse_result != OK:
        print("Error parsing save file!")
        return
    
    var save_data = json.data
    
    # Restore game state
    get_node("/root/Main/Player").position = Vector2(save_data.player.position.x, save_data.player.position.y)
    EventBus.player_money = save_data.player.money
    EventBus.current_day = save_data.calendar.day
    EventBus.current_season = save_data.calendar.season
```

### State Machine Pattern

```gdscript
# PlayerStateMachine.gd
class_name StateMachine extends Node

var current_state: State
var states: Dictionary = {}

func _ready():
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.transition_requested.connect(_on_transition_requested)
    
    if states.size() > 0:
        current_state = states.values()[0]
        current_state.enter()

func _process(delta):
    if current_state:
        current_state.update(delta)

func _physics_process(delta):
    if current_state:
        current_state.physics_update(delta)

func _on_transition_requested(from: State, to_state_name: String):
    if from != current_state:
        return
    
    var new_state = states.get(to_state_name.to_lower())
    if not new_state:
        return
    
    if current_state:
        current_state.exit()
    
    current_state = new_state
    current_state.enter()

# Base State class
class_name State extends Node

signal transition_requested(from: State, to_state_name: String)

func enter():
    pass

func exit():
    pass

func update(delta: float):
    pass

func physics_update(delta: float):
    pass
```

## Performance Optimization Tips

### For Farming Games

1. **Use Object Pooling** for frequently created/destroyed objects
2. **Limit Active Updates:** Only update visible/nearby objects
3. **Batch Rendering:** Group similar sprites together
4. **Optimize Collision:** Use appropriate collision layers and masks
5. **Profile Regularly:** Use Godot's built-in profiler

### Memory Management

```gdscript
# Good: Preload resources
const CROP_SCENE = preload("res://scenes/crops/Crop.tscn")

# Bad: Load at runtime repeatedly
# var crop = load("res://scenes/crops/Crop.tscn").instantiate()

# Good: Instance from preloaded
var crop = CROP_SCENE.instantiate()
```

## Common Pitfalls and Solutions

### Issue: TileMap coordinates confusion
**Solution:** Always use `local_to_map()` and `map_to_local()` for conversions

### Issue: Signals not connecting
**Solution:** Check node paths and use `@onready` variables

### Issue: Physics not working correctly
**Solution:** Verify collision layers and masks in Project Settings

### Issue: Poor performance with many sprites
**Solution:** Use CanvasGroup for batching, limit shader complexity

## Community and Support

### Where to Get Help

1. **Godot Discord:** Real-time community support
2. **Godot Forum:** Detailed technical discussions
3. **Reddit r/godot:** General questions and showcases
4. **GitHub Issues:** Engine bugs and feature requests

### Learning Communities

- **GDQuest:** Professional tutorials and courses
- **HeartBeast:** YouTube tutorials
- **Brackeys (archived):** Game development fundamentals
- **Game from Scratch:** Godot news and tutorials

## Quick Reference

### Input Handling
```gdscript
# Project Settings -> Input Map
# Define actions: move_left, move_right, move_up, move_down, interact

func _input(event):
    if event.is_action_pressed("interact"):
        interact_with_object()

func _process(delta):
    if Input.is_action_pressed("move_left"):
        move_left()
```

### Timers
```gdscript
# Using Timer node
@onready var timer = $Timer

func _ready():
    timer.timeout.connect(_on_timer_timeout)
    timer.start(2.0)  # 2 seconds

func _on_timer_timeout():
    print("Timer finished!")

# Using await (Godot 4 style)
await get_tree().create_timer(2.0).timeout
print("2 seconds passed!")
```

### Random Numbers
```gdscript
# Random integer
var random_int = randi() % 10  # 0-9

# Random float
var random_float = randf()  # 0.0-1.0

# Random range
var random_range = randf_range(5.0, 10.0)  # 5.0-10.0

# Random from array
var items = ["apple", "banana", "orange"]
var random_item = items[randi() % items.size()]
```

---

**Related Documentation:**
- `01_ProjectOverview.md` - Project introduction
- `02_CellShadingTechniques.md` - Shader programming
- `07_ImplementationGuide.md` - Practical implementation steps
