shader_type canvas_item;
//creates a 1px outline with a relative width congruent to the inputted size
uniform vec2 total_size = vec2(16,16);
uniform float alt_pallete = 0.0; //basically a bool

void fragment() {
	//COLOR.rgb = vec3(0.25,0.5,0.85); //base color
	COLOR.r = 0.25;
	COLOR.g = max(0.5 * (1.0 - alt_pallete), 0.85 * alt_pallete);
	COLOR.b = max(0.85 * (1.0 - alt_pallete), 0.5 * alt_pallete);
	
	vec2 current_pixel = floor(UV*total_size);
	float tl_trigger = step(current_pixel.x,0.99) + step(current_pixel.y,0.99);
	float br_trigger = max(0.0, sign(current_pixel.x-total_size.x+2.0)) + max(0.0, sign(current_pixel.y-total_size.y+2.0));
	
	COLOR.a = min(tl_trigger + br_trigger,1.0) * 0.5; //triggers + color.a
}
