shader_type canvas_item;

uniform vec4 tile_color : source_color = vec4(1.0);
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 base = tile_color;
    base.rgb += highlight_strength * vec3(0.3, 0.3, 0.3);
    COLOR = base;
}
