// Fighter Enemy - Fast, agile, low HP enemy
is_myturn = false;

// Fighter stats: Fast and agile but fragile
moves_max = 2;  // Can move 2 tiles per turn
moves = 2;
hp_max = 1;     // Dies in 1 hit
hp = 1;
damage = 1;     // Standard damage
init = 15;      // High initiative - acts early
grid_size = global.grid_size;
enemy_type = "fighter";

// Animation variables
is_animating = false; 
move_start_x = 0;
move_start_y = 0;
move_target_x = 0;
move_target_y = 0;
move_timer = 0;
move_duration = 0.15; // Faster animations for agile fighter

// Damage animation variables
is_hurt = false;
hurt_timer = 0;
hurt_duration = 0.1; // Quick hurt animation
original_image_blend = c_white;
is_dying = false;

// Fighter-specific behavior: Aggressive pursuit
// Tries to close distance quickly and attack
ai_behavior = "aggressive";
preferred_range = 1; // Wants to be adjacent to player

// Take damage function with hurt animation and critical hit support
take_damage = function(damage_amount, is_critical = false) {
    hp -= damage_amount;
    
    // Create floating damage text
    create_damage_text(x, y - 16, damage_amount, is_critical);
    
    // Start hurt animation with different colors for crits
    is_hurt = true;
    hurt_timer = 0;
    image_blend = is_critical ? c_yellow : c_red; // Yellow flash for crits, red for normal
    
    if (is_critical) {
        show_debug_message("Fighter took CRITICAL " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    } else {
        show_debug_message("Fighter took " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    }
    
    // Check if enemy should die
    if (hp <= 0) {
        is_dying = true;
        show_debug_message("Fighter destroyed - playing hurt animation first");
        return true;
    }
    
    return false;
};

// Snap to grid on creation
snap_to_grid();