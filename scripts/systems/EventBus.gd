extends Node
## EventBus - Global signal hub for FarmHouse Stories.
## Provides signals for decoupled communication between game systems.

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

# NPC signals
signal npc_friendship_changed(npc_id: String, level: int)
signal npc_dialogue_triggered(npc_id: String, dialogue_key: String)
signal npc_gift_given(npc_id: String, item_id: String)
signal npc_quest_started(npc_id: String, quest_id: String)
signal npc_quest_completed(npc_id: String, quest_id: String)
signal npc_schedule_changed(npc_id: String, location: String)

# Gear signals
signal gear_set_changed(set_type: String)
signal gear_equipped(slot: String, item_id: String)
signal gear_upgraded(item_id: String, new_level: int)
signal ethereal_tokens_changed(amount: int)

# Dungeon signals
signal dungeon_entered(dungeon_id: String)
signal dungeon_exited(dungeon_id: String)
signal dungeon_room_cleared(room_id: String)
signal dungeon_boss_defeated(boss_id: String)
signal dungeon_key_obtained(key_type: String)
signal dungeon_puzzle_solved(puzzle_id: String)

# Mythic Rift signals
signal mythic_rift_opened(rift_tier: int)
signal mythic_rift_completed(rift_tier: int, rewards: Dictionary)
signal chronos_shard_obtained
signal vendor_item_exchanged(item_id: String, token_cost: int)

# Seasonal event signals
signal seasonal_event_started(event_id: String)
signal seasonal_event_ended(event_id: String)
signal special_creature_spawned(creature_id: String)
signal special_item_obtained(item_id: String)

# Global game state
var current_day: int = 1
var current_season: String = "Spring"
var current_hour: int = 6
var player_money: int = 500
var player_energy: int = 100
var player_max_energy: int = 100
var ethereal_tokens: int = 0
var active_gear_set: String = "farm"
var current_dungeon: String = ""
var active_event: String = ""
