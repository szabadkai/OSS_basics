// Destructible Asteroid - provides cover and can be destroyed
grid_size = global.grid_size;

// Asteroid stats - one-shot destructible
hp_max = 1; // Dies in 1 hit
hp = 1;
is_destroyed = false;

// Damage animation variables
is_hurt = false;
hurt_timer = 0;
hurt_duration = 0.2;
original_image_blend = c_white;

// Destruction animation variables
is_dying = false;
death_timer = 0;
death_duration = 0.5;

// Take damage function with hurt animation and critical hit support
take_damage = function(damage_amount, is_critical = false) {
    if (is_destroyed) return false; // Already destroyed
    
    hp -= damage_amount;
    
    // Create floating damage text (smaller for asteroids)
    create_damage_text(x, y - 12, damage_amount, is_critical);
    
    // Start hurt animation - asteroids flash white when hit
    is_hurt = true;
    hurt_timer = 0;
    image_blend = is_critical ? c_yellow : c_white;
    
    if (is_critical) {
        show_debug_message("Asteroid took CRITICAL " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    } else {
        show_debug_message("Asteroid took " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    }
    
    // Check if asteroid should be destroyed
    if (hp <= 0) {
        is_destroyed = true;
        is_dying = true;
        show_debug_message("Asteroid destroyed - playing destruction animation");
        return true;
    }
    
    return false;
};

// Block line of sight and movement like tiles
blocks_movement = true;
blocks_line_of_sight = true;

// Position is already centered by room generator, no need to snap