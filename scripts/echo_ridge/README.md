# Echo Ridge Story Scripts

This folder contains scripts for the **Echo Ridge Inheritance** alternative starting story.

## Overview

The Echo Ridge story is an alternative/complementary narrative to the main Aethelgard Valley storyline, focusing on restoring a magical farm and reconnecting with Nature Spirits.

## Scripts

### SpiritOrb.gd
**Purpose:** Companion spirit that guides the player through farm restoration.

**Features:**
- 5 growth states (Dim → Soft → Bright → Radiant → Golden)
- State-specific dialogue
- Visual progression based on farm clearing percentage
- Integrates with EventBus for farm progress tracking

**Usage:**
```gdscript
# In Farm scene, add as child node
var spirit_orb = preload("res://scenes/echo_ridge/SpiritOrb.tscn").instantiate()
add_child(spirit_orb)
```

### EchoTree.gd
**Purpose:** The ancient tree at the center of Echo Ridge Farm.

**Features:**
- 6 growth stages (Dormant → Awakening → Budding → Blooming → Radiant → Sanctuary)
- Day-based progression (awakens on Day 21)
- Produces Echo Fruit at Sanctuary stage
- Interactive with player

**Usage:**
```gdscript
# Attach to StaticBody2D node for the tree
# Tree automatically progresses based on Calendar system
```

### EchoRidgeFarmManager.gd
**Purpose:** Manages overall farm state and story progression.

**Features:**
- Tracks debris clearing (100 total: sticks, stones, weeds, stumps)
- Monitors farm worth goal (1000g by Day 28)
- Triggers story events (Havenport visit on Day 14)
- Save/Load integration
- Emits farm clearing percentage to EventBus

**Usage:**
```gdscript
# Add as autoload or singleton
# Or attach to Farm root node
var farm_manager = EchoRidgeFarmManager.new()
```

## Integration with Existing Systems

### EventBus Signals
These scripts use new signals added to `EventBus.gd`:
- `spirit_orb_state_changed(new_state: int)`
- `echo_tree_awakened()`
- `echo_tree_stage_changed(stage: int)`
- `farm_cleared_percentage(percent: float)`
- `havenport_representative_visit()`
- `farm_worth_proven()`

### Calendar System
- EchoTree.gd connects to `Calendar.day_changed` signal
- EchoRidgeFarmManager.gd triggers events on specific days

### Save System
- EchoRidgeFarmManager.gd provides `get_save_data()` and `load_save_data()` methods
- Should be integrated into main SaveSystem.gd

## Story Timeline

| Day | Event | Script Trigger |
|-----|-------|----------------|
| 1 | Player arrives, meets Spirit Orb | Manual/Scene |
| 14 | Havenport Rep visits | EchoRidgeFarmManager |
| 21 | Echo Tree awakens | EchoTree |
| 28 | Prove farm worth (if 1000g earned) | EchoRidgeFarmManager |

## TODO: Implementation Steps

1. **Create Scenes:**
   - [ ] `scenes/echo_ridge/SpiritOrb.tscn`
   - [ ] `scenes/echo_ridge/EchoTree.tscn`
   - [ ] `scenes/farm/EchoRidgeFarm.tscn`

2. **Add Assets:**
   - [ ] Spirit Orb sprite (24x24, animated)
   - [ ] Echo Tree sprites (6 stages, 48x48)
   - [ ] Farm debris objects (sticks, stones, weeds, stumps)

3. **Integrate with Save System:**
   ```gdscript
   # In SaveSystem.gd save_game():
   if has_node("/root/EchoRidgeFarmManager"):
       save_data["echo_ridge"] = EchoRidgeFarmManager.get_save_data()
   ```

4. **Create Story Cutscenes:**
   - [ ] Day 1 intro (Spirit Orb greeting)
   - [ ] Day 14 Havenport Rep visit
   - [ ] Day 21 Echo Tree awakening
   - [ ] Day 28 farm worth proven

## Documentation Reference

See `docs/09_EchoRidgeInheritanceStory.md` for complete story details, asset requirements, and integration guidelines.
