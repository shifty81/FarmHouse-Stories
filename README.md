# FarmHouse Stories

A **2D top-down farming simulation game** inspired by Stardew Valley, built with **Godot Engine 4.6**. Features cell-shaded graphics, comprehensive farming mechanics, and engaging gameplay combining agriculture, crafting, fishing, mining, and social simulation.

## 🎮 Project Vision

Create a charming and relaxing farming game that combines:
- **Top-down 2D gameplay** with Zelda-like exploration
- **Cell-shaded graphics** for a unique artistic style
- **Deep farming mechanics** including crops, animals, and seasons
- **Resource management** through crafting and gathering
- **Social simulation** with NPCs and relationships
- **Adventure elements** with mining and light combat

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

## 🎨 Art Style

The game uses **cell shading** (toon shading) to create a distinctive, cartoon-like aesthetic:
- Distinct color bands instead of smooth gradients
- Clean outlines for definition
- Vibrant, hand-crafted appearance
- Optimized for 2D top-down perspective

See `docs/02_CellShadingTechniques.md` for implementation details.

## 🌾 Core Features (Planned)

### Farming System
- **Crop Cultivation:** Plant, water, and harvest seasonal crops
- **Animal Husbandry:** Raise chickens, cows, and other farm animals
- **Farm Expansion:** Upgrade and customize your farm layout
- **Seasonal Gameplay:** Four seasons with unique crops and events

### Resource Management
- **Crafting System:** Create tools, equipment, and artisan goods
- **Mining:** Explore mines for ores, gems, and resources
- **Fishing:** Catch fish in various locations and seasons
- **Foraging:** Gather wild items throughout the world

### Social & Progression
- **NPC Relationships:** Befriend villagers and build relationships
- **Community Events:** Participate in seasonal festivals
- **Skill System:** Level up farming, mining, fishing, foraging, and combat
- **Economy:** Manage money through selling goods and purchasing upgrades

### Technical Features
- **Time System:** Dynamic day/night cycle and calendar
- **Save/Load:** Persistent game progress
- **Inventory Management:** Organize and manage items
- **Tool Upgrades:** Improve efficiency with better equipment
- **Multiplayer:** Host or join cooperative farming sessions (up to 4 players via ENet)

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
├── assets/            # Game assets (graphics, audio, fonts)
├── scenes/            # Godot scene files
├── scripts/           # GDScript game logic
├── shaders/           # Custom shaders (cell shading)
├── resources/         # Game data (crops, items, recipes)
└── addons/            # Third-party plugins and extensions
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
- [ ] Tilemap and level design

### Phase 2: Core Mechanics (In Progress)
- [x] Farming system (planting, watering, harvesting)
- [x] Day/night cycle and calendar system
- [x] Basic HUD (time, date, money, energy)
- [x] Tool system base class
- [x] Save/load system
- [x] Multiplayer support (host/join lobby, player spawning, position sync)
- [ ] Inventory and item system
- [ ] Tool-specific implementations (hoe, watering can, axe, pickaxe)

### Phase 3: Advanced Features
- [ ] Crafting and artisan goods
- [ ] Mining and combat system
- [ ] Fishing mechanics
- [ ] NPC and dialogue system

### Phase 4: Polish & Content
- [ ] Cell shader implementation
- [ ] UI/UX improvements
- [ ] Sound effects and music
- [ ] Additional content and balancing

See `docs/01_ProjectOverview.md` for detailed roadmap.

## 🎯 Current Status

**Phase:** Core Systems Implemented  
**Next Steps:** Add tilemap/level design, implement inventory system, and create tool-specific scripts

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

*Last Updated: February 2026*
