extends RefCounted
## NoiseGenerator - Provides layered noise functions for procedural terrain generation.
## Uses Godot's built-in FastNoiseLite for Simplex/Perlin noise, inspired by
## techniques from Necesse (layered noise maps) and Core Keeper (radial biome zones).
##
## Generates height, moisture, and temperature maps used by the world generator
## to determine biome placement, terrain features, and resource distribution.

## Noise instances for different map layers
var height_noise: FastNoiseLite
var moisture_noise: FastNoiseLite
var temperature_noise: FastNoiseLite
var cave_noise: FastNoiseLite
var detail_noise: FastNoiseLite

## The world seed that drives all generation
var world_seed: int = 0


func _init(seed_value: int = 0) -> void:
	world_seed = seed_value
	_setup_noise_layers()


func _setup_noise_layers() -> void:
	# Height noise - broad terrain elevation (low frequency, high amplitude)
	height_noise = FastNoiseLite.new()
	height_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	height_noise.seed = world_seed
	height_noise.frequency = 0.008
	height_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	height_noise.fractal_octaves = 4
	height_noise.fractal_lacunarity = 2.0
	height_noise.fractal_gain = 0.5

	# Moisture noise - rainfall/water distribution (offset seed for variety)
	moisture_noise = FastNoiseLite.new()
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	moisture_noise.seed = world_seed + 1000
	moisture_noise.frequency = 0.006
	moisture_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	moisture_noise.fractal_octaves = 3
	moisture_noise.fractal_lacunarity = 2.0
	moisture_noise.fractal_gain = 0.5

	# Temperature noise - heat distribution (offset seed)
	temperature_noise = FastNoiseLite.new()
	temperature_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	temperature_noise.seed = world_seed + 2000
	temperature_noise.frequency = 0.005
	temperature_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	temperature_noise.fractal_octaves = 3
	temperature_noise.fractal_lacunarity = 2.0
	temperature_noise.fractal_gain = 0.5

	# Cave noise - tunnel/cave system carving (higher frequency for detail)
	cave_noise = FastNoiseLite.new()
	cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	cave_noise.seed = world_seed + 3000
	cave_noise.frequency = 0.04
	cave_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	cave_noise.fractal_octaves = 2
	cave_noise.fractal_lacunarity = 2.0
	cave_noise.fractal_gain = 0.5

	# Detail noise - small features like rocks, flowers, bushes
	detail_noise = FastNoiseLite.new()
	detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	detail_noise.seed = world_seed + 4000
	detail_noise.frequency = 0.1
	detail_noise.fractal_type = FastNoiseLite.FRACTAL_NONE


func get_height(x: int, y: int) -> float:
	## Returns normalized height value [0.0, 1.0] at the given tile position.
	return (height_noise.get_noise_2d(x, y) + 1.0) * 0.5


func get_moisture(x: int, y: int) -> float:
	## Returns normalized moisture value [0.0, 1.0] at the given tile position.
	return (moisture_noise.get_noise_2d(x, y) + 1.0) * 0.5


func get_temperature(x: int, y: int) -> float:
	## Returns normalized temperature value [0.0, 1.0] at the given tile position.
	return (temperature_noise.get_noise_2d(x, y) + 1.0) * 0.5


func get_cave_value(x: int, y: int) -> float:
	## Returns cave carving value. Values near 0.0 indicate tunnel/cave areas.
	return absf(cave_noise.get_noise_2d(x, y))


func get_detail(x: int, y: int) -> float:
	## Returns fine detail noise [0.0, 1.0] for placing small objects.
	return (detail_noise.get_noise_2d(x, y) + 1.0) * 0.5


func is_cave(x: int, y: int, threshold: float = 0.08) -> bool:
	## Returns true if this position should be carved into a cave/tunnel.
	## Uses a "Swiss cheese" approach similar to Core Keeper's cave networks.
	return get_cave_value(x, y) < threshold


func get_river_value(x: int, y: int) -> float:
	## Returns a value for river placement. Values near 0.0 indicate river paths.
	## Uses the moisture noise with higher frequency to create winding rivers.
	var river_noise := FastNoiseLite.new()
	river_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	river_noise.seed = world_seed + 5000
	river_noise.frequency = 0.015
	river_noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	river_noise.fractal_octaves = 3
	return absf(river_noise.get_noise_2d(x, y))


func tile_hash(x: int, y: int) -> int:
	## Deterministic hash for consistent pseudo-random placement.
	## Matches the approach used in WorldGenerator.gd.
	var h := x * 374761393 + y * 668265263
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	return absi(h)
