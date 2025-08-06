// Draw thruster effect as a simple shape
draw_set_color(color);
draw_set_alpha(alpha);

// Draw as a circle or use sprite if available
var effect_size = 2 * image_xscale;
draw_circle(x, y, effect_size, false);

// Reset drawing properties
draw_set_alpha(1.0);
draw_set_color(c_white);