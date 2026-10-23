
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture,
filter_linear;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec2 pixel = SCREEN_PIXEL_SIZE * blur_amount;
    vec4 color = texture(screen_texture, SCREEN_UV) * 0.4;

    color += texture(screen_texture, SCREEN_UV + vec2(pixel.x, 0.0)) * 0.15;
    color += texture(screen_texture, SCREEN_UV - vec2(pixel.x, 0.0)) * 0.15;
    color += texture(screen_texture, SCREEN_UV + vec2(0.0, pixel.y)) * 0.15;
    color += texture(screen_texture, SCREEN_UV - vec2(0.0, pixel.y)) * 0.15;

    COLOR = color;
}
