shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
uniform float dim_amount : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec3 blurred = textureLod(screen_tex, SCREEN_UV, blur_amount).rgb;
	COLOR = vec4(mix(blurred, vec3(0.0, 0.0, 0.06), dim_amount), 1.0);
}