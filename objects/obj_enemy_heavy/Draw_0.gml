draw_self();

// Draw HP dots above heavy cruiser (more dots due to higher HP)
var dot_size = 3;
var dot_spacing = 4; // Closer spacing to fit more dots
var total_width = (hp_max - 1) * dot_spacing + dot_size;
var start_x = x - total_width/2;
var dot_y = y - sprite_height/2 - 8;

for (var i = 0; i < hp_max; i++) {
    var dot_x = start_x + i * dot_spacing;
    
    if (i < hp) {
        // Heavy Cruiser HP dot - blue to distinguish from other enemies
        draw_set_color(c_blue);
        draw_circle(dot_x, dot_y, dot_size/2, false);
    } else {
        // Damaged HP dot - gray silhouette
        draw_set_color(c_gray);
        draw_circle(dot_x, dot_y, dot_size/2, true);
    }
}

// Draw armor plating indicator around the ship for visual distinction
draw_set_color(c_blue);
draw_set_alpha(0.3);
draw_circle(x, y, sprite_width/2 + 2, true);
draw_set_alpha(1.0);
draw_set_color(c_white);