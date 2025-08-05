is_myturn = false;

//stats
moves_max = 1;
moves = 1;
hp_max = 1;
hp = 1;
damage = 1;
init = 10;
grid_size = global.grid_size;

// Animation variables
is_animating = false;
move_start_x = 0;
move_start_y = 0;
move_target_x = 0;
move_target_y = 0;
move_timer = 0;
move_duration = 0.2;

// Damage animation variables
is_hurt = false;
hurt_timer = 0;
hurt_duration = 0.15;
original_image_blend = c_white;
is_dying = false;

// Take damage function with hurt animation
take_damage = function(damage_amount) {
    hp -= damage_amount;
    
    // Start hurt animation
    is_hurt = true;
    hurt_timer = 0;
    image_blend = c_red; // Flash red when hurt
    
    show_debug_message("Enemy took " + string(damage_amount) + " damage, HP: " + string(hp) + "/" + string(hp_max));
    
    // Check if enemy should die
    if (hp <= 0) {
        is_dying = true;
        show_debug_message("Enemy marked for death - playing hurt animation first");
        return true;
    }
    
    return false;
};

// Snap to grid on creation
snap_to_grid();