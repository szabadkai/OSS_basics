// Draw the planet
draw_self();

// Initialize visited flag if it doesn't exist (for existing planets)
if (!variable_instance_exists(id, "visited")) {
    visited = false;
}

// Draw planet status indicator
if (visited) {
    // Draw "visited" indicator - grayed out with checkmark
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(x - 8, y - 8, x + 24, y + 24, false);
    draw_set_alpha(1);
    
    // Draw checkmark to show visited
    draw_set_color(c_lime);
    draw_line_width(x - 2, y + 4, x + 4, y + 10, 3);
    draw_line_width(x + 4, y + 10, x + 12, y - 2, 3);
} else {
    // Draw "available" indicator - small exclamation mark
    draw_set_color(c_yellow);
    draw_circle(x + 12, y - 8, 3, false);
    draw_set_color(c_black);
    draw_text(x + 10, y - 12, "!");
}

draw_set_color(c_white);