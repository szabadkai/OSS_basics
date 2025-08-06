// Heavy Cruiser Enemy - Slow, tanky, high HP enemy
is_myturn = false;

// Heavy Cruiser stats: Slow and tanky
moves_max = 1;  // Moves slowly (same as basic enemy)
moves = 1;
hp_max = 4;     // Much higher HP - takes 4 hits to kill
hp = 4;
damage = 2;     // Higher damage output
init = 5;       // Low initiative - acts late
grid_size = global.grid_size;
enemy_type = "heavy";

// Animation variables
is_animating = false;
move_start_x = 0;
move_start_y = 0;
move_target_x = 0;
move_target_y = 0;
move_timer = 0;
move_duration = 0.3; // Slower animations for heavy cruiser

// Damage animation variables
is_hurt = false;
hurt_timer = 0;
hurt_duration = 0.2; // Longer hurt animation for tanky enemy
original_image_blend = c_white;
is_dying = false;

// Heavy Cruiser specific behavior: Defensive positioning
// Prefers to stay at medium range and use superior firepower
ai_behavior = "defensive";
preferred_range = 2; // Prefers to stay 2 tiles away from player

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
        show_debug_message("Heavy Cruiser took CRITICAL " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    } else {
        show_debug_message("Heavy Cruiser took " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    }
    
    // Check if enemy should die
    if (hp <= 0) {
        is_dying = true;
        show_debug_message("Heavy Cruiser destroyed - playing hurt animation first");
        return true;
    }
    
    return false;
};

// Snap to grid on creation
snap_to_grid();