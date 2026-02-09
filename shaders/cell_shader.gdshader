shader_type canvas_item;
/// Cell Shader - Creates a toon/cel-shaded look for 2D sprites.

uniform float color_steps : hint_range(2.0, 8.0, 1.0) = 4.0;
uniform float outline_thickness : hint_range(0.0, 5.0) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Quantize colors to create cel-shading bands
	vec3 quantized = floor(tex_color.rgb * color_steps) / color_steps;

	// Simple outline detection using alpha channel
	float alpha = tex_color.a;
	float outline = 0.0;

	if (outline_thickness > 0.0) {
		vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;

		float a_up = texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
		float a_down = texture(TEXTURE, UV + vec2(0.0, size.y)).a;
		float a_left = texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
		float a_right = texture(TEXTURE, UV + vec2(size.x, 0.0)).a;

		outline = step(0.5, alpha) * (1.0 - step(0.5, min(min(a_up, a_down), min(a_left, a_right))));
	}

	COLOR.rgb = mix(quantized, outline_color.rgb, outline);
	COLOR.a = max(alpha, outline * outline_color.a);
}
