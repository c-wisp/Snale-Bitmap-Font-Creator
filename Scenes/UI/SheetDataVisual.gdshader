shader_type canvas_item;
//creates lines in a grid based on the amount of rows and columns given
//TODO: edit the margin's starting point to be the bottom-right rather than top-left

uniform int rows = 1;
uniform int columns = 1;
uniform vec2 margins = vec2(0,0);
uniform vec2 sprite_size = vec2(64,64);

const vec3 BORDER_COLOR = vec3(0.25,0.5,0.85);
const vec3 MARGIN_COLOR = vec3(0.8,0.1,0.5);

void fragment() {
	vec2 current_pixel = floor(UV*sprite_size);
	vec2 relative_pos = vec2(mod(current_pixel.x,sprite_size.x/float(rows)),mod(current_pixel.y,sprite_size.y/float(columns)));
	vec2 margin_offset = floor(margins/2.0);//allows the margins to split in two even spaces
	
	//topleft + bottomright corners are calc'd so the lines are double thick
	//center_fix is used to fix the lines that cross over the center part (when the sprite has a fractional row size)
	float center_fix = step(abs(sprite_size.y/2.0 - current_pixel.y),0.01)*step(mod(float(rows),2),0.99);
	float rowTg = step(mod(current_pixel.y,sprite_size.y/float(rows)),0.99)+center_fix;
	rowTg += step(sprite_size.y/float(rows)-1.0,mod(current_pixel.y,sprite_size.y/float(rows)));
	
	center_fix = step(abs(sprite_size.x/2.0 - current_pixel.x),0.01)*step(mod(float(columns),2),0.99);
	float columnTg = step(mod(current_pixel.x,sprite_size.x/float(columns)),0.99)+center_fix;
	columnTg += step(sprite_size.x/float(columns)-1.0,mod(current_pixel.x,sprite_size.x/float(columns)));
	
	
	//Margins Ahead !
	//bottom right first
	float marginTg = step(sprite_size.x/float(columns)-1.0,mod(current_pixel.x,sprite_size.x/float(columns))+margins.x-1.0-margin_offset.x);
	marginTg += step(sprite_size.y/float(rows)-1.0,mod(current_pixel.y,sprite_size.y/float(rows))+margins.y-1.0-margin_offset.y);
	//then topleft
	marginTg += step(relative_pos.x-mod(margins.y-1.0,2.0)+1.0, margins.x-margin_offset.x-1.0);
	marginTg += step(relative_pos.y-mod(margins.y-1.0,2.0)+1.0, margins.y-margin_offset.y-1.0);
	
	//add back the blue ! !!
	//basically the same as above block, just offset by 1px
	float marginBorderTg = step(sprite_size.x/float(columns)-1.0,mod(current_pixel.x,sprite_size.x/float(columns))+margins.x-margin_offset.x);
	marginBorderTg += step(sprite_size.y/float(rows)-1.0,mod(current_pixel.y,sprite_size.y/float(rows))+margins.y-margin_offset.y);
	
	marginBorderTg += step(relative_pos.x-mod(margins.x-1.0,2.0)+1.0, margins.x-margin_offset.x);
	marginBorderTg += step(relative_pos.y-mod(margins.y-1.0,2.0)+1.0, margins.y-margin_offset.y);
	
	marginBorderTg *= 1.0-min(marginTg,1.0); //disables when overlapping margins
	
	
	//Final Application
	//float apply_margins = min(step(0.99,margins.x)+step(0.99,margins.y),1.0);
	//COLOR.rgb = mix(MARGIN_COLOR,BORDER_COLOR,(min(vec3(marginBorderTg),1.0)));
	//COLOR.rgb = mix(BORDER_COLOR,COLOR.rgb,apply_margins);
	//COLOR.a = mix(0.6*min(rowTg+columnTg,1.0),0.6*min(marginTg+marginBorderTg,1.0),apply_margins);
}
