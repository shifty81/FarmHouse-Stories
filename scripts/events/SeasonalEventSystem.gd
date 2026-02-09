extends Node
## SeasonalEventSystem - Manages seasonal events tied to US holidays.
## Events are adapted to the fantasy world of Aethelgard and include
## special creatures, drops, activities, and time-limited content.

## All seasonal events mapped to in-game calendar
var events: Dictionary = {}

## Currently active event (empty string if none)
var active_event_id: String = ""

## Special creatures currently spawnable
var active_creatures: Array = []

## Special drops available during current event
var active_drops: Array = []

## Event completion tracking
var completed_events: Dictionary = {}


func _ready():
	_register_all_events()
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_ended.connect(_on_day_ended)


func _on_day_started(day: int, season: String):
	_check_event_activation(day, season)


func _on_day_ended():
	pass


func get_active_event() -> Dictionary:
	if active_event_id != "" and events.has(active_event_id):
		return events[active_event_id]
	return {}


func get_event_creatures() -> Array:
	return active_creatures


func get_event_drops() -> Array:
	return active_drops


func is_event_active() -> bool:
	return active_event_id != ""


func _check_event_activation(day: int, season: String):
	var previous_event = active_event_id
	active_event_id = ""
	active_creatures = []
	active_drops = []

	for event_id in events:
		var event = events[event_id]
		if event.season == season and day >= event.start_day and day <= event.end_day:
			active_event_id = event_id
			active_creatures = event.get("special_creatures", [])
			active_drops = event.get("special_drops", [])
			EventBus.active_event = event_id

			if previous_event != event_id:
				EventBus.seasonal_event_started.emit(event_id)
			return

	if previous_event != "" and active_event_id == "":
		EventBus.active_event = ""
		EventBus.seasonal_event_ended.emit(previous_event)


func _register_all_events():
	# === SPRING EVENTS ===

	# Valentine's Day equivalent (Feb 14 -> Spring Day 14)
	events["blossom_hearts"] = {
		"id": "blossom_hearts",
		"name": "Blossom Hearts Festival",
		"description": "A celebration of love and friendship. Give special Heart Blossoms to townsfolk for double friendship points.",
		"season": "Spring",
		"start_day": 13,
		"end_day": 15,
		"us_holiday": "Valentine's Day",
		"activities": ["gift_giving_bonus", "heart_blossom_crafting", "couples_dance"],
		"special_creatures": [
			{"id": "love_sprite", "name": "Love Sprite", "rarity": "uncommon", "description": "A tiny pink fairy that appears near flowering trees."}
		],
		"special_drops": [
			{"id": "heart_blossom", "name": "Heart Blossom", "description": "A heart-shaped flower that doubles friendship when gifted."},
			{"id": "cupids_arrow_seed", "name": "Cupid's Arrow Seed", "description": "Grows into a rare rose bush that blooms year-round."}
		],
		"rewards": ["double_friendship_gains", "heart_blossom_recipe"]
	}

	# St. Patrick's Day equivalent (Mar 17 -> Spring Day 17)
	events["emerald_fortune"] = {
		"id": "emerald_fortune",
		"name": "Emerald Fortune Day",
		"description": "Luck is in the air! Find golden clovers and chase leprechaun-like Rift sprites for bonus gold.",
		"season": "Spring",
		"start_day": 16,
		"end_day": 18,
		"us_holiday": "St. Patrick's Day",
		"activities": ["clover_hunt", "gold_sprite_chase", "lucky_fishing"],
		"special_creatures": [
			{"id": "gold_sprite", "name": "Gold Sprite", "rarity": "rare", "description": "A mischievous golden sprite that drops coins when caught."}
		],
		"special_drops": [
			{"id": "golden_clover", "name": "Golden Clover", "description": "Increases luck stat for the day when consumed."},
			{"id": "pot_of_gold_seeds", "name": "Pot of Gold Seeds", "description": "Rare seeds that yield golden crops worth triple."}
		],
		"rewards": ["luck_boost", "gold_multiplier"]
	}

	# Easter equivalent (Spring Day 21-23)
	events["spring_bloom_fair"] = {
		"id": "spring_bloom_fair",
		"name": "Spring Bloom Fair",
		"description": "A festival of lights and renewal! Find Petal-Pups hiding throughout the valley, hunt for enchanted eggs, and earn specialized planting seeds from festival games.",
		"season": "Spring",
		"start_day": 21,
		"end_day": 25,
		"us_holiday": "Easter",
		"activities": ["egg_hunt", "petal_pup_search", "seed_festival_games", "lantern_parade"],
		"special_creatures": [
			{"id": "petal_pup", "name": "Petal-Pup", "rarity": "uncommon", "description": "Adorable dog-like creatures made of living flower petals. Can be adopted as farm pets."},
			{"id": "bloom_bunny", "name": "Bloom Bunny", "rarity": "common", "description": "Flower-eared rabbits that leave trails of seeds wherever they hop."}
		],
		"special_drops": [
			{"id": "enchanted_egg", "name": "Enchanted Egg", "description": "Contains a random rare seed or cosmetic item."},
			{"id": "bloom_seed_pack", "name": "Bloom Seed Pack", "description": "Special seeds that grow 50% faster during Spring."},
			{"id": "petal_pup_treat", "name": "Petal-Pup Treat", "description": "Used to befriend and adopt Petal-Pups."},
			{"id": "festival_lantern", "name": "Festival Lantern", "description": "Decorative farm item that glows at night."}
		],
		"rewards": ["petal_pup_pet", "bloom_seeds", "spring_crown"]
	}

	# Mother's Day equivalent (Spring Day 10)
	events["nurturers_blessing"] = {
		"id": "nurturers_blessing",
		"name": "Nurturer's Blessing",
		"description": "Honor those who nurture. Crops planted today grow with bonus quality. Special bouquets available.",
		"season": "Spring",
		"start_day": 9,
		"end_day": 11,
		"us_holiday": "Mother's Day",
		"activities": ["bouquet_crafting", "garden_blessing", "family_dinner"],
		"special_creatures": [],
		"special_drops": [
			{"id": "nurturers_bouquet", "name": "Nurturer's Bouquet", "description": "Grants crop quality bonus when placed on farm."}
		],
		"rewards": ["crop_quality_boost"]
	}

	# Memorial Day equivalent (Spring Day 28)
	events["remembrance_vigil"] = {
		"id": "remembrance_vigil",
		"name": "Remembrance Vigil",
		"description": "The town honors fallen adventurers who protected Hearthhaven. Candle-lit ceremonies and stories of bravery.",
		"season": "Spring",
		"start_day": 27,
		"end_day": 28,
		"us_holiday": "Memorial Day",
		"activities": ["candle_ceremony", "story_circle", "memorial_dungeon_run"],
		"special_creatures": [
			{"id": "memory_wisp", "name": "Memory Wisp", "rarity": "rare", "description": "Gentle spirits of fallen adventurers that guide you in dungeons."}
		],
		"special_drops": [
			{"id": "heros_candle", "name": "Hero's Candle", "description": "Provides light and courage buffs in dungeons."}
		],
		"rewards": ["dungeon_courage_buff", "memorial_badge"]
	}

	# === SUMMER EVENTS ===

	# Independence Day equivalent (Jul 4 -> Summer Day 4)
	events["freedom_fireworks"] = {
		"id": "freedom_fireworks",
		"name": "Freedom Fireworks Festival",
		"description": "Celebrate with magical fireworks, cookouts, and competitive games! The whole town gathers at the square.",
		"season": "Summer",
		"start_day": 3,
		"end_day": 5,
		"us_holiday": "Independence Day",
		"activities": ["fireworks_show", "cookout_contest", "strength_games", "sparkler_crafting"],
		"special_creatures": [
			{"id": "spark_beetle", "name": "Spark Beetle", "rarity": "uncommon", "description": "Beetles that glow like fireworks and drop sparkle dust."}
		],
		"special_drops": [
			{"id": "sparkle_dust", "name": "Sparkle Dust", "description": "Used to craft decorative fireworks for the farm."},
			{"id": "freedom_banner", "name": "Freedom Banner", "description": "Festive farm decoration that attracts visitors."}
		],
		"rewards": ["fireworks_recipe", "freedom_hat"]
	}

	# Summer Solstice (Summer Day 21)
	events["sun_singe_solstice"] = {
		"id": "sun_singe_solstice",
		"name": "The Sun-Singe Solstice",
		"description": "The longest day brings an island beach party! Fishing competitions, sun-bathing, and tropical festivities. Special Sun-Touched Fish appear only during this event.",
		"season": "Summer",
		"start_day": 20,
		"end_day": 23,
		"us_holiday": "Summer Solstice",
		"activities": ["fishing_competition", "beach_party", "sun_bathing", "sandcastle_contest", "tiki_torch_lighting"],
		"special_creatures": [
			{"id": "sun_ray_fish", "name": "Sun-Ray Fish", "rarity": "rare", "description": "A golden fish that glows with solar energy. Only appears during peak sunlight."},
			{"id": "sand_crab_king", "name": "Sand Crab King", "rarity": "uncommon", "description": "An oversized hermit crab wearing a crown of shells."}
		],
		"special_drops": [
			{"id": "sun_touched_fish", "name": "Sun-Touched Fish", "description": "Used to craft fire-resistant potions essential for the Ember Forge dungeon."},
			{"id": "solar_scale", "name": "Solar Scale", "description": "Crafting material for sun-infused equipment."},
			{"id": "beach_treasure", "name": "Beach Treasure", "description": "Random valuable found while beach-combing."},
			{"id": "solstice_shell", "name": "Solstice Shell", "description": "Rare decorative shell that plays ocean sounds."}
		],
		"rewards": ["fire_resist_potion_recipe", "beach_umbrella_decor", "fishing_rod_upgrade"]
	}

	# Father's Day equivalent (Summer Day 15)
	events["crafters_honor"] = {
		"id": "crafters_honor",
		"name": "Crafter's Honor Day",
		"description": "A day to honor master craftsmen. Tool upgrades are discounted, and crafting yields bonus items.",
		"season": "Summer",
		"start_day": 14,
		"end_day": 16,
		"us_holiday": "Father's Day",
		"activities": ["tool_showcase", "crafting_marathon", "mentorship_bonding"],
		"special_creatures": [],
		"special_drops": [
			{"id": "master_polish", "name": "Master's Polish", "description": "Temporarily enhances tool effectiveness."}
		],
		"rewards": ["tool_discount", "crafting_bonus"]
	}

	# Labor Day equivalent (Summer Day 28)
	events["harvest_prep"] = {
		"id": "harvest_prep",
		"name": "Harvest Preparation Day",
		"description": "The town comes together to prepare for the fall harvest. Community farming events and feasts.",
		"season": "Summer",
		"start_day": 27,
		"end_day": 28,
		"us_holiday": "Labor Day",
		"activities": ["community_farming", "potluck_feast", "barn_raising"],
		"special_creatures": [],
		"special_drops": [
			{"id": "community_spirit", "name": "Community Spirit Token", "description": "Boosts all friendship gains for a week."}
		],
		"rewards": ["friendship_boost", "harvest_tools"]
	}

	# === FALL EVENTS ===

	# Halloween equivalent (Fall Day 28)
	events["harvest_moon_hallow"] = {
		"id": "harvest_moon_hallow",
		"name": "Harvest Moon Hallow",
		"description": "The town dons masks and costumes! A special Spooky Rift opens with exclusive dark-themed furniture and rare Void-Bat pets. Trick-or-treating yields unique candies with temporary buffs.",
		"season": "Fall",
		"start_day": 25,
		"end_day": 28,
		"us_holiday": "Halloween",
		"activities": ["trick_or_treating", "costume_contest", "spooky_rift_dungeon", "pumpkin_carving", "ghost_story_circle"],
		"special_creatures": [
			{"id": "void_bat", "name": "Void-Bat", "rarity": "rare", "description": "A bat infused with Rift energy. Can be tamed as a pet that scouts dungeons ahead of you."},
			{"id": "jack_o_wisp", "name": "Jack-o'-Wisp", "rarity": "uncommon", "description": "A pumpkin-headed spirit that leads you to hidden treasure."},
			{"id": "shadow_cat", "name": "Shadow Cat", "rarity": "rare", "description": "A spectral cat that phases through walls and reveals secret passages."}
		],
		"special_drops": [
			{"id": "void_bat_treat", "name": "Void-Bat Treat", "description": "Used to tame Void-Bats as dungeon companion pets."},
			{"id": "spooky_furniture_set", "name": "Spooky Furniture Blueprint", "description": "Dark-themed furniture collection for farm decoration."},
			{"id": "candy_corn_boost", "name": "Enchanted Candy Corn", "description": "Temporary buff: +20% dungeon loot for 3 days."},
			{"id": "phantom_mask", "name": "Phantom Mask", "description": "Cosmetic headgear with minor stealth bonus in dungeons."},
			{"id": "haunted_pumpkin_seed", "name": "Haunted Pumpkin Seed", "description": "Grows into a giant glowing pumpkin decoration."}
		],
		"rewards": ["void_bat_pet", "spooky_furniture", "phantom_mask", "hallow_crown"]
	}

	# Thanksgiving equivalent (Fall Day 22-24)
	events["great_harvest_feast"] = {
		"id": "great_harvest_feast",
		"name": "The Great Harvest Feast",
		"description": "A grand community feast celebrating the fall harvest. Contribute dishes for town-wide buffs.",
		"season": "Fall",
		"start_day": 22,
		"end_day": 24,
		"us_holiday": "Thanksgiving",
		"activities": ["community_cooking", "feast_preparation", "gratitude_gifts", "harvest_parade"],
		"special_creatures": [
			{"id": "golden_turkey", "name": "Golden Turkey", "rarity": "rare", "description": "A majestic golden bird that drops rare cooking ingredients."}
		],
		"special_drops": [
			{"id": "feast_platter", "name": "Feast Platter", "description": "Restores full energy and provides all-day buffs."},
			{"id": "gratitude_gem", "name": "Gratitude Gem", "description": "Major friendship boost when gifted to any NPC."},
			{"id": "cornucopia_seed", "name": "Cornucopia Seeds", "description": "Grows a decorative cornucopia overflowing with produce."}
		],
		"rewards": ["feast_recipe_book", "gratitude_bonus", "harvest_crown"]
	}

	# Columbus Day / Indigenous Peoples' Day equivalent (Fall Day 10)
	events["explorers_journey"] = {
		"id": "explorers_journey",
		"name": "Explorer's Journey",
		"description": "Celebrate exploration and discovery. Special map fragments appear in dungeons and the overworld.",
		"season": "Fall",
		"start_day": 9,
		"end_day": 11,
		"us_holiday": "Columbus Day / Indigenous Peoples' Day",
		"activities": ["map_fragment_hunt", "exploration_challenge", "history_exhibit"],
		"special_creatures": [
			{"id": "trail_fox", "name": "Trail Fox", "rarity": "uncommon", "description": "A clever fox that leads you to hidden areas."}
		],
		"special_drops": [
			{"id": "ancient_map_fragment", "name": "Ancient Map Fragment", "description": "Collect all pieces to reveal a hidden dungeon."}
		],
		"rewards": ["exploration_bonus", "ancient_map"]
	}

	# Veterans Day equivalent (Fall Day 11)
	events["warriors_tribute"] = {
		"id": "warriors_tribute",
		"name": "Warrior's Tribute",
		"description": "Honor veteran adventurers. Dungeon rewards are doubled and Reed shares special combat techniques.",
		"season": "Fall",
		"start_day": 11,
		"end_day": 12,
		"us_holiday": "Veterans Day",
		"activities": ["combat_training", "veteran_stories", "gear_blessing"],
		"special_creatures": [],
		"special_drops": [
			{"id": "veterans_medal", "name": "Veteran's Medal", "description": "Permanently increases combat XP gains by 5%."}
		],
		"rewards": ["double_dungeon_loot", "combat_technique"]
	}

	# === WINTER EVENTS ===

	# Christmas equivalent (Winter Day 25)
	events["great_frost_light"] = {
		"id": "great_frost_light",
		"name": "The Great Frost-Light",
		"description": "The city lights up with magical frost-lights! Gift-giving dramatically boosts relationships. Rare ice monsters drop Ice Shards to upgrade winter gear. The whole town celebrates with feasts, music, and a grand tree-lighting ceremony.",
		"season": "Winter",
		"start_day": 23,
		"end_day": 27,
		"us_holiday": "Christmas",
		"activities": ["gift_exchange", "tree_lighting", "carol_singing", "ice_sculpture_contest", "frost_light_decoration", "winter_feast"],
		"special_creatures": [
			{"id": "frost_stag", "name": "Frost Stag", "rarity": "rare", "description": "A majestic ice-antlered deer that appears in snowy fields. Drops Ice Shards."},
			{"id": "snow_sprite", "name": "Snow Sprite", "rarity": "uncommon", "description": "Playful ice fairies that gift random presents when caught."},
			{"id": "ice_golem_mini", "name": "Mini Ice Golem", "rarity": "uncommon", "description": "A small animated snowman that guards hidden winter treasure."}
		],
		"special_drops": [
			{"id": "ice_shard", "name": "Ice Shard", "description": "Used to upgrade winter gear and craft frost-enchanted equipment."},
			{"id": "frost_light", "name": "Frost-Light", "description": "Magical light decoration for farm and home."},
			{"id": "gift_box", "name": "Wrapped Gift Box", "description": "Contains a random rare item. Better gifts for higher friendship NPCs."},
			{"id": "winter_star_ornament", "name": "Winter Star Ornament", "description": "Rare collectible that boosts all seasonal event rewards."},
			{"id": "hot_cocoa_mix", "name": "Hot Cocoa Mix", "description": "Restores energy and provides cold resistance buff."}
		],
		"rewards": ["ice_gear_upgrades", "frost_light_set", "winter_crown", "relationship_boost"]
	}

	# New Year's equivalent (Winter Day 28 / Spring Day 1)
	events["new_dawn_festival"] = {
		"id": "new_dawn_festival",
		"name": "New Dawn Festival",
		"description": "Ring in the new year with fireworks and resolutions! Set goals for bonus rewards throughout the coming year.",
		"season": "Winter",
		"start_day": 27,
		"end_day": 28,
		"us_holiday": "New Year's Eve / New Year's Day",
		"activities": ["countdown_ceremony", "resolution_setting", "fireworks_finale", "midnight_toast"],
		"special_creatures": [
			{"id": "chrono_butterfly", "name": "Chrono Butterfly", "rarity": "rare", "description": "A time-touched butterfly that briefly slows time around it."}
		],
		"special_drops": [
			{"id": "resolution_scroll", "name": "Resolution Scroll", "description": "Set a goal for the year for bonus rewards."},
			{"id": "new_dawn_gem", "name": "New Dawn Gem", "description": "Start the new year with a luck boost."}
		],
		"rewards": ["yearly_resolution_bonus", "luck_boost"]
	}

	# MLK Day equivalent (Winter Day 15)
	events["unity_day"] = {
		"id": "unity_day",
		"name": "Unity Day",
		"description": "A day celebrating community bonds. All friendship interactions give triple points.",
		"season": "Winter",
		"start_day": 14,
		"end_day": 16,
		"us_holiday": "Martin Luther King Jr. Day",
		"activities": ["community_gathering", "peace_walk", "unity_quilt"],
		"special_creatures": [],
		"special_drops": [
			{"id": "unity_ribbon", "name": "Unity Ribbon", "description": "Wear for triple friendship gains all day."}
		],
		"rewards": ["triple_friendship", "unity_decoration"]
	}

	# Presidents' Day equivalent (Winter Day 18)
	events["founders_day"] = {
		"id": "founders_day",
		"name": "Founder's Day",
		"description": "Celebrate Hearthhaven's founding. The mayor opens the town vault with discounted shop prices.",
		"season": "Winter",
		"start_day": 17,
		"end_day": 19,
		"us_holiday": "Presidents' Day",
		"activities": ["history_tour", "vault_sale", "founder_statue_ceremony"],
		"special_creatures": [],
		"special_drops": [
			{"id": "founders_coin", "name": "Founder's Coin", "description": "Commemorative coin worth bonus gold at shops."}
		],
		"rewards": ["shop_discounts", "founders_badge"]
	}


func get_save_data() -> Dictionary:
	return {
		"active_event_id": active_event_id,
		"completed_events": completed_events.duplicate()
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("completed_events"):
		completed_events = data.completed_events
