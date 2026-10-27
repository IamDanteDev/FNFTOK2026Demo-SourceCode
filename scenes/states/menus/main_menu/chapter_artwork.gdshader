shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float alpha : hint_range(0.0, 1.0);
uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0.0,1.0);

vec4 linear_burn (vec4 base, vec4 blend)
{
	return base + blend - 1.0;
}

vec4 shillouette (vec4 base, vec4 blend)
{
	return vec4(0.650,0.460,0.370, alpha);
}


void fragment() {
vec4 SCREEN_COLOR = texture(SCREEN_TEXTURE, SCREEN_UV).rgba;

vec4 main_texture = texture(TEXTURE, UV);
vec4 noise_texture = texture(dissolve_texture, UV);
main_texture.a *= floor(dissolve_value + min(1, noise_texture.x));

COLOR = shillouette(COLOR,SCREEN_COLOR);
COLOR.a *= main_texture.a;

}
