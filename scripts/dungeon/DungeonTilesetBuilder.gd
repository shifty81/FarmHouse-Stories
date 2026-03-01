extends RefCounted
## DungeonTilesetBuilder - Builds TileSets for dungeon rooms
## using the cave.png tileset (16x16 tiles).
## Provides atlas coordinate constants and collision setup
## for cave/dungeon room layouts.

## Atlas source IDs
const CAVE_SOURCE: int = 0

## cave.png atlas coordinates for dungeon tiles
const FLOOR_CENTER := Vector2i(4, 4)
const FLOOR_ALT := Vector2i(5, 4)

const WALL_TOP := Vector2i(4, 0)
const WALL_LEFT := Vector2i(0, 4)
const WALL_RIGHT := Vector2i(9, 4)
const WALL_BOTTOM := Vector2i(4, 9)
const WALL_TL := Vector2i(0, 0)
const WALL_TR := Vector2i(9, 0)
const WALL_BL := Vector2i(0, 9)
const WALL_BR := Vector2i(9, 9)

const DOOR_H := Vector2i(4, 2)
const DOOR_V := Vector2i(2, 4)

const ROCK := Vector2i(7, 6)
const CHEST := Vector2i(8, 7)
const STAIRS := Vector2i(6, 8)
const TORCH := Vector2i(8, 2)

## Wall tiles that should have collision
const COLLISION_COORDS: Array = [
	Vector2i(4, 0),  # wall top
	Vector2i(0, 4),  # wall left
	Vector2i(9, 4),  # wall right
	Vector2i(4, 9),  # wall bottom
	Vector2i(0, 0),  # corner TL
	Vector2i(9, 0),  # corner TR
	Vector2i(0, 9),  # corner BL
	Vector2i(9, 9),  # corner BR
	Vector2i(7, 6),  # rock
]


static func build_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)

	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)

	var source := TileSetAtlasSource.new()
	var texture := load("res://gfx/cave.png") as Texture2D
	if not texture:
		return tileset

	source.texture = texture
	source.texture_region_size = Vector2i(16, 16)
	tileset.add_source(source, CAVE_SOURCE)

	var tex_size := texture.get_size()
	var cols := int(tex_size.x) / 16
	var rows := int(tex_size.y) / 16
	for x in range(cols):
		for y in range(rows):
			source.create_tile(Vector2i(x, y))

	var rect := PackedVector2Array([
		Vector2(-8, -8), Vector2(8, -8),
		Vector2(8, 8), Vector2(-8, 8)])
	for coords: Vector2i in COLLISION_COORDS:
		if coords.x < cols and coords.y < rows:
			var tile_data: TileData = source.get_tile_data(
				coords, 0)
			if tile_data:
				tile_data.add_collision_polygon(0)
				tile_data.set_collision_polygon_points(
					0, 0, rect)

	return tileset
