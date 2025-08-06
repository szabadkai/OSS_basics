// Draw floating damage text in world coordinates
if (damage_value > 0) {
    // Set drawing properties
    draw_set_alpha(alpha);
    draw_set_color(color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(-1);
    
    // Draw damage text with scaling at exact world position
    var text = string(damage_value);
    if (is_crit) {
        text = "CRIT! " + text;
    }
    
    draw_text_transformed(x, y, text, scale, scale, 0);
    
    // Reset drawing properties
    draw_set_alpha(1.0);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}