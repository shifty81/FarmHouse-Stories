extends Node
## GameBalance - Centralized balance constants and progression curves.
## Provides tuning values used by CombatSystem, CraftingSystem, FishingSystem,
## MiningSystem, GearSetSystem, and InventorySystem for consistent game economy.

## ─── Economy Constants ───
const SELL_PRICE_MULTIPLIER: float = 0.5  ## Sell prices as fraction of buy prices
const CROP_PROFIT_MARGIN: float = 2.5     ## Minimum crop sell / seed buy ratio
const FISHING_GOLD_PER_MINUTE: float = 3.0 ## Target income from fishing per in-game minute
const MINING_GOLD_PER_MINUTE: float = 2.5  ## Target income from mining per in-game minute

## ─── XP & Leveling ───
const BASE_XP_PER_LEVEL: int = 100
const XP_SCALING_FACTOR: float = 1.35     ## Each level requires 35% more XP
const MAX_PLAYER_LEVEL: int = 50

## ─── Combat Scaling ───
const PLAYER_BASE_HP: int = 100
const PLAYER_HP_PER_LEVEL: int = 8
const PLAYER_ATTACK_PER_LEVEL: int = 2
const PLAYER_DEFENSE_PER_LEVEL: int = 1
const DAMAGE_VARIANCE_MIN: float = 0.85
const DAMAGE_VARIANCE_MAX: float = 1.15
const BOSS_HP_MULTIPLIER: float = 4.0     ## Bosses have N× regular enemy HP at same tier
const BOSS_XP_MULTIPLIER: float = 5.0     ## Bosses give N× regular enemy XP

## ─── Status Effects ───
const POISON_DAMAGE_PER_TURN: int = 3
const POISON_DURATION: int = 3
const BURN_DAMAGE_PER_TURN: int = 5
const BURN_DURATION: int = 2
const FREEZE_DURATION: int = 2          ## Turns unable to act
const STUN_DURATION: int = 1

## ─── Gear Progression ───
const GEAR_UPGRADE_STAT_BONUS: float = 0.15      ## +15% stats per upgrade level
const GEAR_UPGRADE_TOKEN_BASE: int = 4            ## Base Ethereal Token cost
const GEAR_UPGRADE_TOKEN_SCALING: float = 1.5     ## Each level costs 50% more tokens

## ─── Farming ───
const CROP_QUALITY_BONUS_PER_HEART: float = 0.02  ## +2% quality per NPC friendship level
const RIFT_TOUCHED_CROP_MULTIPLIER: float = 1.8   ## Rift-touched crop sell price multiplier
const FERTILIZER_GROWTH_REDUCTION: float = 0.25   ## Fertilizer reduces grow time by 25%

## ─── Fishing ───
const BAIT_CATCH_RATE_BONUS: float = 0.15         ## Bait adds 15% to catch rates
const ROD_TIER_CATCH_BONUS: float = 0.10           ## Each rod tier adds 10% catch rate

## ─── Mining ───
const MINE_DEPTH_ORE_BONUS: float = 0.05          ## +5% rare ore chance per 10 levels deep
const GEM_DROP_CHANCE_BASE: float = 0.05           ## Base gem drop chance from any rock

## ─── Dungeon Difficulty ───
const DUNGEON_ENEMY_COUNT_BASE: int = 3
const DUNGEON_ENEMY_COUNT_PER_DIFFICULTY: int = 1  ## +1 enemy per room per difficulty tier
const MYTHIC_RIFT_REWARD_SCALING: float = 1.4      ## Each tier gives 40% more rewards

## Player level tracking
var player_level: int = 1
var player_xp: int = 0


func _ready() -> void:
	EventBus.combat_ended.connect(_on_combat_ended)


## Calculate XP required for a specific level.
func xp_for_level(level: int) -> int:
	return int(BASE_XP_PER_LEVEL * pow(XP_SCALING_FACTOR, level - 1))


## Add XP to the player. Returns true if the player leveled up.
func add_xp(amount: int) -> bool:
	player_xp += amount
	var leveled_up := false

	while player_level < MAX_PLAYER_LEVEL and player_xp >= xp_for_level(player_level + 1):
		player_xp -= xp_for_level(player_level + 1)
		player_level += 1
		leveled_up = true
		_apply_level_up()

	return leveled_up


## Apply stat gains on level up.
func _apply_level_up() -> void:
	var combat := get_node_or_null("/root/CombatSystem")
	if combat:
		combat.player_max_hp += PLAYER_HP_PER_LEVEL
		combat.player_hp = combat.player_max_hp
		combat.player_attack += PLAYER_ATTACK_PER_LEVEL
		combat.player_defense += PLAYER_DEFENSE_PER_LEVEL


## Calculate upgrade token cost for a given level.
func upgrade_token_cost(current_level: int) -> int:
	return int(GEAR_UPGRADE_TOKEN_BASE * pow(GEAR_UPGRADE_TOKEN_SCALING, current_level))


func _on_combat_ended() -> void:
	pass


## Save balance data.
func get_save_data() -> Dictionary:
	return {
		"player_level": player_level,
		"player_xp": player_xp
	}


## Load balance data.
func load_save_data(data: Dictionary) -> void:
	if data.has("player_level"):
		player_level = data.player_level
	if data.has("player_xp"):
		player_xp = data.player_xp
