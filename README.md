# FarmHouse Stories — Echoes of Aethelgard

A **2D top-down action-farming RPG** built with **Godot Engine 4.6**, merging **Link to the Past** puzzle-dungeons with **Stardew Valley** relationship mechanics. Set in **Aethelgard Valley**, players manage a farm, explore Zelda-style dungeons in the Echo Ridge mountains, tackle procedurally generated Mythic Rift dungeons for rare loot, and build relationships with 35 unique citizens of Hearthhaven.

## 🎮 Project Vision

Create an engaging action-farming RPG that combines:
- **Top-down 2D gameplay** with Zelda-like dungeon exploration and puzzle-solving
- **Cell-shaded graphics** for a unique artistic style
- **Deep farming mechanics** including crops, animals, and rift-touched seasons
- **Dual gear sets** — Farm Set for daily life, Dungeon Set for combat/spelunking
- **Link to the Past-style dungeons** with keys, puzzles, and boss battles
- **Mythic Rift dungeons** — procedurally generated challenges with Ethereal Token rewards
- **35 unique NPCs** with daily routines, rich backstories, and evolving questlines
- **Seasonal events** tied to US holidays with special creatures, drops, and activities
- **Resource management** through crafting and gathering

## 🚀 Getting Started

### Prerequisites

- **Godot Engine 4.6 beta1** or later ([Download here](https://godotengine.org/download))
- **Git** for version control
- Basic knowledge of GDScript (optional but helpful)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shifty81/FarmHouse-Stories.git
   cd FarmHouse-Stories
   ```

2. **Open in Godot 4.6:**
   - Launch Godot Engine
   - Click "Import" and navigate to the project folder
   - Select `project.godot` file

3. **Read the documentation:**
   - Start with `docs/01_ProjectOverview.md` for an introduction
   - Follow `docs/07_ImplementationGuide.md` for step-by-step development

## 📚 Documentation

Comprehensive documentation is available in the `docs/` folder:

### Core Documentation

1. **[Project Overview](docs/01_ProjectOverview.md)**  
   Introduction to the project, vision, and roadmap

2. **[Cell Shading Techniques](docs/02_CellShadingTechniques.md)**  
   How to implement toon/cell shading in Godot 4.6 for a unique visual style

3. **[Stardew Valley Mechanics](docs/03_StardewValleyMechanics.md)**  
   Analysis of Stardew Valley's game systems and mechanics for reference

4. **[Open Source Projects](docs/04_OpenSourceProjects.md)**  
   Catalog of similar open-source games and learning resources

5. **[Asset Organization](docs/05_AssetOrganization.md)**  
   Guidelines for organizing graphics, audio, and other game assets

6. **[Godot Resources](docs/06_GodotResources.md)**  
   Learning resources, tutorials, and best practices for Godot 4.6

7. **[Implementation Guide](docs/07_ImplementationGuide.md)**  
   Step-by-step guide to building the game from scratch

8. **[GFX Integration Guide](docs/08_GFXIntegrationGuide.md)**  
   Graphics asset integration and workflow

9. **[Echo Ridge Inheritance Story](docs/09_EchoRidgeInheritanceStory.md)**  
   Alternative starting story concept with detailed farm layout and asset guide

10. **[GDScript Style Guide](docs/10_GDScriptStyleGuide.md)**  
    Type annotation rules, naming conventions, and linting with gdlint

11. **[Godot Asset Library Guide](docs/11_GodotAssetLibraryGuide.md)**  
    How to accelerate development using Godot's built-in Asset Library — recommended addons for dungeons, dialogue, quests, audio, and UI

## 🎨 Art Style

The game uses **cell shading** (toon shading) to create a distinctive, cartoon-like aesthetic:
- Distinct color bands instead of smooth gradients
- Clean outlines for definition
- Vibrant, hand-crafted appearance
- Optimized for 2D top-down perspective

See `docs/02_CellShadingTechniques.md` for implementation details.

## 🌍 World: Aethelgard Valley

### The Hub City — Hearthhaven
A bustling, cozy town centered around a large Clock Tower, a market square, and the Gilded Hearth tavern. Home to 35 unique citizens with daily schedules, rich backstories, and evolving questlines.

### Echo Ridge Mountains
Ancient mountains containing **Link to the Past-style dungeons** with keys, puzzles, and bosses:
- **Echo Caverns** — Stone corridors echoing the past (Difficulty 1)
- **Whispering Depths** — Rift energy seeps through ancient walls (Difficulty 2)
- **Ancient Aqueducts** — Waterlogged tunnels with shifting currents (Difficulty 2)
- **Crystal Sanctum** — Cathedral of living crystals (Difficulty 3)
- **Ember Forge** — Volcanic dungeon with ancient forges (Difficulty 4)
- **Void Fortress** — Reality bends within these halls (Difficulty 5)

### The Mythic Rifts (Void Anchor)
Near the valley's edge lies the **Void Anchor**, where a mysterious cloaked vendor opens daily randomized **Mythic Rift** dungeons in exchange for **Chronos Shards**. These procedurally generated dungeons offer escalating tiers of difficulty (Minor to Abyssal) with better loot and **Ethereal Tokens** for gear upgrades.

### Whispering Wastes
The desolate border of the known world, home to Old Moss the hermit and strange phenomena.

## ⚔️ Dual Gear System

- **Farm Set** — Casual wear for daily farm life: stamina regen, movement speed, interaction bonuses, harvest quality
- **Dungeon Set** — Combat gear for exploration: defense, HP, trap resistance, elemental protection
- Gear automatically swaps when entering/exiting dungeons
- Dungeon gear upgradeable using **Ethereal Tokens** from Mythic Rift vendors (up to 5 upgrade levels)

## 🏰 Dungeon Mechanics

Dungeons feature **Link to the Past-style** gameplay:
- **Room types:** Combat, puzzle, treasure, key rooms, boss arenas
- **Puzzle types:** Block pushing, switch sequences, light reflection, pressure plates, torch lighting, crystal alignment, water flow, lever order
- **Key progression:** Small keys, big keys, boss keys, crystal keys
- **Boss encounters** with specific weaknesses and unique loot drops
- **Chronos Shard** drops that unlock Mythic Rift access

## 👥 Citizens of Hearthhaven (35 NPCs)

Each NPC has a unique backstory, daily schedule, favorite/disliked gifts, birthday, and multi-part questline:

| NPC | Role | Key Questline |
|-----|------|---------------|
| **Silas** | Blacksmith | Overcome trauma → unlock Legendary gear forging |
| **Elara** | Myth-Keeper/Librarian | Translate ancient texts → reveal Aethelgard's true history |
| **Barnaby** | Botanist | Overcome social anxiety → access rare rift-touched crops |
| **Mayor Thornwell** | Mayor | Uncover founding secrets and political intrigue |
| **Marlowe** | Tavern Owner | Rebuild the Gilded Hearth after a mysterious fire |
| **The Shrouded One** | Void Anchor Vendor | Mysterious Rift fragment — Mythic dungeon gateway |
| **Old Moss** | Hermit/Herbalist | Reveal he sealed the original Rift breach |
| **Theron** | Ranger/Guard Captain | Defend against threats from beyond Echo Ridge |
| ...and 27 more | Various | Deep personal stories woven into the world |

## 🎉 Seasonal Events (US Holidays)

Events are adapted to Aethelgard's fantasy world with special creatures, drops, and activities:

| Season | Event | US Holiday | Special Creatures |
|--------|-------|------------|-------------------|
| 🌸 Spring | **Spring Bloom Fair** | Easter | Petal-Pups, Bloom Bunnies |
| 🌸 Spring | **Blossom Hearts Festival** | Valentine's Day | Love Sprites |
| 🌸 Spring | **Emerald Fortune Day** | St. Patrick's Day | Gold Sprites |
| ☀️ Summer | **Sun-Singe Solstice** | Summer Solstice | Sun-Ray Fish, Sand Crab King |
| ☀️ Summer | **Freedom Fireworks** | Independence Day | Spark Beetles |
| 🍂 Fall | **Harvest Moon Hallow** | Halloween | Void-Bats, Shadow Cats |
| 🍂 Fall | **Great Harvest Feast** | Thanksgiving | Golden Turkeys |
| ❄️ Winter | **The Great Frost-Light** | Christmas | Frost Stags, Snow Sprites |
| ❄️ Winter | **New Dawn Festival** | New Year's | Chrono Butterflies |
| ❄️ Winter | **Unity Day** | MLK Day | — |


## 🌐 Multiplayer

FarmHouse Stories supports cooperative multiplayer for up to **4 players**:

1. **Host a Game:** One player creates a server on a chosen port (default 9999).
2. **Join a Game:** Other players connect using the host's IP address and port.
3. **Singleplayer:** Start a solo game directly from the lobby.

All players share the same farm world. Crop actions and time progression are synchronized across all connected clients.

## 🗂️ Project Structure

```
FarmHouse-Stories/
├── docs/               # Comprehensive documentation
├── gfx/               # Game assets (sprites, fonts)
├── scenes/            # Godot scene files
│   ├── ui/            # HUD, lobby, quest journal
│   ├── farm/          # Farm, crops
│   ├── dungeon/       # Dungeon room templates
│   └── player/        # Player character
├── scripts/           # GDScript game logic
│   ├── systems/       # EventBus, Calendar, Save, Network, Inventory, QuestManager, SoundManager, GameBalance
│   ├── farm/          # Crop management
│   ├── player/        # Player movement, tools
│   │   └── tools/     # Tool implementations (hoe, axe, pickaxe, etc.)
│   ├── npc/           # NPC database, data definitions, dialogue system
│   ├── gear/          # Dual gear set system
│   ├── dungeon/       # Dungeon and Mythic Rift systems, dungeon room base
│   │   ├── DungeonTilesetBuilder  # Cave tileset builder
│   │   └── DungeonRoomGenerator   # Procedural room layouts
│   ├── combat/        # Combat system and enemy definitions
│   ├── crafting/      # Crafting recipes and artisan goods
│   ├── fishing/       # Fishing system and fish registry
│   ├── mining/        # Mining system and ore extraction
│   └── events/        # Seasonal event system
├── shaders/           # Custom shaders (cell shading)
└── project.godot      # Godot project configuration
```

## 🛠️ Technology Stack

- **Engine:** Godot 4.6 (GDScript)
- **Graphics:** 2D pixel art with cell shading
- **Target Platforms:** Windows, Linux, macOS
- **Version Control:** Git & GitHub

## 📖 Learning Resources

### For Godot 4.6
- [Official Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDQuest Tutorials](https://www.gdquest.com/)
- See `docs/06_GodotResources.md` for comprehensive learning paths

### For Game Design
- [Stardew Valley Wiki](https://stardewvalleywiki.com/) - Mechanics reference
- See `docs/03_StardewValleyMechanics.md` for detailed analysis

### For Code Examples
- See `docs/04_OpenSourceProjects.md` for open-source farming games

## 🤝 Contributing

This is an open learning project! Contributions are welcome:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

Please read the documentation first to understand the project structure and conventions.

## 📋 Development Roadmap

### Phase 1: Foundation ✅
- [x] Project setup and structure
- [x] Research and documentation
- [x] Godot project file with input mapping and physics layers
- [x] Basic player controller with movement and interaction
- [x] Cell shader for toon-style rendering
- [x] Tilemap and level design

### Phase 2: Core Mechanics ✅
- [x] Farming system (planting, watering, harvesting)
- [x] Day/night cycle and calendar system
- [x] Basic HUD (time, date, money, energy)
- [x] Tool system base class
- [x] Save/load system (extended for all new systems)
- [x] Multiplayer support (host/join lobby, player spawning, position sync)
- [x] Inventory and item system
- [x] Tool-specific implementations (hoe, watering can, axe, pickaxe, scythe, fishing rod)

### Phase 3: World Systems ✅
- [x] NPC database with 35 citizens (backstories, schedules, questlines)
- [x] Dual gear set system (Farm Set / Dungeon Set)
- [x] Story dungeon system (6 Link to the Past-style dungeons)
- [x] Mythic Rift procedural dungeon system with tiered difficulty
- [x] Void Anchor vendor with Chronos Shard / Ethereal Token economy
- [x] Seasonal event system (16+ events tied to US holidays)
- [x] EventBus extended with NPC, gear, dungeon, rift, and event signals

### Phase 4: Advanced Features
- [x] Dungeon room/puzzle scene implementations
- [x] Combat system with enemy AI
- [x] NPC dialogue and cutscene system
- [x] Crafting and artisan goods
- [x] Fishing mechanics
- [x] Mining system

### Phase 5: Polish & Content ✅
- [x] Cell shader integration with all scenes
- [x] UI/UX improvements
- [x] Sound effects and music
- [x] Quest journal UI
- [x] Additional content and balancing

See `docs/01_ProjectOverview.md` for detailed roadmap.

## 🎯 Current Status

**Phase:** All phases complete  
**Latest:** Additional content and balancing pass — expanded item registry (100+ items), 20+ crafting recipes, 6 new ores/gems, 8 new fish species, full gear sets for all slots, 10 new enemies + 2 missing bosses, and centralized GameBalance system for XP/economy tuning  
**New:** See `docs/11_GodotAssetLibraryGuide.md` for recommended addons

## 📄 License

[To be determined - Consider MIT or similar open-source license]

## 🙏 Acknowledgments

- **Stardew Valley** by ConcernedApe - Inspiration and design reference
- **Godot Engine** - Amazing open-source game engine
- **Open Source Community** - Tutorials, assets, and code examples

## 📞 Contact & Community

- **GitHub Issues:** Report bugs or request features
- **Discussions:** Share ideas and ask questions
- **Godot Discord:** Join the Godot community for engine support

---

**Built with ❤️ using Godot Engine 4.6**

*Last Updated: March 2026*
