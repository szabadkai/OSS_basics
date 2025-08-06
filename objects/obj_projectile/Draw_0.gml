// Draw projectile with trail effect
draw_set_color(color);

// Draw trail
for (var i = 0; i < array_length(trail_positions); i++) {
    var trail_alpha = (1.0 - (i / trail_length)) * 0.6;
    var trail_size = 3 - (i * 0.8);
    
    draw_set_alpha(trail_alpha);
    draw_circle(trail_positions[i][0], trail_positions[i][1], trail_size, false);
}

// Draw main projectile based on type
draw_set_alpha(1.0);
switch (projectile_type) {
    case "laser":
        draw_circle(x, y, 4, false);
        break;
        
    case "missile":
        // Draw missile shape
        draw_set_color(c_orange);
        draw_circle(x, y, 3, false);
        draw_set_color(c_red);
        draw_circle(x, y, 2, false);
        break;
        
    case "rail":
        // Draw rail gun beam
        draw_set_color(c_aqua);
        var beam_length = 12;
        var end_x = x + lengthdir_x(beam_length, image_angle);
        var end_y = y + lengthdir_y(beam_length, image_angle);
        draw_line_width(x, y, end_x, end_y, 3);
        break;
        
    case "shotgun":
        // Draw shotgun pellet
        draw_set_color(c_orange);
        draw_circle(x, y, 2, false);
        break;
        
    default:
        draw_circle(x, y, 3, false);
        break;
}

// Reset drawing properties
draw_set_alpha(1.0);
draw_set_color(c_white);