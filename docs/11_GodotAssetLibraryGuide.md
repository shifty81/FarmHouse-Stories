# Godot Asset Library Guide — Accelerating FarmHouse Stories

## Overview

Godot Engine's **built-in Asset Library** (AssetLib) is a free marketplace of community-created addons, plugins, templates, and assets accessible directly from within the Godot editor. This guide maps specific Asset Library addons to the remaining features on our roadmap, providing the fastest path to a playable game.

## How to Use the Asset Library

### Accessing the Asset Library

1. Open your project in **Godot 4.6**
2. Click the **AssetLib** tab at the top center of the editor (next to 2D, 3D, Script)
3. Browse, search, or filter by category, engine version, and support level

### Installing an Addon

1. **Search** for the addon by name in the AssetLib search bar
2. **Click** the addon to review its description, license, and compatibility
3. Click **Download** and wait for it to finish
4. Click **Install** in the dialog that appears
5. Ensure "Ignore asset root" is **unchecked** so files go to `res://addons/`
6. Go to **Project → Project Settings → Plugins** tab
7. Find the new plugin and **check "Enable"**
8. Most plugins work immediately; restart the editor if prompted

### Manual Installation (GitHub)

Some addons are not on the built-in AssetLib but are available on GitHub:

1. Download or clone the addon repository
2. Copy the addon folder into your project's `res://addons/` directory
3. Enable via **Project → Project Settings → Plugins**

> **Tip:** Always check that the addon supports **Godot 4.x** before installing.

---

## Recommended Addons by Feature

### 🗺️ Dungeon Room & Puzzle Scenes (Phase 4)

Our project needs dungeon room implementations with puzzles, keys, and boss arenas. These addons can accelerate development:

#### 1. Phantom Camera (2D/3D Camera System)

- **What it does:** Cinematic camera control with smooth follow, room transitions, look-ahead, zoom, screen shake, and priority-based camera switching
- **Why we need it:** Essential for room-by-room dungeon exploration (Link to the Past style), camera locking to rooms, boss arena zoom-ins, and cutscene cameras
- **Where to get it:** AssetLib search "Phantom Camera" or [GitHub](https://github.com/ramokz/phantom-camera)
- **License:** MIT
- **How to integrate:**
  ```
  1. Install from AssetLib → Enable in Project Settings
  2. Add PhantomCamera2D node to your dungeon scenes
  3. Create camera zones for each dungeon room
  4. Use priority system to switch between room cameras
  5. Add screen shake for boss hits and puzzle completions
  ```

#### 2. LimboAI (Behavior Trees + State Machines)

- **What it does:** Behavior trees and hierarchical state machines for complex AI logic
- **Why we need it:** Boss enemy AI patterns, NPC daily schedules driven by behavior trees, puzzle element state tracking (switches, doors, pressure plates)
- **Where to get it:** AssetLib search "LimboAI" or [GitHub](https://github.com/limbonaut/limboai)
- **License:** MIT
- **How to integrate:**
  ```
  1. Install from AssetLib → Enable in Project Settings
  2. Create BehaviorTree resources for each boss type
  3. Define states: patrol, chase, attack, special_attack, stunned
  4. Wire up the tree to your CombatSystem enemy nodes
  5. Reuse behavior trees across similar enemy types
  ```

#### 3. DTL (Dungeon Template Library)

- **What it does:** Procedural 2D map generation using various algorithms (BSP, maze, cellular automata, Perlin noise)
- **Why we need it:** Powers our Mythic Rift procedural dungeon system with proper room layouts and corridor connections
- **Where to get it:** [GitHub](https://github.com/krazyjakee/godot-dtl) (GDExtension)
- **License:** Open Source
- **How to integrate:**
  ```
  1. Download and place in addons/ folder
  2. Use DTL to generate room layouts as 2D arrays
  3. Feed the output into TileMap for visual rendering
  4. Connect rooms with corridor generation
  5. Place enemies, treasure, and puzzles based on room type
  ```

---

### 💬 Dialogue & Quest System (Phase 4-5)

#### 4. Dialogic 2 (Visual Dialogue Editor)

- **What it does:** Full-featured visual dialogue editor with branching conversations, character portraits, variables, conditions, localization, save/load, and timeline-based cutscenes
- **Why we need it:** Our 35 NPCs need rich dialogue trees, quest triggers, friendship-gated conversations, and seasonal dialogue variants
- **Where to get it:** AssetLib search "Dialogic" or [GitHub](https://github.com/dialogic-godot/dialogic)
- **License:** MIT
- **How to integrate:**
  ```
  1. Install from AssetLib → Enable in Project Settings
  2. Open the Dialogic editor (new tab appears in the editor)
  3. Create Character resources for each of our 35 NPCs
  4. Build dialogue timelines with branching based on:
     - Friendship level (EventBus heart points)
     - Current season/day (CalendarSystem)
     - Quest progress (quest flags)
  5. Connect to our DialogueSystem.gd via signals
  6. Use Dialogic's built-in save/load to persist dialogue state
  ```
- **Integration with existing code:**
  ```gdscript
  # In DialogueSystem.gd, connect Dialogic to our EventBus
  func start_npc_dialogue(npc_id: String) -> void:
      var npc_data: Dictionary = NPCDatabase.get_npc(npc_id)
      # Set Dialogic variables from our game state
      Dialogic.VAR.set_variable("friendship", npc_data.friendship_points)
      Dialogic.VAR.set_variable("season", CalendarSystem.current_season)
      Dialogic.VAR.set_variable("day", CalendarSystem.current_day)
      # Start the dialogue timeline
      Dialogic.start("npc_" + npc_id)
  ```

#### 5. Quest Manager Addon

- **What it does:** Quest tracking with objectives (collect, talk, visit, defeat), quest journal UI, quest states (available, active, completed, failed)
- **Why we need it:** Quest journal UI is a Phase 5 priority; our 35 NPCs each have multi-part questlines that need tracking
- **Where to get it:** AssetLib search "Quest" or community GitHub repositories
- **License:** Varies (typically MIT)
- **How to integrate:**
  ```
  1. Install quest system addon
  2. Define quest resources for each NPC questline
  3. Connect quest triggers to Dialogic dialogue events
  4. Wire quest completion to EventBus signals
  5. Build quest journal UI using the addon's built-in components
  ```

---

### 🎵 Sound Effects & Music (Phase 5)

#### 6. Sound Manager

- **What it does:** Global audio management with music crossfading, SFX pooling, volume bus control, and cross-scene audio persistence
- **Why we need it:** Background music for farm/dungeon/town, tool sound effects, ambient sounds, UI feedback sounds, seasonal music variants
- **Where to get it:** AssetLib search "Sound Manager"
- **License:** MIT
- **How to integrate:**
  ```
  1. Install from AssetLib → Enable in Project Settings
  2. Configure audio buses: Music, SFX, Ambient, UI
  3. Add music tracks for each area:
     - Farm (calm, pastoral)
     - Town/Hearthhaven (cheerful, bustling)
     - Dungeon (tense, mysterious)
     - Boss fights (intense, dramatic)
     - Seasonal variants
  4. Connect to EventBus signals for automatic music switching:
     - dungeon_entered → switch to dungeon music
     - dungeon_exited → switch to farm music
     - boss_encountered → switch to boss music
  5. Add SFX for tools, crops, UI interactions
  ```
- **Free music/SFX sources to pair with this:**
  - [OpenGameArt.org](https://opengameart.org/) — Free game audio (CC licenses)
  - [Freesound.org](https://freesound.org/) — Sound effects library
  - [Kenney.nl](https://kenney.nl/) — Free game assets including audio

---

### 🎨 UI/UX Improvements (Phase 5)

#### 7. Godot Theme Editor / UI Toolkit

- **What it does:** Pre-built, polished UI themes with buttons, panels, progress bars, tabs, and scroll containers designed for Godot 4's theme system
- **Why we need it:** Professional-looking inventory screens, quest journal, settings menus, and HUD elements
- **Where to get it:** AssetLib search "Theme" or "UI"
- **How to integrate:**
  ```
  1. Install a UI theme pack from AssetLib
  2. Apply the theme to our root Control nodes
  3. Customize colors to match our cell-shaded art style
  4. Use themed components for:
     - Inventory grid (InventoryUI.tscn)
     - Quest journal panels
     - Settings/pause menu
     - Dialogue boxes
     - Shop interface
  ```

#### 8. Inventory System (by expressobits)

- **What it does:** Complete inventory system with slots, drag-and-drop, crafting grid, hotbar, and clean separation between data and UI
- **Why we need it:** While we have an InventorySystem.gd, this addon provides polished UI components for the visual inventory, crafting table, and shop interfaces
- **Where to get it:** AssetLib search "Inventory" or [GitHub](https://github.com/expressobits/inventory-system)
- **License:** MIT
- **How to integrate:**
  ```
  1. Install and review the addon's architecture
  2. Adapt our InventorySystem.gd to use the addon's data layer
     (or keep our data layer and use only the UI components)
  3. Connect to EventBus inventory signals
  4. Style the UI to match our cell-shaded theme
  ```

---

### ✨ Visual Polish & Effects (Phase 5)

#### 9. Godot Particles Pack / Trail2D

- **What it does:** Pre-made particle effects (sparkles, dust, fire, water splash, magic) and trail rendering for moving objects
- **Why we need it:** Tool usage effects (dirt flying when hoeing), crop growth sparkles, dungeon torches, magic effects, boss attack VFX, seasonal weather (rain, snow, falling leaves)
- **Where to get it:** AssetLib search "Particles" or "Trail"
- **How to integrate:**
  ```
  1. Browse particle effect addons in AssetLib
  2. Import particle scenes for each effect type
  3. Attach to game events:
     - Tool use → dirt/water/chop particles
     - Crop harvest → sparkle burst
     - Dungeon torches → fire particles
     - Boss attacks → magic VFX
     - Weather → rain/snow/leaf particles tied to CalendarSystem
  ```

#### 10. Godot Screen Transitions

- **What it does:** Smooth scene transitions (fade, wipe, dissolve, pixelate) between game areas
- **Why we need it:** Transitions between Farm ↔ Town ↔ Dungeon, day-end sleep transition, dungeon room transitions
- **Where to get it:** AssetLib search "Transition" or "Scene Transition"
- **How to integrate:**
  ```
  1. Install transition addon
  2. Add transition layer to scene tree
  3. Trigger transitions on area changes:
     - Farm → Town: gentle fade
     - Enter dungeon: dramatic wipe
     - Room to room: quick cut or slide
     - Day end: slow fade to black
  ```

---

### 🧪 Development & Testing Tools

#### 11. GUT (Godot Unit Testing)

- **What it does:** Full unit testing framework for GDScript with assertions, test suites, mocking, and a test runner GUI
- **Why we need it:** Test our game systems (CropManager, CalendarSystem, CombatSystem, etc.) without running the full game
- **Where to get it:** AssetLib search "GUT" or [GitHub](https://github.com/bitwes/Gut)
- **License:** MIT
- **How to integrate:**
  ```
  1. Install from AssetLib → Enable in Project Settings
  2. Create test/ directory with test scripts
  3. Write tests for critical systems:
     - test_crop_growth.gd (planting, watering, harvesting)
     - test_calendar.gd (day/season progression)
     - test_inventory.gd (add, remove, stack items)
     - test_combat.gd (damage calculation, enemy AI)
  4. Run tests from the GUT panel in the editor
  ```

#### 12. Godot Debug Console

- **What it does:** In-game developer console for running commands, spawning items, teleporting, changing time, and debugging
- **Why we need it:** Rapid testing of game systems without navigating to specific areas or waiting for time to pass
- **Where to get it:** AssetLib search "Console" or "Debug"
- **How to integrate:**
  ```
  1. Install and add console to the scene tree
  2. Register cheat commands:
     - set_time <hour> → CalendarSystem.current_hour = hour
     - set_season <name> → CalendarSystem.advance_season()
     - give_item <name> <count> → InventorySystem.add_item()
     - set_money <amount> → EventBus.player_money = amount
     - teleport <x> <y> → Player.position = Vector2(x, y)
     - spawn_enemy <type> → CombatSystem.spawn()
  ```

---

## Implementation Priority Order

Based on the current project state and maximum impact-to-effort ratio, here is the recommended order for integrating Asset Library addons:

### 🟢 Quick Wins (1-2 hours each)

| Priority | Addon | Impact | Why First |
|----------|-------|--------|-----------|
| 1 | **Phantom Camera** | High | Immediate visual polish; room-based cameras for dungeons |
| 2 | **Sound Manager** | High | Audio transforms the "feel" of the game instantly |
| 3 | **Screen Transitions** | Medium | Smooth area changes make the game feel complete |
| 4 | **GUT Testing** | Medium | Catch bugs early as we add more systems |

### 🟡 Core Features (Half-day each)

| Priority | Addon | Impact | Why Next |
|----------|-------|--------|----------|
| 5 | **Dialogic 2** | Very High | Unlocks all NPC dialogue content; visual editor saves weeks |
| 6 | **LimboAI** | High | Boss AI, NPC schedules, puzzle state machines |
| 7 | **Quest Manager** | High | Quest journal UI + tracking for 35 NPC questlines |

### 🔴 Enhancement Layer (1+ day each)

| Priority | Addon | Impact | Why Later |
|----------|-------|--------|-----------|
| 8 | **UI Theme Pack** | Medium | Polish inventory, menus, and HUD visually |
| 9 | **Inventory UI** | Medium | Upgrade inventory visuals with drag-and-drop |
| 10 | **Particle Effects** | Medium | Visual juice for tools, crops, combat, weather |
| 11 | **DTL Dungeon Gen** | Medium | Enhance Mythic Rift procedural generation |
| 12 | **Debug Console** | Low | Developer convenience (not player-facing) |

---

## Integration with Existing Systems

### Connecting Addons to EventBus

All addons should communicate through our existing `EventBus` autoload to maintain clean architecture:

```gdscript
# Example: Connecting Dialogic to EventBus
# In a DialogicBridge.gd autoload script:
extends Node

func _ready() -> void:
    # Listen for Dialogic events
    Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
    match argument:
        "quest_started":
            EventBus.quest_started.emit()
        "friendship_up":
            EventBus.npc_friendship_changed.emit()
        "give_item":
            EventBus.item_received.emit()
```

### Connecting Addons to SaveSystem

Ensure addon state is included in our save/load flow:

```gdscript
# In SaveSystem.gd, extend save_game():
func save_game() -> bool:
    var save_data: Dictionary = {
        # ... existing save data ...
        "dialogic_state": Dialogic.Save.get_save_data(),
        "quest_state": QuestManager.get_save_data(),
        "audio_state": {
            "music_volume": SoundManager.get_music_volume(),
            "sfx_volume": SoundManager.get_sfx_volume(),
        }
    }
    # ... save to file ...
    return true
```

### Connecting to CalendarSystem

Seasonal addons should respond to calendar changes:

```gdscript
# Connect seasonal music/visuals to calendar
func _ready() -> void:
    EventBus.day_started.connect(_on_day_started)

func _on_day_started(day: int, season: String) -> void:
    # Update music based on season
    SoundManager.play_music("res://audio/music/" + season.to_lower() + "_theme.ogg")
    # Update particle weather
    match season:
        "Spring":
            weather_particles.texture = petal_texture
        "Summer":
            weather_particles.emitting = false
        "Fall":
            weather_particles.texture = leaf_texture
        "Winter":
            weather_particles.texture = snow_texture
```

---

## Free Asset Sources for Audio & Graphics

### Music (for Sound Manager)

| Source | License | Best For |
|--------|---------|----------|
| [OpenGameArt.org](https://opengameart.org/) | CC-BY / CC0 | RPG town, farm, dungeon themes |
| [Kenney.nl](https://kenney.nl/) | CC0 | UI sounds, simple SFX |
| [Freesound.org](https://freesound.org/) | CC-BY / CC0 | Nature ambience, tool sounds |
| [itch.io Free Music](https://itch.io/game-assets/free/tag-music) | Varies | Complete soundtrack packs |

### Sound Effects

| Effect Needed | Search Terms | Source |
|---------------|-------------|--------|
| Tool sounds | "dig", "water splash", "chop", "mine" | Freesound, OpenGameArt |
| Farm ambience | "birds", "wind", "crickets" | Freesound |
| Dungeon ambience | "cave drip", "torch crackle", "wind howl" | Freesound, OpenGameArt |
| UI feedback | "click", "menu select", "inventory" | Kenney |
| Combat | "sword swing", "hit", "magic cast" | OpenGameArt |

---

## Quick-Start: Your First Addon Integration

### Example: Installing Phantom Camera in 5 Minutes

1. **Open Godot 4.6** and load FarmHouse Stories
2. Click **AssetLib** tab
3. Search **"Phantom Camera"**
4. Click → **Download** → **Install**
5. Go to **Project → Project Settings → Plugins** → Enable **Phantom Camera**
6. Open `scenes/farm/Farm.tscn`
7. Add a **PhantomCamera2D** node as a child of the scene
8. Configure:
   - Follow Target: Player node
   - Follow Mode: Glued (for overworld) or Framed (for dungeons)
   - Tween Duration: 0.5s for smooth transitions
9. For dungeon rooms, add one PhantomCamera2D per room with higher priority
10. **Run the scene** — the camera now smoothly follows the player!

### Example: Adding Dialogic in 10 Minutes

1. Click **AssetLib** → Search **"Dialogic"** → Download → Install → Enable
2. A new **Dialogic** tab appears in the editor toolbar
3. Click it and create a **New Character** → name it after an NPC (e.g., "Silas")
4. Set the character's portrait image from `gfx/NPC_test.png`
5. Create a **New Timeline** → "silas_greeting"
6. Add dialogue nodes:
   - Silas: "Welcome to my forge. Need something repaired?"
   - Choice: "Yes, please" / "Just browsing"
   - Branch based on choice
7. In your game code:
   ```gdscript
   # When player interacts with Silas NPC
   func _on_interaction_with_silas() -> void:
       Dialogic.start("silas_greeting")
   ```
8. **Run the scene** — dialogue plays with portrait and choices!

---

## Addon Compatibility Notes

| Addon | Godot 4.6 | GDScript | Notes |
|-------|-----------|----------|-------|
| Phantom Camera | ✅ | ✅ | Actively maintained |
| Dialogic 2 | ✅ | ✅ | Large community, frequent updates |
| LimboAI | ✅ | ✅ | Also supports C++ extensions |
| GUT | ✅ | ✅ | Standard testing framework |
| Sound Manager | ✅ | ✅ | Check for 4.6 compatibility on install |
| Inventory System | ✅ | ✅ | May need adaptation for our data model |

> **Always check the addon's page for the latest Godot version compatibility before installing.**

---

## Next Steps After Addon Integration

Once you have addons installed and configured, the next development steps are:

1. **Build dungeon room scenes** using Phantom Camera for room transitions and LimboAI for boss AI
2. **Create dialogue content** for all 35 NPCs using Dialogic's visual editor
3. **Design quest trees** connecting dialogue triggers to quest objectives
4. **Add audio** using Sound Manager with free assets from OpenGameArt/Kenney
5. **Polish UI** with themed components for inventory, quest journal, and menus
6. **Add particle effects** for tool use, crop growth, weather, and combat
7. **Write unit tests** with GUT for all core systems
8. **Playtest and balance** combat difficulty, crop prices, and progression pacing

---

**Related Documentation:**
- `04_OpenSourceProjects.md` — Open source projects and code patterns
- `06_GodotResources.md` — Godot learning resources and best practices
- `07_ImplementationGuide.md` — Step-by-step implementation phases
- `08_GFXIntegrationGuide.md` — Graphics asset integration workflow
