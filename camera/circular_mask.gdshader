shader_type canvas_item;

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float distance_from_center = length(centered_uv);

    if (distance_from_center > 0.5) {
        discard;
    }

    COLOR = texture(TEXTURE, UV);
}