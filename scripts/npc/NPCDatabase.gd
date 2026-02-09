extends Node
## NPCDatabase - Central registry of all Hearthhaven citizens.
## Contains data for 35 NPCs with unique backstories, schedules, and questlines.

var citizens: Dictionary = {}


func _ready():
	_register_all_citizens()


func get_npc(npc_id: String) -> Dictionary:
	if citizens.has(npc_id):
		return citizens[npc_id]
	return {}


func get_all_npc_ids() -> Array:
	return citizens.keys()


func get_npcs_at_location(location: String, hour: int) -> Array:
	var result = []
	for npc_id in citizens:
		var npc = citizens[npc_id]
		var current_loc = _get_npc_location(npc, hour)
		if current_loc == location:
			result.append(npc_id)
	return result


func add_friendship(npc_id: String, points: int) -> void:
	if not citizens.has(npc_id):
		return
	var npc = citizens[npc_id]
	npc.friendship_points += points
	var new_level = mini(npc.friendship_points / 250, 10)
	if new_level != npc.friendship_level:
		npc.friendship_level = new_level
		EventBus.npc_friendship_changed.emit(npc_id, new_level)


func get_friendship(npc_id: String) -> int:
	if citizens.has(npc_id):
		return citizens[npc_id].friendship_level
	return 0


func _get_npc_location(npc: Dictionary, hour: int) -> String:
	var schedule = npc.get("schedule", {})
	var best_hour = -1
	var location = npc.get("home_location", "")
	for schedule_hour in schedule:
		var h = int(schedule_hour)
		if h <= hour and h > best_hour:
			best_hour = h
			location = schedule[schedule_hour]
	return location


func _register_all_citizens():
	# === KEY STORY NPCs ===
	_add_npc("rowland_smith", {
		"display_name": "Rowland Smith",
		"age": 42,
		"occupation": "Blacksmith",
		"personality": "Moody, guarded, deeply skilled",
		"backstory": "The town's master blacksmith who crafts and upgrades tools and forges specialized gear for Rift Dungeons. After losing his partner in a dungeon collapse, he swore never to return underground. His trauma hides the knowledge needed to forge Legendary-tier gear. Earning his trust means helping him confront his past and ultimately unlocking the most powerful equipment upgrades in the game.",
		"home_location": "rowland_house",
		"work_location": "blacksmith_shop",
		"favorite_gifts": ["iron_ore", "ancient_metal", "fire_crystal"],
		"disliked_gifts": ["flowers", "sweets"],
		"birthday_season": "Winter",
		"birthday_day": 15,
		"schedule": {"7": "blacksmith_shop", "8": "blacksmith_shop", "17": "blacksmith_shop", "18": "tavern", "21": "rowland_house"},
		"quest_chain": ["rowland_bellows", "rowland_void_weapon", "rowland_legacy"],
		"quest_requirements": {
			"rowland_bellows": {"heart_level": 2, "title": "Bring me 50 Copper Ore", "description": "Rowland asks for resources to fix his bellows."},
			"rowland_void_weapon": {"heart_level": 5, "title": "A Weapon for the Void", "description": "Rowland asks for rare, high-tier Rift materials to create a special weapon, unlocking a new weapon type."},
			"rowland_legacy": {"heart_level": 8, "title": "Forging a Legacy", "description": "Rowland asks to meet your grandfather's old spirit, revealing his past training."}
		}
	})

	_add_npc("elara", {
		"display_name": "Elara",
		"age": 34,
		"occupation": "Archaeologist / Scholar",
		"personality": "Curious, scholarly, warm",
		"backstory": "Researches the history of Aethelgard and the nature of the Rifts. She operates the Hearthhaven Museum and Library, serving as the valley's lore keeper. She has spent years translating ancient texts that hint at the true origin of the Rifts and Aethelgard itself. Her storyline reveals the world's deepest secrets and provides critical clues to dungeon puzzles.",
		"home_location": "elara_house",
		"work_location": "museum_library",
		"favorite_gifts": ["ancient_scroll", "rare_book", "ink_pot"],
		"disliked_gifts": ["raw_fish", "slime"],
		"birthday_season": "Fall",
		"birthday_day": 7,
		"schedule": {"9": "museum_library", "13": "town_archives", "16": "valley_patrol", "22": "elara_house"},
		"quest_chain": ["elara_artifact", "elara_cipher", "elara_truth"],
		"quest_requirements": {
			"elara_artifact": {"heart_level": 2, "title": "Locate a Lost Artifact", "description": "Elara tasks you with finding a specific item in a low-level dungeon."},
			"elara_cipher": {"heart_level": 5, "title": "Unraveling the Cipher", "description": "Elara asks for a scroll from a specific, dangerous, and puzzle-heavy rift."},
			"elara_truth": {"heart_level": 8, "title": "The Truth Behind the Void", "description": "Elara shares her research, revealing the origin of the rifts."}
		}
	})

	_add_npc("barnaby", {
		"display_name": "Barnaby",
		"age": 28,
		"occupation": "Farmer / Botanist",
		"personality": "Shy, kind, passionate about plants",
		"backstory": "A timid neighbor who runs a greenhouse specializing in rare cross-pollination experiments. His social anxiety keeps him isolated, but his botanical knowledge is unmatched. Befriending him and helping him overcome his fears leads to access to the rarest produce and rift-touched crop varieties.",
		"home_location": "barnaby_greenhouse",
		"work_location": "barnaby_greenhouse",
		"favorite_gifts": ["rare_seeds", "rift_blossom", "compost"],
		"disliked_gifts": ["weapons", "dungeon_loot"],
		"birthday_season": "Spring",
		"birthday_day": 14,
		"schedule": {"6": "barnaby_greenhouse", "10": "farm_area", "12": "barnaby_greenhouse", "15": "market_square", "17": "barnaby_greenhouse", "21": "barnaby_greenhouse"},
		"quest_chain": ["barnaby_seeds", "barnaby_courage", "barnaby_masterwork", "rare_harvest"]
	})

	_add_npc("mayor_thornwell", {
		"display_name": "Mayor Thornwell",
		"age": 58,
		"occupation": "Mayor",
		"personality": "Jovial, proud, occasionally pompous",
		"backstory": "The long-serving mayor of Hearthhaven who takes great pride in the community. He organizes all major festivals and events. Beneath his cheerful exterior, he carries guilt about a decision years ago that may have worsened the Rift activity. His questline reveals political intrigue and the town's founding secrets.",
		"home_location": "mayor_mansion",
		"work_location": "town_hall",
		"favorite_gifts": ["gold_bar", "fine_wine", "truffle"],
		"disliked_gifts": ["junk", "bait"],
		"birthday_season": "Summer",
		"birthday_day": 22,
		"schedule": {"6": "mayor_mansion", "8": "town_hall", "12": "tavern", "14": "market_square", "17": "town_hall", "20": "mayor_mansion"},
		"quest_chain": ["thornwell_festival", "thornwell_secret", "thornwell_confession", "town_charter"]
	})

	_add_npc("marlowe", {
		"display_name": "Marlowe",
		"age": 38,
		"occupation": "Tavern Owner",
		"personality": "Boisterous, caring, gossip-lover",
		"backstory": "Runs 'The Bludgeoned Barrister' tavern at the center of Hearthhaven. Marlowe serves food and drinks and provides a social hub for the villagers. A former adventurer turned barkeep, she has connections to the dungeon-delving community and can point you toward hidden quests. Her story involves rebuilding after a mysterious fire years ago.",
		"home_location": "tavern_upstairs",
		"work_location": "tavern",
		"favorite_gifts": ["aged_spirits", "exotic_spice", "recipe_book"],
		"disliked_gifts": ["plain_water", "dirt"],
		"birthday_season": "Fall",
		"birthday_day": 19,
		"schedule": {"5": "tavern_upstairs", "6": "tavern", "13": "park", "15": "tavern", "23": "tavern_upstairs"},
		"quest_chain": ["marlowe_rare_blend", "marlowe_entertainment", "marlowe_toast"],
		"quest_requirements": {
			"marlowe_rare_blend": {"heart_level": 2, "title": "A Rare Blend", "description": "Asks for a special, foraged item to make a new drink."},
			"marlowe_entertainment": {"heart_level": 5, "title": "The Evening Entertainment", "description": "Asks for a musical instrument or a special performance to liven up the tavern."},
			"marlowe_toast": {"heart_level": 8, "title": "A Toast to the Town", "description": "The owner shares a deeply personal story."}
		}
	})

	_add_npc("jessop_edwards", {
		"display_name": "Jessop Edwards",
		"age": 45,
		"occupation": "Town Doctor",
		"personality": "Precise, empathetic, secretive",
		"backstory": "Provides medical care, cures illnesses from Rift exposure, and manages the town Apothecary. He came to the valley fleeing a scandal at a city hospital. His medical knowledge extends to crafting unique healing potions. His storyline involves confronting his past and developing cures for rift-touched ailments.",
		"home_location": "clinic_upstairs",
		"work_location": "clinic",
		"favorite_gifts": ["medicinal_herb", "crystal_vial", "research_notes"],
		"disliked_gifts": ["alcohol", "void_essence"],
		"birthday_season": "Winter",
		"birthday_day": 3,
		"schedule": {"8": "clinic", "10": "clinic", "16": "clinic", "17": "river_bank", "20": "clinic_upstairs"},
		"quest_chain": ["jessop_herbs", "jessop_rift_sickness", "jessop_ailment"],
		"quest_requirements": {
			"jessop_herbs": {"heart_level": 2, "title": "Forage for Medicinal Herbs", "description": "Asks for 10 units of a rare herb to make a potion for an ill villager."},
			"jessop_rift_sickness": {"heart_level": 5, "title": "The Rift Sickness", "description": "Asks for a potion-like ingredient found inside a difficult, high-level dungeon."},
			"jessop_ailment": {"heart_level": 8, "title": "An Uncurable Ailment", "description": "Jessop reveals his fear of the rifts and asks to research the origin of the sickness."}
		}
	})

	_add_npc("garrick", {
		"display_name": "Garrick",
		"age": 52,
		"occupation": "General Store Owner",
		"personality": "Shrewd, fair, old-fashioned",
		"backstory": "Runs Hearthhaven's general store, stocking everything from seeds to basic adventuring supplies. A third-generation shopkeeper, Garrick has seen the town change over decades. He secretly hoards rare items and his quest involves uncovering a family treasure map hidden in old ledgers.",
		"home_location": "general_store_upstairs",
		"work_location": "general_store",
		"favorite_gifts": ["rare_gem", "antique_coin", "fine_cloth"],
		"disliked_gifts": ["cheap_bait", "rotten_crop"],
		"birthday_season": "Spring",
		"birthday_day": 25,
		"schedule": {"6": "general_store_upstairs", "8": "general_store", "13": "tavern", "14": "general_store", "19": "general_store_upstairs"},
		"quest_chain": ["garrick_inventory", "garrick_ledgers", "garrick_treasure"]
	})

	_add_npc("fern", {
		"display_name": "Fern",
		"age": 22,
		"occupation": "Florist",
		"personality": "Dreamy, artistic, gentle",
		"backstory": "A young florist who cultivates both ordinary and rift-touched flowers. She believes the Rifts are beautiful rather than dangerous and creates arrangements that harness subtle magical properties. Her story explores the artistic side of Aethelgard's magic and unlocks decorative items for your farm.",
		"home_location": "flower_shop_upstairs",
		"work_location": "flower_shop",
		"favorite_gifts": ["rift_blossom", "paint_set", "butterfly_jar"],
		"disliked_gifts": ["iron_ore", "monster_parts"],
		"birthday_season": "Spring",
		"birthday_day": 8,
		"schedule": {"6": "flower_shop_upstairs", "8": "flower_shop", "12": "park", "14": "flower_shop", "17": "river_bank", "20": "flower_shop_upstairs"},
		"quest_chain": ["fern_bouquets", "fern_rift_garden", "fern_masterpiece"]
	})

	_add_npc("jack_watt", {
		"display_name": "Jack Watt",
		"age": 30,
		"occupation": "Carpenter",
		"personality": "Sturdy, reliable, quiet",
		"backstory": "Builds and upgrades farm structures, homes, and public facilities. A craftsman of few words but extraordinary skill. His family built the original Clock Tower. Helping him restore old structures around town reveals architectural secrets and unlocks farm building upgrades.",
		"home_location": "carpenter_shop",
		"work_location": "carpenter_shop",
		"favorite_gifts": ["hardwood", "blueprint", "fine_tools"],
		"disliked_gifts": ["cheap_food", "mud"],
		"birthday_season": "Summer",
		"birthday_day": 10,
		"schedule": {"6": "carpenter_shop", "9": "lumber_yard", "18": "lumber_yard", "19": "tavern", "21": "carpenter_shop"},
		"quest_chain": ["jack_hardwood", "jack_structural", "jack_future"],
		"quest_requirements": {
			"jack_hardwood": {"heart_level": 2, "title": "Bring 100 Hardwood", "description": "Jack asks for resources to repair a town bridge."},
			"jack_structural": {"heart_level": 5, "title": "The Structural Integrity Task", "description": "Jack asks for specialized materials to reinforce your farm against a future Rift Siege."},
			"jack_future": {"heart_level": 8, "title": "Designing a New Future", "description": "Jack asks you to help design a new, specialized building in town."}
		}
	})

	_add_npc("isla", {
		"display_name": "Isla",
		"age": 26,
		"occupation": "Fisher",
		"personality": "Independent, witty, adventurous",
		"backstory": "A skilled fisher who works the rivers and coastal areas around Hearthhaven. She discovered strange aquatic creatures appearing since the Rifts intensified. Isla teaches fishing techniques and her questline involves tracking a legendary rift-touched fish rumored to grant visions.",
		"home_location": "dock_house",
		"work_location": "fishing_dock",
		"favorite_gifts": ["rare_bait", "ocean_gem", "boat_parts"],
		"disliked_gifts": ["dry_food", "books"],
		"birthday_season": "Summer",
		"birthday_day": 5,
		"schedule": {"5": "fishing_dock", "11": "dock_house", "13": "market_square", "15": "river_bank", "19": "tavern", "22": "dock_house"},
		"quest_chain": ["isla_fishing", "isla_creature", "isla_legendary_catch"]
	})

	_add_npc("theron", {
		"display_name": "Theron",
		"age": 35,
		"occupation": "Ranger / Guard Captain",
		"personality": "Stoic, protective, honorable",
		"backstory": "Captain of Hearthhaven's small guard force and an expert ranger. He patrols the valley's borders where Rift activity is strongest. His deep knowledge of the wilderness and combat makes him a valuable ally. His storyline involves uncovering a threat from beyond the Echo Ridge.",
		"home_location": "guard_barracks",
		"work_location": "guard_post",
		"favorite_gifts": ["quality_bow", "leather_armor", "trail_rations"],
		"disliked_gifts": ["perfume", "jewelry"],
		"birthday_season": "Fall",
		"birthday_day": 2,
		"schedule": {"5": "guard_post", "10": "valley_patrol", "13": "guard_barracks", "14": "training_grounds", "18": "tavern", "22": "guard_barracks"},
		"quest_chain": ["theron_patrol", "theron_threat", "theron_defense", "echo_ridge_secret"]
	})

	_add_npc("clara", {
		"display_name": "Clara",
		"age": 19,
		"occupation": "Baker's Apprentice",
		"personality": "Cheerful, clumsy, determined",
		"backstory": "The youngest worker at Hearthhaven's bakery, Clara dreams of opening her own patisserie. She's enthusiastic but accident-prone, often creating surprisingly useful failed experiments. Her questline involves perfecting recipes using rift-touched ingredients.",
		"home_location": "bakery_upstairs",
		"work_location": "bakery",
		"favorite_gifts": ["sugar", "vanilla_extract", "recipe_book"],
		"disliked_gifts": ["raw_meat", "bugs"],
		"birthday_season": "Spring",
		"birthday_day": 20,
		"schedule": {"5": "bakery", "12": "market_square", "13": "bakery", "17": "park", "19": "bakery_upstairs"},
		"quest_chain": ["clara_recipes", "clara_rift_baking", "clara_patisserie"]
	})

	_add_npc("old_moss", {
		"display_name": "Old Moss",
		"age": 78,
		"occupation": "Hermit / Herbalist",
		"personality": "Eccentric, wise, cryptic",
		"backstory": "An elderly hermit living at the edge of the valley near the Whispering Wastes. He remembers when the Rifts first appeared and speaks in riddles. His vast herbal knowledge provides unique potion recipes. His storyline reveals he was once a powerful rift-walker who sealed the original breach.",
		"home_location": "moss_cabin",
		"work_location": "moss_cabin",
		"favorite_gifts": ["rare_mushroom", "void_essence", "ancient_scroll"],
		"disliked_gifts": ["technology", "loud_items"],
		"birthday_season": "Winter",
		"birthday_day": 21,
		"schedule": {"6": "moss_cabin", "10": "forest_edge", "14": "moss_cabin", "16": "whispering_wastes_edge", "20": "moss_cabin"},
		"quest_chain": ["moss_herbs", "moss_memories", "moss_truth", "original_seal"]
	})

	_add_npc("void_vendor", {
		"display_name": "The Shrouded One",
		"age": -1,
		"occupation": "Void Anchor Vendor",
		"personality": "Mysterious, ancient, transactional",
		"backstory": "A cloaked figure who appears near the Void Anchor at the valley's edge. No one knows their true identity or origin. They accept Chronos Shards and rare dungeon items in exchange for opening Mythic Rifts and selling Ethereal Token upgrade materials. Some whisper they are a fragment of the Rifts themselves.",
		"home_location": "void_anchor",
		"work_location": "void_anchor",
		"favorite_gifts": ["chronos_shard", "void_essence", "ethereal_token"],
		"disliked_gifts": [],
		"birthday_season": "Winter",
		"birthday_day": 28,
		"schedule": {"0": "void_anchor"},
		"quest_chain": ["void_vendor_intro", "void_vendor_trust", "void_vendor_revelation"]
	})

	_add_npc("petra", {
		"display_name": "Petra",
		"age": 40,
		"occupation": "Miner",
		"personality": "Tough, practical, loyal",
		"backstory": "A veteran miner who works the caverns beneath Echo Ridge. She's uncovered strange minerals that react to Rift energy. Practical and no-nonsense, Petra provides mining tips and access to deeper cave systems. Her story involves discovering an ancient underground civilization.",
		"home_location": "miners_quarters",
		"work_location": "mine_entrance",
		"favorite_gifts": ["rare_gem", "pickaxe_upgrade", "dynamite"],
		"disliked_gifts": ["flowers", "poetry"],
		"birthday_season": "Summer",
		"birthday_day": 18,
		"schedule": {"5": "mine_entrance", "12": "miners_quarters", "13": "mine_entrance", "18": "tavern", "21": "miners_quarters"},
		"quest_chain": ["petra_ores", "petra_deep_mine", "petra_civilization"]
	})

	_add_npc("jasper", {
		"display_name": "Jasper",
		"age": 32,
		"occupation": "Jeweler / Enchanter",
		"personality": "Flamboyant, precise, mysterious",
		"backstory": "An eccentric jeweler who arrived in Hearthhaven two years ago claiming to be from 'beyond the Wastes.' He crafts enchanted accessories that provide passive bonuses. His true origins are tied to the Rifts, and his storyline reveals he's searching for a way home.",
		"home_location": "jeweler_shop_upstairs",
		"work_location": "jeweler_shop",
		"favorite_gifts": ["ethereal_token", "rare_gem", "void_crystal"],
		"disliked_gifts": ["plain_stone", "cheap_ring"],
		"birthday_season": "Fall",
		"birthday_day": 13,
		"schedule": {"8": "jeweler_shop", "12": "market_square", "14": "jeweler_shop", "19": "clock_tower", "22": "jeweler_shop_upstairs"},
		"quest_chain": ["jasper_gems", "jasper_enchanting", "jasper_homeward"]
	})

	_add_npc("mira", {
		"display_name": "Mira",
		"age": 29,
		"occupation": "Animal Rancher",
		"personality": "Warm, nurturing, stubborn",
		"backstory": "Runs the ranch on the south side of Hearthhaven, raising livestock and caring for animals. She has a special bond with creatures, including rift-touched ones. Her questline involves taming a wild rift beast and establishing a sanctuary for displaced magical creatures.",
		"home_location": "ranch_house",
		"work_location": "ranch",
		"favorite_gifts": ["animal_treat", "hay_bale", "golden_egg"],
		"disliked_gifts": ["monster_parts", "traps"],
		"birthday_season": "Spring",
		"birthday_day": 3,
		"schedule": {"5": "ranch", "11": "ranch_house", "13": "ranch", "16": "market_square", "18": "ranch", "21": "ranch_house"},
		"quest_chain": ["mira_animals", "mira_rift_beast", "mira_sanctuary"]
	})

	_add_npc("cedric", {
		"display_name": "Cedric",
		"age": 48,
		"occupation": "Schoolteacher",
		"personality": "Patient, intellectual, nostalgic",
		"backstory": "Hearthhaven's schoolteacher who educates the town's children and anyone willing to learn. He was once a scholar at a great university before choosing the quiet valley life. His lessons provide skill bonuses and his questline involves recovering lost educational texts from dungeon ruins.",
		"home_location": "schoolhouse_upstairs",
		"work_location": "schoolhouse",
		"favorite_gifts": ["rare_book", "writing_quill", "globe"],
		"disliked_gifts": ["weapons", "loud_items"],
		"birthday_season": "Summer",
		"birthday_day": 1,
		"schedule": {"7": "schoolhouse", "12": "park", "13": "schoolhouse", "16": "library", "19": "tavern", "22": "schoolhouse_upstairs"},
		"quest_chain": ["cedric_lessons", "cedric_texts", "cedric_academy"]
	})

	_add_npc("nell", {
		"display_name": "Nell",
		"age": 24,
		"occupation": "Courier / Messenger",
		"personality": "Energetic, nosy, brave",
		"backstory": "The fastest runner in Hearthhaven, Nell delivers mail and messages across the valley. She often ventures near dangerous Rift zones for deliveries. Her energy and curiosity make her a natural explorer. Her questline involves establishing safe courier routes through rift territory.",
		"home_location": "courier_office",
		"work_location": "courier_office",
		"favorite_gifts": ["running_boots", "stamina_potion", "map"],
		"disliked_gifts": ["heavy_armor", "anchors"],
		"birthday_season": "Fall",
		"birthday_day": 25,
		"schedule": {"6": "courier_office", "7": "market_square", "9": "valley_patrol", "12": "tavern", "14": "valley_patrol", "18": "courier_office"},
		"quest_chain": ["nell_deliveries", "nell_routes", "nell_rift_mail"]
	})

	_add_npc("greta", {
		"display_name": "Greta",
		"age": 65,
		"occupation": "Head Baker",
		"personality": "Stern, perfectionist, secretly kind",
		"backstory": "The master baker of Hearthhaven who has run the bakery for 40 years. She's Clara's demanding mentor. Beneath her stern exterior, she deeply cares about the town's wellbeing. Her signature festival cakes are legendary. Her questline involves passing down family recipes with magical properties.",
		"home_location": "bakery_upstairs",
		"work_location": "bakery",
		"favorite_gifts": ["rare_flour", "honey", "butter"],
		"disliked_gifts": ["store_bought_cake", "shortcuts"],
		"birthday_season": "Winter",
		"birthday_day": 8,
		"schedule": {"4": "bakery", "12": "market_square", "14": "bakery", "18": "bakery_upstairs"},
		"quest_chain": ["greta_standards", "greta_recipes", "greta_legacy"]
	})

	_add_npc("felix", {
		"display_name": "Felix",
		"age": 20,
		"occupation": "Musician / Bard",
		"personality": "Charming, restless, talented",
		"backstory": "A traveling bard who fell in love with Hearthhaven and decided to stay. He plays at the tavern most evenings and composes songs about the town's history. His music has an unexplained effect on Rift activity, calming nearby disturbances. His questline explores the connection between music and Rift energy.",
		"home_location": "tavern_upstairs",
		"work_location": "tavern",
		"favorite_gifts": ["instrument_strings", "song_sheet", "rare_wood"],
		"disliked_gifts": ["earplugs", "silence_potion"],
		"birthday_season": "Summer",
		"birthday_day": 15,
		"schedule": {"9": "tavern_upstairs", "11": "park", "14": "market_square", "17": "tavern", "23": "tavern_upstairs"},
		"quest_chain": ["felix_songs", "felix_rift_melody", "felix_symphony"]
	})

	_add_npc("vivian", {
		"display_name": "Vivian",
		"age": 36,
		"occupation": "Tailor / Fashion Designer",
		"personality": "Glamorous, creative, competitive",
		"backstory": "Hearthhaven's tailor who designs both everyday clothing and specialized gear outfits. She came from the city seeking inspiration and found it in the valley's magical materials. She crafts the visual appearance of both Farm and Dungeon gear sets. Her questline involves creating a legendary outfit from rift-touched fabrics.",
		"home_location": "tailor_shop_upstairs",
		"work_location": "tailor_shop",
		"favorite_gifts": ["silk_thread", "rift_fabric", "fashion_magazine"],
		"disliked_gifts": ["torn_clothes", "mud"],
		"birthday_season": "Spring",
		"birthday_day": 17,
		"schedule": {"7": "tailor_shop", "12": "market_square", "14": "tailor_shop", "18": "tavern", "21": "tailor_shop_upstairs"},
		"quest_chain": ["vivian_fabrics", "vivian_designs", "vivian_masterwork"]
	})

	_add_npc("hank", {
		"display_name": "Hank",
		"age": 55,
		"occupation": "Stable Master",
		"personality": "Gruff, dependable, animal-loving",
		"backstory": "Manages the town stables and provides transportation services. A former cavalry soldier, Hank found peace in Hearthhaven. He knows every trail in the valley and his horses can sense Rift disturbances. His questline involves training a rift-touched mount.",
		"home_location": "stables",
		"work_location": "stables",
		"favorite_gifts": ["horse_treat", "saddle_oil", "carrot"],
		"disliked_gifts": ["spurs", "whip"],
		"birthday_season": "Fall",
		"birthday_day": 10,
		"schedule": {"5": "stables", "12": "tavern", "14": "stables", "19": "stables"},
		"quest_chain": ["hank_horses", "hank_trails", "hank_rift_mount"]
	})

	_add_npc("owen", {
		"display_name": "Owen",
		"age": 16,
		"occupation": "Student / Aspiring Adventurer",
		"personality": "Eager, reckless, good-hearted",
		"backstory": "The youngest aspiring adventurer in Hearthhaven who idolizes dungeon delvers. Despite his age, he's surprisingly resourceful. His questline involves mentoring him safely and discovering he has a natural ability to sense Rift energy, making him crucial to the valley's future.",
		"home_location": "owen_house",
		"work_location": "schoolhouse",
		"favorite_gifts": ["adventure_book", "wooden_sword", "dungeon_map"],
		"disliked_gifts": ["homework", "vegetables"],
		"birthday_season": "Summer",
		"birthday_day": 27,
		"schedule": {"7": "schoolhouse", "12": "market_square", "14": "training_grounds", "17": "river_bank", "19": "owen_house"},
		"quest_chain": ["owen_training", "owen_first_dungeon", "owen_gift"]
	})

	_add_npc("agatha", {
		"display_name": "Agatha",
		"age": 70,
		"occupation": "Retired / Town Elder",
		"personality": "Sharp-minded, traditional, storyteller",
		"backstory": "The oldest resident of Hearthhaven and a living repository of the town's oral history. She sits on the town council and her stories contain hidden truths about the Rifts. Her questline involves piecing together her memories to create a complete chronicle of Aethelgard's founding.",
		"home_location": "agatha_cottage",
		"work_location": "town_hall",
		"favorite_gifts": ["tea", "knitting_yarn", "old_photograph"],
		"disliked_gifts": ["loud_items", "spicy_food"],
		"birthday_season": "Winter",
		"birthday_day": 12,
		"schedule": {"7": "agatha_cottage", "10": "town_hall", "12": "park", "15": "agatha_cottage", "17": "clock_tower", "19": "agatha_cottage"},
		"quest_chain": ["agatha_stories", "agatha_memories", "agatha_chronicle"]
	})

	_add_npc("dax", {
		"display_name": "Dax",
		"age": 27,
		"occupation": "Tinkerer / Inventor",
		"personality": "Scattered, brilliant, enthusiastic",
		"backstory": "A self-taught inventor who builds gadgets from scrap and Rift-touched materials. His workshop is a chaotic mess of half-finished contraptions. Some of his inventions are incredibly useful for farming and dungeon exploration. His questline involves completing his masterwork: a Rift-detection device.",
		"home_location": "tinkerer_workshop",
		"work_location": "tinkerer_workshop",
		"favorite_gifts": ["gears", "rift_crystal", "copper_wire"],
		"disliked_gifts": ["instruction_manual", "organized_things"],
		"birthday_season": "Spring",
		"birthday_day": 11,
		"schedule": {"8": "tinkerer_workshop", "12": "junkyard", "15": "tinkerer_workshop", "19": "tavern", "22": "tinkerer_workshop"},
		"quest_chain": ["dax_parts", "dax_prototype", "dax_detector"]
	})

	_add_npc("lena", {
		"display_name": "Lena",
		"age": 31,
		"occupation": "Alchemist",
		"personality": "Methodical, curious, dry humor",
		"backstory": "Runs a small alchemy shop where she brews potions, elixirs, and experimental concoctions. She studies the chemical properties of Rift-touched materials with scientific rigor. Her potions are essential for dungeon survival. Her questline involves synthesizing a stabilization compound for the Rifts.",
		"home_location": "alchemy_shop_upstairs",
		"work_location": "alchemy_shop",
		"favorite_gifts": ["rare_mushroom", "void_essence", "crystal_vial"],
		"disliked_gifts": ["unscientific_claims", "lucky_charms"],
		"birthday_season": "Fall",
		"birthday_day": 5,
		"schedule": {"7": "alchemy_shop", "12": "forest_edge", "14": "alchemy_shop", "18": "library", "21": "alchemy_shop_upstairs"},
		"quest_chain": ["lena_ingredients", "lena_experiments", "lena_stabilizer"]
	})

	_add_npc("bram", {
		"display_name": "Bram",
		"age": 44,
		"occupation": "Farmer (Veteran)",
		"personality": "Weathered, wise, mentoring",
		"backstory": "A veteran farmer who's been working the land longer than most residents have lived in Hearthhaven. He serves as an informal mentor to new farmers. He understands rift-touched soil better than anyone and can teach advanced farming techniques. His questline involves restoring ancient farmland corrupted by Rift energy.",
		"home_location": "bram_farmhouse",
		"work_location": "bram_farm",
		"favorite_gifts": ["quality_seeds", "fertilizer", "almanac"],
		"disliked_gifts": ["shortcuts", "processed_food"],
		"birthday_season": "Summer",
		"birthday_day": 8,
		"schedule": {"5": "bram_farm", "12": "bram_farmhouse", "14": "bram_farm", "18": "tavern", "21": "bram_farmhouse"},
		"quest_chain": ["bram_lessons", "bram_restoration", "bram_legacy_fields"]
	})

	_add_npc("wren", {
		"display_name": "Wren",
		"age": 23,
		"occupation": "Cartographer / Explorer",
		"personality": "Quiet, observant, wanderlust",
		"backstory": "A young cartographer mapping the ever-shifting Rift zones around the valley. Her maps are essential for navigating the changing landscape. She dreams of charting the entire world beyond the Wastes. Her questline involves discovering new areas as Rifts reveal hidden regions.",
		"home_location": "cartographer_office",
		"work_location": "cartographer_office",
		"favorite_gifts": ["blank_map", "compass", "ink_pot"],
		"disliked_gifts": ["staying_put", "chains"],
		"birthday_season": "Winter",
		"birthday_day": 6,
		"schedule": {"7": "cartographer_office", "9": "valley_patrol", "13": "cartographer_office", "15": "echo_ridge_base", "19": "tavern", "22": "cartographer_office"},
		"quest_chain": ["wren_survey", "wren_rift_maps", "wren_beyond"]
	})

	_add_npc("tobias", {
		"display_name": "Tobias",
		"age": 60,
		"occupation": "Priest / Spiritual Leader",
		"personality": "Serene, philosophical, conflicted",
		"backstory": "The spiritual leader of Hearthhaven's small chapel. He tends to the community's spiritual needs and performs seasonal blessing ceremonies. The Rifts challenge his beliefs, and his questline involves reconciling faith with the reality of magical phenomena.",
		"home_location": "chapel_quarters",
		"work_location": "chapel",
		"favorite_gifts": ["candles", "incense", "holy_water"],
		"disliked_gifts": ["void_essence", "dark_artifacts"],
		"birthday_season": "Spring",
		"birthday_day": 1,
		"schedule": {"6": "chapel", "12": "park", "14": "chapel", "17": "cemetery", "19": "chapel_quarters"},
		"quest_chain": ["tobias_blessings", "tobias_faith", "tobias_revelation"]
	})

	_add_npc("sylvie", {
		"display_name": "Sylvie",
		"age": 33,
		"occupation": "Beekeeper / Chandler",
		"personality": "Calm, nature-loving, observant",
		"backstory": "Manages several beehives around the valley and crafts candles and wax products. Her bees behave strangely near Rift zones, acting as natural Rift detectors. She provides honey and wax resources essential for crafting. Her questline involves following her bees to discover a hidden Rift-touched hive.",
		"home_location": "sylvie_cottage",
		"work_location": "apiary",
		"favorite_gifts": ["rare_flower", "beeswax", "pollen"],
		"disliked_gifts": ["pesticide", "smoke_bomb"],
		"birthday_season": "Summer",
		"birthday_day": 20,
		"schedule": {"6": "apiary", "11": "sylvie_cottage", "13": "flower_shop", "15": "apiary", "19": "sylvie_cottage"},
		"quest_chain": ["sylvie_honey", "sylvie_bees", "sylvie_rift_hive"]
	})

	_add_npc("duncan", {
		"display_name": "Duncan",
		"age": 38,
		"occupation": "Lumberjack",
		"personality": "Strong, simple, dependable",
		"backstory": "Hearthhaven's primary woodsman who harvests timber from the forests near Echo Ridge. He's witnessed strange things in the deep woods and provides hardwood for construction. His questline involves clearing a path through a Rift-corrupted forest to reach an ancient grove.",
		"home_location": "lumber_cabin",
		"work_location": "lumber_yard",
		"favorite_gifts": ["axe_upgrade", "maple_syrup", "pine_resin"],
		"disliked_gifts": ["plastic", "city_clothes"],
		"birthday_season": "Fall",
		"birthday_day": 16,
		"schedule": {"5": "lumber_yard", "12": "lumber_cabin", "14": "forest_edge", "18": "tavern", "21": "lumber_cabin"},
		"quest_chain": ["duncan_timber", "duncan_deep_forest", "duncan_grove"]
	})

	_add_npc("mae", {
		"display_name": "Mae",
		"age": 28,
		"occupation": "Cook / Chef",
		"personality": "Passionate, competitive, generous",
		"backstory": "The head cook at the tavern who dreams of creating dishes using ingredients from every region of Aethelgard. She competes fiercely with Greta over whose food is better. Her dishes provide temporary stat buffs for dungeon delving. Her questline involves a cooking competition that brings the town together.",
		"home_location": "tavern_upstairs",
		"work_location": "tavern",
		"favorite_gifts": ["exotic_spice", "rare_fish", "truffle"],
		"disliked_gifts": ["bland_food", "instant_meals"],
		"birthday_season": "Winter",
		"birthday_day": 18,
		"schedule": {"7": "market_square", "9": "tavern", "15": "tavern_upstairs", "17": "tavern", "23": "tavern_upstairs"},
		"quest_chain": ["mae_ingredients", "mae_competition", "mae_feast"]
	})

	_add_npc("reed", {
		"display_name": "Reed",
		"age": 50,
		"occupation": "Retired Adventurer / Historian",
		"personality": "Grizzled, cautious, knowledgeable",
		"backstory": "A retired adventurer who settled in Hearthhaven after decades of dungeon delving. He lost his adventuring party to a Mythic Rift years ago and now serves as an informal advisor to new explorers. His vast dungeon knowledge provides tips and dungeon-specific strategies. His questline involves finding closure for his lost companions.",
		"home_location": "reed_cottage",
		"work_location": "tavern",
		"favorite_gifts": ["old_map", "dungeon_artifact", "aged_spirits"],
		"disliked_gifts": ["recklessness", "cheap_gear"],
		"birthday_season": "Winter",
		"birthday_day": 25,
		"schedule": {"8": "reed_cottage", "10": "tavern", "14": "library", "17": "guard_post", "20": "reed_cottage"},
		"quest_chain": ["reed_advice", "reed_companions", "reed_closure"]
	})

	_add_npc("penny", {
		"display_name": "Penny",
		"age": 21,
		"occupation": "Postal Worker / Shopkeeper",
		"personality": "Organized, helpful, shy",
		"backstory": "Helps run the general store with Garrick and manages the town's small post office. She has an encyclopedic memory for everyone's orders and preferences. She secretly writes adventure novels based on overheard tavern tales. Her questline involves finding the courage to share her writing.",
		"home_location": "general_store_upstairs",
		"work_location": "general_store",
		"favorite_gifts": ["stationery", "ink_pot", "novel"],
		"disliked_gifts": ["criticism", "loud_items"],
		"birthday_season": "Spring",
		"birthday_day": 28,
		"schedule": {"7": "general_store", "12": "courier_office", "14": "general_store", "18": "library", "21": "general_store_upstairs"},
		"quest_chain": ["penny_orders", "penny_writing", "penny_published"]
	})


func _add_npc(npc_id: String, data: Dictionary):
	data["npc_id"] = npc_id
	data["friendship_level"] = 0
	data["friendship_points"] = 0
	citizens[npc_id] = data
