# FarmHouse Stories — Echoes of Aethelgard: Project Overview

## Introduction

FarmHouse Stories (subtitle: **Echoes of Aethelgard**) is a **2D top-down action-farming RPG** that merges Link to the Past puzzle-dungeons with Stardew Valley relationship mechanics. Set in **Aethelgard Valley**, the game features cell-shaded graphics, a dual gear system, procedurally generated Mythic Rift dungeons, and 35 unique NPCs with daily lives. Built with **Godot Engine 4.6** and GDScript.

## Vision

Create an engaging action-farming RPG that combines:
- **Top-down 2D gameplay** with smooth character movement
- **Cell-shaded graphics** for a unique, hand-crafted visual appeal
- **Deep farming mechanics** including crops, animals, and rift-touched seasonal changes
- **Link to the Past-style dungeons** with keys, puzzles, and boss encounters
- **Mythic Rift dungeons** — procedurally generated challenges for Ethereal Tokens
- **Dual gear sets** — Farm Set for daily life, Dungeon Set for combat/spelunking
- **35 unique NPCs** with daily schedules, deep backstories, and evolving questlines
- **Seasonal events** tied to US holidays with special creatures and drops
- **Adventure elements** with exploration, combat, and cave spelunking

## The World: Aethelgard Valley

### Setting
A vibrant, pastoral valley trapped between the **Echo Ridge** mountains (containing ancient dungeons) and the **Whispering Wastes**. The land is affected by **Rifts** — areas where the past and present merge, creating both danger and wonder.

### The Hub City — Hearthhaven
A bustling, cozy town centered around a large Clock Tower, a market square, and the Gilded Hearth tavern. Home to 35 citizens with unique daily routines and rich backstories.

### Echo Ridge Mountains
Home to six Link to the Past-style story dungeons of escalating difficulty, each requiring specific items to access. Dungeons feature room-by-room exploration with keys, puzzles, treasure, and boss encounters.

### The Void Anchor (Mythic Rifts)
Near the valley's edge, a mysterious cloaked figure known as **The Shrouded One** opens daily randomized Mythic Rift dungeons in exchange for Chronos Shards. Five tiers of difficulty (Minor to Abyssal) yield Ethereal Tokens for gear upgrades.

### Whispering Wastes
The desolate border of the known world, home to Old Moss the hermit and unexplored phenomena beyond.

## Gear & Gameplay Mechanics

### Farm Set (Daily Wear)
Casual clothes providing fast movement, stamina regeneration, and improved interaction with townsfolk. Includes farmer's shirt, work overalls, and muddy boots.

### Dungeon Set (Combat/Spelunking)
Heavy armor, magical capes, and specialized gear (like magnetic boots) upgradeable using Ethereal Tokens from Mythic Dungeons. Provides defense, HP bonuses, trap resistance, and elemental protection.

### Gear Switching
Sets automatically swap when entering/exiting dungeons. Dungeon gear has 5 upgrade tiers, each boosting stats by 15%.

### Farming
Crops are influenced by the Rifts, requiring unique care depending on if the season is "Stable" or "Rift-Touched." Rift-touched crops yield rare materials for crafting.

## Citizen Storylines & Daily Life (35 NPCs)

Each NPC has a unique, evolving story that progresses based on friendship levels (0-10 hearts, 250 points per level) and completed quests. Key NPCs include:

- **Silas, The Former Spelunker** — The town's moody blacksmith who refused to return to dungeons after tragedy. His storyline involves overcoming trauma and forging Legendary-tier gear.
- **Elara, The Myth-Keeper** — Operates the library and tracks Aethelgard's lore. Her story involves translating ancient texts to unlock the true history of the valley.
- **Barnaby, The Timid Farmer** — A shy botanist specializing in rare cross-pollination. Helping him overcome social anxiety leads to the best produce and rift-touched crop varieties.
- **The Shrouded One** — The mysterious Void Anchor vendor who accepts Chronos Shards and rare items for Mythic Rift access and Ethereal Token gear upgrades.
- **Old Moss** — An elderly hermit who was once a powerful rift-walker. His storyline reveals he sealed the original Rift breach.

## Events & Seasonal Creatures

Events are based on US holidays, adapted to the fantasy world of Aethelgard:

- **Spring (Spring Bloom Fair)** — A festival of lights with Petal-Pups and specialized planting seeds.
- **Summer (The Sun-Singe Solstice)** — Beach party with fishing competitions; Sun-Touched Fish for fire-resistant potions.
- **Fall (Harvest Moon Hallow)** — Costumes and masks; a Spooky Rift for dark-themed furniture and Void-Bat pets.
- **Winter (The Great Frost-Light)** — Gift-giving boosts relationships; Frost Stags drop Ice Shards for winter gear.

Plus events for Valentine's Day, St. Patrick's Day, Independence Day, Thanksgiving, New Year's, MLK Day, and more — 16+ events total.

## Target Platform

- **Primary Engine**: Godot v4.6-beta1 (Windows 64-bit)
- **Target Platforms**: PC (Windows, Linux, Mac)
- **Game Type**: Single-player 2D top-down simulation RPG

## Core Game Pillars

### 1. Farming
- Crop cultivation with seasonal varieties and rift-touched variants
- Animal husbandry and care
- Farm expansion and customization
- Automated systems (sprinklers, feeders)

### 2. Dungeon Exploration
- Six story dungeons with Link to the Past-style puzzles, keys, and bosses
- Mythic Rift procedurally generated dungeons for endgame challenge
- Dual gear system: Farm Set and Dungeon Set
- Ethereal Token economy for gear upgrades via the Void Anchor vendor

### 3. Crafting & Economy
- Resource gathering and processing
- Artisan goods production
- Trading and selling mechanics
- Economic progression system
- Chronos Shard and Ethereal Token exchange

### 4. Social Interaction
- 35 NPC relationships with friendship levels (0-10 hearts)
- Daily schedules and location-based encounters
- Community events tied to US holidays (16+ events)
- Marriage and family systems
- Quest and dialogue systems with multi-part questlines

### 5. Progression
- Tool and equipment upgrades
- Skill leveling systems
- Dungeon gear upgrade tiers (5 levels)
- Achievement tracking
- Multiple farm layouts to choose from

## Art Direction

### Visual Style
- **Cell Shading**: Cartoon-like rendering with distinct color bands
- **Tile-based world**: Modular, expandable game environment
- **Sprite-based characters**: Animated 2D characters with multiple states
- **Color palette**: Vibrant, seasonal color schemes

### Influences
- Stardew Valley's pixel art aesthetic
- Legend of Zelda's top-down perspective
- Modern indie game visual styles

## Technical Architecture

### Engine Choice: Godot 4.6
Benefits for this project:
- Open source and free
- Excellent 2D capabilities
- Built-in physics and collision
- Powerful shader system for cell shading
- Cross-platform export
- Active community and resources

### Development Approach
1. Modular scene design
2. Resource-based data management
3. Signal-driven event system
4. Component-based architecture

## Project Structure

```
FarmHouse-Stories/
├── docs/               # Documentation (this folder)
├── gfx/               # Game assets (sprites, fonts)
├── scripts/           # GDScript game logic
│   ├── systems/       # EventBus, Calendar, Save, Network
│   ├── farm/          # Crop management
│   ├── player/        # Player movement, tools
│   ├── npc/           # NPC database and data definitions
│   ├── gear/          # Dual gear set system
│   ├── dungeon/       # Dungeon and Mythic Rift systems
│   └── events/        # Seasonal event system
├── scenes/            # Godot scene files
├── shaders/           # Custom shaders (cell shading)
└── project.godot      # Godot project configuration
```

## Development Roadmap

### Phase 1: Foundation (Complete)
- [x] Project setup and structure
- [x] Research and documentation
- [x] Basic player controller
- [x] Cell shader implementation
- [ ] Tilemap and level design

### Phase 2: Core Mechanics (Complete)
- [x] Farming system (planting, watering, harvesting)
- [x] Day/night cycle and calendar
- [x] Save/load system (extended for all new systems)
- [x] Tool system base
- [ ] Inventory and item system
- [ ] Tool-specific implementations

### Phase 3: World Systems (Complete)
- [x] NPC database (35 citizens with backstories, schedules, questlines)
- [x] Dual gear set system (Farm Set / Dungeon Set)
- [x] Story dungeon system (6 dungeons with puzzles, keys, bosses)
- [x] Mythic Rift procedural dungeon system (5 tiers)
- [x] Void Anchor vendor with Chronos Shard / Ethereal Token economy
- [x] Seasonal event system (16+ events tied to US holidays)
- [x] EventBus extended with NPC, gear, dungeon, rift, and event signals
- [x] SaveSystem extended to persist all new system data

### Phase 4: Advanced Features
- [ ] Dungeon room/puzzle scene implementations
- [ ] Combat system with enemy AI
- [ ] NPC dialogue and cutscene system
- [ ] Crafting and artisan goods
- [ ] Fishing mechanics
- [ ] Mining system

### Phase 5: Content & Polish
- [ ] Additional crops and recipes
- [ ] More NPCs and quests
- [ ] Sound effects and music
- [ ] Testing and balancing

## Key Resources

### Official Documentation
- [Godot 4.6 Documentation](https://docs.godotengine.org/en/stable/)
- [Stardew Valley Wiki](https://stardewvalleywiki.com/)

### Learning Resources
- See `02_GodotResources.md` for Godot-specific guides
- See `03_StardewValleyMechanics.md` for game design reference
- See `04_OpenSourceProjects.md` for code examples

### Community
- Godot Discord and Forums
- Reddit: r/godot, r/StardewValley
- GitHub open-source projects

## Contributing

This project is open for contributions. Please refer to the documentation in the `docs/` folder for technical details and implementation guidelines.

## License

[To be determined - Consider MIT or similar open-source license]

---

**Next Steps**: Review the detailed documentation files to understand specific implementation approaches for each game system.
