draw_self();

// Draw health bar above enemy
var bar_width = 48;
var bar_height = 6;
var bar_x = x - bar_width/2;
var bar_y = y - sprite_height/2 - 12;

// Background
draw_set_color(c_red);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

// Health
draw_set_color(c_green);
var health_width = (hp / hp_max) * bar_width;
draw_rectangle(bar_x, bar_y, bar_x + health_width, bar_y + bar_height, false);

// Border
draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);

