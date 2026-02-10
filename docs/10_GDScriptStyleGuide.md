# GDScript Style Guide

Coding conventions for FarmHouse Stories to keep the codebase consistent and avoid common GDScript pitfalls.

## Type Annotations — Avoid Variant Inference

**Rule:** Never use `:=` when the right-hand side resolves to `Variant` at compile time. Use an explicit type annotation instead.

This happens most often when:

1. **Calling methods on a base-typed variable** — If a variable is typed as `Node`, `RefCounted`, `Object`, or any base class rather than the concrete script, the static analyzer cannot see the method's return type and falls back to `Variant`.
2. **Using `Dictionary.get()`** — `Dictionary.get()` always returns `Variant`.
3. **Iterating an untyped `Array`** — Loop variables from untyped arrays are `Variant`.

### Examples

```gdscript
# ❌ BAD — noise_gen is typed as RefCounted, so get_height() returns Variant
var noise_gen: RefCounted = NoiseGeneratorScript.new(seed)
var height := noise_gen.get_height(wx, wy)        # Variant!

# ✅ GOOD — explicit type annotation
var height: float = noise_gen.get_height(wx, wy)
```

```gdscript
# ❌ BAD — Dictionary.get() returns Variant
var chunk := loaded_chunks.get(chunk_pos, {})

# ✅ GOOD
var chunk: Dictionary = loaded_chunks.get(chunk_pos, {})
```

```gdscript
# ❌ BAD — biome_sys is typed as Node, method return is Variant
var allowed := biome_sys.get_allowed_neighbors(biome_id)

# ✅ GOOD
var allowed: Array = biome_sys.get_allowed_neighbors(biome_id)
```

### When `:=` Is Safe

`:=` is fine when the right-hand side has a known concrete type:

```gdscript
var pos := Vector2i(10, 20)              # Vector2i is concrete
var dx := float(wx - center.x)           # float cast is concrete
var origin := Vector2i(cx * 32, cy * 32) # Vector2i constructor
```

## Naming Conventions

Follow the rules enforced by `gdlintrc` in the project root:

| Kind | Pattern | Example |
|------|---------|---------|
| Class name | `PascalCase` | `ChunkManager` |
| Function name | `snake_case` | `generate_chunk` |
| Variable name | `snake_case` | `world_seed` |
| Constant name | `UPPER_SNAKE` | `CHUNK_SIZE` |
| Signal name | `snake_case` | `chunk_loaded` |
| Enum element | `UPPER_SNAKE` | `TYPE_FISH` |

## File Length

Maximum **1000 lines** per file (enforced by gdlint). If a script grows beyond this, split it into smaller, focused scripts.

## Function Arguments

Maximum **10 arguments** per function. If you need more, group related parameters into a `Dictionary` or a custom `Resource`.

## Linting

Run `gdlint scripts/` before committing to catch style issues early. The `gdlintrc` config at the project root defines all rules.
