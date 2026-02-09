# Cell Shading Techniques for Godot 4.6

## What is Cell Shading?

Cell shading (also called "toon shading") is a stylized rendering technique that gives assets a flat, cartoon-like appearance with distinct color bands rather than smooth, photo-realistic gradients. This technique creates a hand-drawn, comic book aesthetic that works exceptionally well for indie games.

## Why Cell Shading for FarmHouse Stories?

- **Distinctive Visual Style**: Stand out from other farming games
- **Artistic Appeal**: Achieves a hand-crafted, timeless look
- **Performance**: Often more efficient than complex realistic rendering
- **Flexibility**: Easy to adjust and iterate on the visual style
- **Accessibility**: Clear, readable graphics work well on different displays

## Implementing Cell Shading in Godot 4.6

### Basic 2D Cell Shading Approach

For 2D top-down games like FarmHouse Stories, cell shading is implemented using custom fragment shaders attached to sprites or tilemaps.

### Core Concept: Color Quantization

The fundamental technique is **quantizing** (stepping) color or light values into a limited number of discrete bands instead of smooth gradients.

## Shader Implementation

### Basic Cell Shader for 2D Sprites

```gdshader
shader_type canvas_item;

// Number of color bands (steps)
uniform int color_steps : hint_range(2, 10) = 4;

// Outline color and thickness
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    // Sample the texture
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate grayscale brightness
    float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Quantize the brightness into discrete steps
    float quantized = floor(brightness * float(color_steps)) / float(color_steps);
    
    // Apply quantized brightness back to color
    vec3 cel_color = tex_color.rgb * (quantized / brightness);
    
    // Output the result
    COLOR.rgb = cel_color;
    COLOR.a = tex_color.a;
}
```

### Advanced Cell Shader with Color Preservation

```gdshader
shader_type canvas_item;

uniform int color_steps : hint_range(2, 10) = 4;
uniform float shade_intensity : hint_range(0.0, 1.0) = 0.8;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Preserve hue and saturation, only quantize value
    vec3 hsv = rgb_to_hsv(tex_color.rgb);
    
    // Quantize the value (brightness)
    hsv.z = floor(hsv.z * float(color_steps)) / float(color_steps);
    
    // Convert back to RGB
    vec3 cel_color = hsv_to_rgb(hsv);
    
    // Apply shade intensity
    cel_color = mix(tex_color.rgb, cel_color, shade_intensity);
    
    COLOR.rgb = cel_color;
    COLOR.a = tex_color.a;
}

// Helper functions for HSV conversion
vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
```

### Outline Shader for Toon Effect

```gdshader
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Sample surrounding pixels
    float alpha_sum = 0.0;
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * outline_width;
    
    // 8-directional sampling for outline detection
    alpha_sum += texture(TEXTURE, UV + vec2(-pixel_size.x, -pixel_size.y)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(0.0, -pixel_size.y)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(pixel_size.x, -pixel_size.y)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(-pixel_size.x, pixel_size.y)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(0.0, pixel_size.y)).a;
    alpha_sum += texture(TEXTURE, UV + vec2(pixel_size.x, pixel_size.y)).a;
    
    // If this pixel is transparent but surrounded by opaque pixels, draw outline
    if (tex.a < 0.1 && alpha_sum > 0.1) {
        COLOR = outline_color;
    } else {
        COLOR = tex;
    }
}
```

## Application in Godot

### 1. Creating a Shader Material

1. In Godot Editor, create a new **ShaderMaterial**
2. Click on the ShaderMaterial and create a new **Shader**
3. Copy one of the shader codes above into the shader editor
4. Save the shader with a descriptive name (e.g., `cell_shader.gdshader`)

### 2. Applying to Sprites

```gdscript
# Apply to a Sprite2D node
var sprite = $Sprite2D
var material = ShaderMaterial.new()
material.shader = preload("res://shaders/cell_shader.gdshader")

# Set shader parameters
material.set_shader_parameter("color_steps", 4)
material.set_shader_parameter("shade_intensity", 0.8)

sprite.material = material
```

### 3. Applying to TileMaps

```gdscript
# Apply to entire tilemap
var tilemap = $TileMap
var material = ShaderMaterial.new()
material.shader = preload("res://shaders/cell_shader.gdshader")
tilemap.material = material
```

### 4. Global Post-Processing Approach

For a consistent cell-shaded look across the entire game:

```gdscript
# In your main scene or camera
extends Camera2D

func _ready():
    # Create a CanvasLayer for post-processing
    var canvas_layer = CanvasLayer.new()
    add_child(canvas_layer)
    
    # Add a ColorRect that covers the screen
    var screen_shader = ColorRect.new()
    screen_shader.material = preload("res://shaders/cell_shader_material.tres")
    screen_shader.set_anchors_preset(Control.PRESET_FULL_RECT)
    canvas_layer.add_child(screen_shader)
```

## Performance Considerations

### Optimization Tips

1. **Use Simpler Shaders Where Possible**: Basic color quantization is very efficient
2. **Limit Outline Passes**: Outlines require multiple texture samples; use sparingly
3. **Bake Effects**: For static elements, consider pre-processing with the shader and saving as images
4. **Test on Target Hardware**: Always profile shader performance on your target platform

### When to Use Cell Shading

✅ **Good for:**
- Character sprites
- UI elements
- Important game objects
- Environmental decorations

⚠️ **Use Carefully:**
- Large tilemaps (consider simpler approaches)
- Many simultaneous particle effects
- Mobile platforms (test performance)

## Artistic Tips

### Color Palette Design

When designing assets for cell shading:

1. **Use Distinct Value Ranges**: Ensure your sprites have clear light and dark areas
2. **Limit Color Counts**: Fewer colors work better with quantization
3. **Bold Outlines**: Add black or dark outlines to sprites for better definition
4. **Test Early**: Apply shaders early in asset creation to see how they behave

### Shader Parameter Tuning

- **color_steps (3-5)**: Start with 3-4 steps for a strong toon effect
- **shade_intensity (0.7-1.0)**: Lower values for subtle effects, higher for pronounced
- **outline_thickness (1-2)**: Keep outlines thin for readability

## Learning Resources

### Official Documentation
- [Godot Shading Language](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/index.html)
- [Canvas Item Shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html)

### Video Tutorials
- [Stylized Toon Cell Shading in Godot 4.6 - YouTube](https://www.youtube.com/watch?v=cqPcj1xhrUw)
- [Introduction to Shaders in Godot 4 - Kodeco](https://www.kodeco.com/43354079-introduction-to-shaders-in-godot-4)

### Community Resources
- Godot Shaders - [godotshaders.com](https://godotshaders.com/)
- GDQuest Shader Tutorials
- Godot Discord #shaders channel

## Example Project Setup

```
shaders/
├── cell_shader.gdshader              # Main cell shading shader
├── outline_shader.gdshader           # Outline effect
├── combined_cell_outline.gdshader    # Combined effect
└── materials/
    ├── player_cell_material.tres     # Pre-configured for player
    ├── npc_cell_material.tres        # Pre-configured for NPCs
    └── environment_cell_material.tres # For environment objects
```

## Next Steps

1. **Experiment**: Try different color_steps values (3, 4, 5)
2. **Create Variants**: Make different shader materials for characters vs. environment
3. **Iterate**: Test with actual game art to refine the look
4. **Optimize**: Profile and adjust for performance on target platforms

---

**Related Documentation:**
- `05_ArtStyleGuide.md` - Overall art direction and asset creation
- `06_PerformanceOptimization.md` - Shader performance tips
- `02_GodotResources.md` - General Godot learning resources
