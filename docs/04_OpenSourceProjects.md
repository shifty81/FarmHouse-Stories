# Open Source Farming Game Projects

## Overview

This document catalogs open-source farming simulation games and projects built with Godot that can serve as references, learning resources, and inspiration for FarmHouse Stories.

## Godot Farming Game Projects

### 1. Pupi's Farm (2D Top-Down Farming Game)

**Repository:** [rehawild/2D-Topdown-Farming-Game](https://github.com/rehawild/2D-Topdown-Farming-Game)

**Description:**
A comprehensive 2D top-down farming game created in Godot with a focus on learning and extensibility.

**Key Features:**
- Planting, growing, and harvesting crops
- Resource management system
- Day and night cycle implementation
- NPC interaction system
- Various farming tools (hoe, watering can, etc.)
- Save/load system
- Inventory management

**License:** MIT (typically)

**Why It's Useful:**
- Well-structured code for learning
- Implements core farming mechanics
- Good starting point for prototyping
- Active development and community

**What to Learn:**
```gdscript
# Example patterns from this project:
# - Crop growth state machines
# - Tile-based farming system
# - Resource collection patterns
# - Save/load data persistence
```

---

### 2. Gadget HQ's 2D Farming Game

**Repository:** [gadget-hq/2d-farming-game](https://github.com/gadget-hq/2d-farming-game)

**Description:**
A learning-focused farming game built as part of a comprehensive video tutorial series.

**Key Features:**
- Progressive tutorial structure
- Core farming mechanics
- Modular code design
- Uses community assets (Sprout Lands Asset Pack)
- Step-by-step implementation guide

**License:** MIT

**Why It's Useful:**
- Great for beginners
- Code corresponds to video tutorials
- Clean, well-commented code
- Shows progression from simple to complex

**Tutorial Series:**
Each commit/branch represents a tutorial step, making it easy to follow along and understand the development process.

---

### 3. Godot 2D Top-Down Game Template

**Forum:** [Godot Forum Thread](https://forum.godotengine.org/t/i-created-a-godot-template-for-2d-top-down-games/95350)

**Description:**
A comprehensive template for building any 2D top-down game including adventure, RPG, and farming simulators.

**Key Features:**
- Robust character controller
- Inventory system
- Dialogue system with branching
- State management
- Quest system
- Scene transition system
- Polish and juice (screen shake, particles, etc.)

**Why It's Useful:**
- Production-ready foundation
- Professional code structure
- Extensive documentation
- Saves months of foundational work
- Highly customizable

**Components to Adopt:**
- Character movement and animation
- Input handling system
- UI framework
- Event/signal architecture

---

### 4. Croptails - Video Tutorial Series

**YouTube Playlist:** [Croptails Farming Game Series](https://www.youtube.com/playlist?list=PLWTXKdBN8RZe3ytf6qdR4g1JRy0j-93v9)

**Description:**
Comprehensive 8+ hour video series building a complete 2D top-down farming game from scratch in Godot.

**Topics Covered:**
- TileMap setup and usage
- Crop planting and growth systems
- Day/night cycle implementation
- Inventory and UI systems
- NPC characters and dialogue
- Save/load functionality
- Audio and visual effects

**Why It's Useful:**
- Step-by-step visual learning
- Explains the "why" behind design decisions
- Shows debugging and problem-solving
- Community in comments section

**How to Use:**
Follow along to build your own version, then reference the code for specific implementations.

---

## General Godot Game Projects

### 5. Godot Demo Projects

**Repository:** [godotengine/godot-demo-projects](https://github.com/godotengine/godot-demo-projects)

**Relevant Demos:**
- 2D Platformer (character controller patterns)
- Isometric Game (tile-based world)
- Inventory System demos
- Dialogue System examples

**Why It's Useful:**
- Official examples from Godot team
- Best practices and patterns
- Updated for each Godot version
- Well-documented code

---

### 6. Heartbeast's Action RPG Tutorial

**Repository/Tutorial:** Available on YouTube and itch.io

**Key Systems:**
- Top-down character movement
- Combat mechanics
- Health and damage systems
- Enemy AI patterns
- Room/scene transitions

**Why It's Useful:**
- Clean code architecture
- Excellent for understanding state machines
- Well-explained design patterns
- Active community support

---

## Asset Packs and Resources

### Free Asset Packs for Farming Games

#### 1. Sprout Lands Asset Pack
- **Link:** [itch.io](https://cupnooble.itch.io/sprout-lands-asset-pack)
- **License:** Free for commercial use with attribution
- **Contains:** Characters, crops, buildings, tiles, UI elements
- **Style:** Cute, colorful pixel art

#### 2. Pixel Farm Asset Pack
- **Link:** Various on itch.io
- **Contains:** Animals, crops, tools, buildings
- **Style:** 16x16 or 32x32 pixel art

#### 3. Farming Tilesets
- **OpenGameArt.org:** Multiple free farming tilesets
- **License:** Various (check each asset)
- **Great for:** Prototyping and learning

---

## Code Patterns to Study

### 1. State Machine Pattern

```gdscript
# From various open-source projects
class_name StateMachine extends Node

var current_state: State
var states: Dictionary = {}

func _ready():
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_machine = self
    
    current_state = states.values()[0]
    current_state.enter()

func change_state(new_state_name: String):
    if current_state:
        current_state.exit()
    
    current_state = states[new_state_name]
    current_state.enter()

func _process(delta):
    if current_state:
        current_state.update(delta)

func _physics_process(delta):
    if current_state:
        current_state.physics_update(delta)
```

### 2. Grid-Based Planting System

```gdscript
# Pattern from multiple farming game projects
class_name FarmGrid extends TileMap

var planted_crops: Dictionary = {}  # {Vector2i: Crop}

func plant_crop(grid_pos: Vector2i, crop_data: CropResource):
    if can_plant_at(grid_pos):
        var crop = Crop.new()
        crop.initialize(crop_data)
        planted_crops[grid_pos] = crop
        update_tile_at(grid_pos, crop.get_current_sprite())

func can_plant_at(grid_pos: Vector2i) -> bool:
    return not planted_crops.has(grid_pos) and is_tilled(grid_pos)

func water_crop(grid_pos: Vector2i):
    if planted_crops.has(grid_pos):
        planted_crops[grid_pos].water()

func advance_day():
    for pos in planted_crops:
        planted_crops[pos].grow()
        if planted_crops[pos].is_mature():
            enable_harvest_at(pos)
```

### 3. Inventory System Pattern

```gdscript
# Common inventory pattern from open-source projects
class_name Inventory extends Node

signal item_added(item: Item, amount: int)
signal item_removed(item: Item, amount: int)

var items: Array[ItemStack] = []
var max_slots: int = 36

class ItemStack:
    var item: Item
    var amount: int
    
    func _init(p_item: Item, p_amount: int = 1):
        item = p_item
        amount = p_amount

func add_item(item: Item, amount: int = 1) -> bool:
    # Try to stack with existing
    for stack in items:
        if stack.item == item and stack.amount < item.max_stack:
            var space = item.max_stack - stack.amount
            var to_add = min(space, amount)
            stack.amount += to_add
            amount -= to_add
            item_added.emit(item, to_add)
            
            if amount == 0:
                return true
    
    # Create new stack if slots available
    if items.size() < max_slots and amount > 0:
        items.append(ItemStack.new(item, amount))
        item_added.emit(item, amount)
        return true
    
    return false  # Inventory full

func remove_item(item: Item, amount: int = 1) -> bool:
    for i in range(items.size()):
        if items[i].item == item:
            if items[i].amount >= amount:
                items[i].amount -= amount
                if items[i].amount == 0:
                    items.remove_at(i)
                item_removed.emit(item, amount)
                return true
            else:
                amount -= items[i].amount
                item_removed.emit(item, items[i].amount)
                items.remove_at(i)
    
    return false
```

---

## Learning Path Recommendations

### Beginner Path
1. **Start with:** Gadget HQ's 2D Farming Game tutorial
2. **Then study:** Godot official demo projects
3. **Practice by:** Building small prototypes of each system
4. **Reference:** Pupi's Farm for more complex implementations

### Intermediate Path
1. **Begin with:** Godot 2D Top-Down Template (understand architecture)
2. **Study:** Croptails tutorial series (comprehensive approach)
3. **Implement:** Custom features using patterns from multiple sources
4. **Extend:** Add your own unique mechanics

### Advanced Path
1. **Analyze:** Multiple open-source projects for best patterns
2. **Architect:** Custom system design using learned patterns
3. **Optimize:** Performance and code quality
4. **Contribute:** Back to open-source projects

---

## How to Use These Resources

### For Learning
1. Clone the repository
2. Run the game to see it in action
3. Read through the code, starting with main scenes
4. Modify and experiment
5. Note patterns and techniques

### For Reference
1. Bookmark useful repositories
2. Keep code snippets of useful patterns
3. Reference during implementation
4. Adapt, don't copy directly

### For Inspiration
1. Play the games
2. Note what feels good
3. Identify unique features
4. Consider how to implement similarly

---

## Community Resources

### Forums and Discussion
- **Godot Forum:** [forum.godotengine.org](https://forum.godotengine.org/)
- **r/godot:** Reddit community
- **Godot Discord:** Real-time help and discussion

### Tutorial Websites
- **GDQuest:** Professional Godot tutorials
- **Brackeys (archived):** Game dev fundamentals
- **HeartBeast:** Godot-specific tutorials

### Asset Sources
- **OpenGameArt.org:** Free game assets
- **itch.io:** Free and paid asset packs
- **Kenney.nl:** Free game assets

---

## Contributing Back

### When You Learn
- Document your findings
- Share solutions to problems
- Create tutorials for others
- Contribute to open-source projects

### Best Practices
- Always credit original sources
- Follow license requirements
- Give back to the community
- Share your own work when possible

---

**Related Documentation:**
- `02_GodotResources.md` - Godot-specific learning
- `03_StardewValleyMechanics.md` - Game design reference
- `07_ImplementationGuide.md` - Step-by-step development
