# Stardew Valley Game Mechanics Analysis

## Overview

This document analyzes the core game mechanics of Stardew Valley to serve as a design reference for FarmHouse Stories. Understanding these systems helps us identify what makes the game engaging and how to implement similar mechanics in Godot.

## Core Game Loop

### Daily Cycle
```
Morning (6:00 AM)
    ↓
Player Activities (Farming, Mining, Fishing, Social)
    ↓
Evening Tasks (Animal care, Crop processing)
    ↓
Night (2:00 AM - Forced Sleep)
    ↓
New Day (Stats refresh, Progress updates)
```

## 1. Farming System

### Crop Management

**Core Mechanics:**
- **Planting**: Till soil → Plant seeds → Water daily
- **Growth Cycles**: Different crops take 4-28 days to mature
- **Seasons**: Spring, Summer, Fall, Winter (28 days each)
- **Crop Types**:
  - Single harvest crops (e.g., parsnips, cauliflower)
  - Multi-harvest crops (e.g., strawberries, corn)
  - Giant crops (rare, 3x3 formations)

**Technical Implementation Ideas:**
```gdscript
# Crop data structure
class_name Crop extends Resource

@export var crop_name: String
@export var growth_time: int  # Days to mature
@export var seasons: Array[String]  # Valid seasons
@export var regrows: bool  # Multi-harvest?
@export var regrow_time: int  # Days between harvests
@export var sell_price: int
@export var seed_price: int
@export var growth_stages: Array[Texture2D]  # Sprite for each stage
```

### Soil Quality

**Mechanics:**
- **Fertilizers**: Speed growth, improve quality, retain moisture
- **Watering**: Required daily (unless raining)
- **Tilling**: Soil must be tilled before planting
- **Quality Levels**: Normal, Silver, Gold, Iridium (affects sell price)

**Quality Calculation:**
```gdscript
func calculate_crop_quality(farming_skill: int, used_fertilizer: bool) -> int:
    var base_chance = farming_skill / 10.0
    if used_fertilizer:
        base_chance *= 1.5
    
    var roll = randf()
    if roll < base_chance * 0.02:
        return 4  # Iridium
    elif roll < base_chance * 0.05:
        return 3  # Gold
    elif roll < base_chance * 0.1:
        return 2  # Silver
    else:
        return 1  # Normal
```

### Animals

**Types:**
- Chickens → Eggs (daily)
- Cows → Milk (daily)
- Goats → Goat Milk (every 2 days)
- Sheep → Wool (every 3 days)
- Pigs → Truffles (find outdoors)

**Animal Care:**
- Daily petting (increases mood/friendship)
- Feeding (hay or grass)
- Regular collection of products
- Health management

**Implementation Structure:**
```gdscript
class_name Animal extends Node2D

@export var animal_type: String
@export var mood: float = 100.0  # 0-100
@export var friendship: int = 0  # 0-1000
@export var has_been_fed: bool = false
@export var has_been_petted: bool = false
@export var produce_ready: bool = false
@export var days_until_produce: int = 1

func process_day():
    if has_been_fed and has_been_petted:
        mood = min(100.0, mood + 10)
        friendship = min(1000, friendship + 15)
    else:
        mood = max(0, mood - 20)
    
    if days_until_produce > 0:
        days_until_produce -= 1
    else:
        produce_ready = true
```

## 2. Resource Gathering

### Mining

**Structure:**
- 120 floors in main mines
- Every 5 floors: elevator checkpoint
- Resources: Copper, Iron, Gold, Iridium ores
- Gems and geodes for collection/sale
- Monsters for combat and drops

**Combat System:**
- Simple hit detection
- Weapon types: Swords, clubs, daggers
- Knockback mechanics
- Health and energy management

**Implementation:**
```gdscript
# Simple combat system
class_name CombatSystem extends Node

signal enemy_hit(damage: int)
signal player_hit(damage: int)

func attack(attacker: CharacterBody2D, target: CharacterBody2D, weapon_damage: int):
    var distance = attacker.global_position.distance_to(target.global_position)
    
    if distance < 50:  # Attack range
        var damage = weapon_damage + randi() % 5  # Add randomness
        target.take_damage(damage)
        apply_knockback(target, attacker.global_position)

func apply_knockback(target: CharacterBody2D, from_position: Vector2):
    var direction = (target.global_position - from_position).normalized()
    target.velocity = direction * 200  # Knockback force
```

### Fishing

**Mechanics:**
- Cast line in water
- Mini-game: Keep fish in green bar
- Different fish by:
  - Location (ocean, river, pond, lake)
  - Season
  - Weather
  - Time of day
- Fish quality based on mini-game performance

**Fishing Mini-game Logic:**
```gdscript
class_name FishingMinigame extends Control

var fish_position: float = 0.5  # 0 to 1
var bar_position: float = 0.5
var bar_size: float = 0.2
var catch_progress: float = 0.0
var fish_difficulty: float = 0.5

func _process(delta):
    # Update fish position (AI movement)
    fish_position += sin(Time.get_ticks_msec() * 0.001 * fish_difficulty) * delta
    fish_position = clamp(fish_position, 0.0, 1.0)
    
    # Player controls bar
    if Input.is_action_pressed("ui_accept"):
        bar_position -= 2.0 * delta
    else:
        bar_position += 1.5 * delta
    bar_position = clamp(bar_position, 0.0, 1.0)
    
    # Check if fish is in bar
    if abs(fish_position - bar_position) < bar_size / 2:
        catch_progress += delta
    else:
        catch_progress -= delta * 0.5
    
    catch_progress = clamp(catch_progress, 0.0, 1.0)
    
    if catch_progress >= 1.0:
        catch_fish()
    elif catch_progress <= 0.0:
        fish_escaped()
```

### Foraging

**Collectibles:**
- Seasonal items spawn on ground
- Different items per season
- Renewable resources (berries, mushrooms)
- Special items in specific locations

## 3. Crafting System

### Recipe Learning
- Unlock recipes via:
  - Skill level ups
  - TV programs
  - NPC gifts
  - Special events

### Crafting Stations
- **Furnace**: Smelt ores into bars
- **Preserves Jar**: Make jams and pickles
- **Keg**: Brew wine, beer, juice
- **Mayonnaise Machine**: Process eggs
- **Cheese Press**: Process milk
- **Loom**: Process wool into cloth

**Crafting Data Structure:**
```gdscript
class_name Recipe extends Resource

@export var recipe_name: String
@export var ingredients: Dictionary  # {item_name: quantity}
@export var result_item: String
@export var result_quantity: int = 1
@export var crafting_time: float = 0.0  # Hours in-game
@export var required_station: String = ""

func can_craft(inventory: Inventory) -> bool:
    for ingredient in ingredients:
        if inventory.get_item_count(ingredient) < ingredients[ingredient]:
            return false
    return true
```

## 4. Progression Systems

### Skills

**Five Main Skills:**
1. **Farming** (planting, harvesting crops)
2. **Mining** (breaking rocks, finding ores)
3. **Fishing** (catching fish)
4. **Foraging** (gathering wild items)
5. **Combat** (fighting monsters)

**Skill Progression:**
- 10 levels per skill
- Each level unlocks:
  - New recipes
  - Efficiency bonuses
  - Special abilities
- Level 5 & 10: Choose specialization

**Implementation:**
```gdscript
class_name SkillSystem extends Node

signal skill_leveled_up(skill_name: String, new_level: int)

var skills = {
    "farming": {"level": 0, "xp": 0, "xp_to_next": 100},
    "mining": {"level": 0, "xp": 0, "xp_to_next": 100},
    "fishing": {"level": 0, "xp": 0, "xp_to_next": 100},
    "foraging": {"level": 0, "xp": 0, "xp_to_next": 100},
    "combat": {"level": 0, "xp": 0, "xp_to_next": 100},
}

func add_xp(skill: String, amount: int):
    skills[skill]["xp"] += amount
    
    while skills[skill]["xp"] >= skills[skill]["xp_to_next"]:
        level_up_skill(skill)

func level_up_skill(skill: String):
    skills[skill]["level"] += 1
    skills[skill]["xp"] -= skills[skill]["xp_to_next"]
    skills[skill]["xp_to_next"] = int(skills[skill]["xp_to_next"] * 1.5)
    
    skill_leveled_up.emit(skill, skills[skill]["level"])
```

### Tools & Equipment

**Upgrade Progression:**
- Copper → Iron → Gold → Iridium
- Each tier:
  - Costs more materials
  - Requires higher-tier bars
  - Increases efficiency/power/range

### Community Center Bundles

**Purpose:** Long-term collection goals
- Complete bundles by donating specific items
- Rewards: New areas, recipes, permanent bonuses
- Alternative: Joja Corporation membership (money-based)

## 5. Social Systems

### NPC Friendship

**Mechanics:**
- 10 hearts per NPC (14 for marriage candidates)
- Increase through:
  - Talking daily (+20 points)
  - Giving liked/loved gifts (+80/+160 points)
  - Completing quests
  - Attending events together

**Heart Events:**
- Cutscenes at specific heart levels
- Reveal character backstory
- Can affect relationships (choices matter)

**Implementation:**
```gdscript
class_name NPC extends CharacterBody2D

@export var npc_name: String
@export var friendship_points: int = 0
@export var has_talked_today: bool = false
@export var birthday: String = ""
@export var loved_items: Array[String] = []
@export var liked_items: Array[String] = []
@export var disliked_items: Array[String] = []

func receive_gift(item_name: String):
    if item_name in loved_items:
        add_friendship(160)
    elif item_name in liked_items:
        add_friendship(80)
    elif item_name in disliked_items:
        add_friendship(-40)
    else:
        add_friendship(20)  # Neutral

func add_friendship(amount: int):
    friendship_points = clamp(friendship_points + amount, 0, 2500)
    # 250 points per heart, max 10 hearts (or 14 for marriage)
```

### Marriage System

**Requirements:**
- 10 hearts with bachelor/bachelorette
- Purchase Mermaid's Pendant
- Upgrade house
- Wedding ceremony

**Benefits:**
- Spouse helps with farm work
- Occasional gifts
- Children (2 maximum)

### Festivals & Events

**Annual Events:**
- Seasonal festivals (spring fair, winter festival, etc.)
- Special activities unique to each
- Opportunities for social interactions
- Unique items to purchase/win

## 6. Economy System

### Money Sources
1. **Selling crops** (main income early game)
2. **Artisan goods** (high-value processed items)
3. **Mining** (ores and gems)
4. **Fishing** (reliable daily income)
5. **Foraging** (low but consistent)

### Money Sinks
1. **Seeds** (constant expense)
2. **Tool upgrades** (major investments)
3. **Buildings** (barns, coops, sheds)
4. **Animals** (upfront cost)
5. **House upgrades** (quality of life)

**Balanced Economy Design:**
```gdscript
# Example pricing structure
const CROP_ECONOMICS = {
    "parsnip": {
        "seed_cost": 20,
        "sell_price": 35,
        "grow_time": 4,
        "profit_per_day": (35 - 20) / 4  # 3.75g/day
    },
    "strawberry": {
        "seed_cost": 100,
        "sell_price": 120,
        "grow_time": 8,
        "regrows": 4,  # Every 4 days after first harvest
        "profit_per_day": 120 / 8 + 120 / 4  # Initial + ongoing
    }
}
```

## 7. Calendar & Time System

### Time Mechanics
- **1 day = 20 real minutes** (default)
- 10-minute intervals displayed
- Day: 6:00 AM to 2:00 AM (next day)
- Forced sleep at 2:00 AM (energy penalty if not in bed)

### Seasonal System
- 4 seasons × 28 days = 112 days/year
- Crops tied to seasons (die at season change unless multi-season)
- Different events, fish, and foraging per season

**Implementation:**
```gdscript
class_name Calendar extends Node

signal day_changed(season: String, day: int)
signal season_changed(new_season: String)

var current_season: String = "Spring"
var current_day: int = 1
var current_year: int = 1

const SEASONS = ["Spring", "Summer", "Fall", "Winter"]
const DAYS_PER_SEASON = 28

func advance_day():
    current_day += 1
    
    if current_day > DAYS_PER_SEASON:
        current_day = 1
        advance_season()
    
    day_changed.emit(current_season, current_day)

func advance_season():
    var season_index = SEASONS.find(current_season)
    season_index = (season_index + 1) % SEASONS.size()
    current_season = SEASONS[season_index]
    
    if current_season == "Spring":
        current_year += 1
    
    season_changed.emit(current_season)
```

## Key Takeaways for FarmHouse Stories

### What Makes Stardew Valley Engaging:

1. **Interconnected Systems**: Every mechanic feeds into others
2. **Long-term Goals**: Bundles, relationships, farm perfection
3. **Daily Rewards**: Consistent sense of progress and achievement
4. **Player Choice**: Freedom to focus on preferred activities
5. **Depth**: Simple to learn, complex to master
6. **Cozy Atmosphere**: Low-stress, relaxing gameplay

### Implementation Priorities:

1. **Start with Farming**: It's the core loop
2. **Add Time System**: Creates urgency and planning
3. **Build Inventory/Crafting**: Foundation for all other systems
4. **Layer Complexity**: Add fishing, mining, social gradually
5. **Polish Feel**: Smooth controls, satisfying feedback

### Simplified Scope for FarmHouse Stories:

Consider starting with:
- ✅ Basic farming (plant, water, harvest)
- ✅ Simple tool system (hoe, watering can, axe, pickaxe)
- ✅ Day/night cycle with time management
- ✅ 2-3 NPCs with basic dialogue
- ✅ One crafting station type
- ✅ Basic inventory system

Then expand based on what works and what players enjoy.

---

**Related Documentation:**
- `01_ProjectOverview.md` - Overall project vision
- `07_ImplementationGuide.md` - Step-by-step development guide
- `04_OpenSourceProjects.md` - Code examples from similar games
