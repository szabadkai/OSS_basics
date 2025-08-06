draw_self();

// Draw HP dots above fighter (same as standard enemy for now)
var dot_size = 3;
var dot_spacing = 5;
var total_width = (hp_max - 1) * dot_spacing + dot_size;
var start_x = x - total_width/2;
var dot_y = y - sprite_height/2 - 8;

for (var i = 0; i < hp_max; i++) {
    var dot_x = start_x + i * dot_spacing;
    
    if (i < hp) {
        // Fighter HP dot - bright orange to distinguish from regular enemies
        draw_set_color(c_orange);
        draw_circle(dot_x, dot_y, dot_size/2, false);
    } else {
        // Damaged HP dot - gray silhouette
        draw_set_color(c_gray);
        draw_circle(dot_x, dot_y, dot_size/2, true);
    }
}