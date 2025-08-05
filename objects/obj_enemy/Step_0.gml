// Update smooth movement animation
update_smooth_movement();

// Update hurt animation
if (is_hurt) {
    hurt_timer += 1 / room_speed;
    
    if (hurt_timer >= hurt_duration) {
        // End hurt animation
        is_hurt = false;
        hurt_timer = 0;
        image_blend = original_image_blend;
        
        // If enemy was marked for death, destroy it now
        if (is_dying) {
            show_debug_message("Enemy hurt animation complete - destroying now");
            instance_destroy();
            return; // Exit to prevent further processing
        }
    } else {
        // Flash between red and white
        var flash_speed = 8; // Flashes per second
        var flash_cycle = hurt_timer * flash_speed;
        if (floor(flash_cycle) % 2 == 0) {
            image_blend = c_red;
        } else {
            image_blend = c_white;
        }
    }
}

// Enemy AI - only act during enemy's turn and when not animating or dying
if (is_myturn && moves > 0 && !is_animating && !is_dying) {
    var player = instance_find(obj_player, 0);
    
    if (player != noone) {
        // Check if player is in attack range
        if (in_attack_range(player.x, player.y)) {
            // Attack the player using damage function (player needs take_damage function too)
            if (variable_instance_exists(player, "take_damage")) {
                // take_damage handles death animation internally now
                player.take_damage(damage);
            } else {
                // Fallback to direct damage if player doesn't have take_damage function
                player.hp -= damage;
                if (player.hp <= 0) {
                    instance_destroy(player);
                }
            }
            moves--;
            
            // Check for defeat immediately
            var turn_manager = instance_find(obj_turn_manager, 0);
            if (turn_manager != noone) {
                turn_manager.check_game_state();
            }
        } else {
            // Move towards player
            var dir = get_direction_to_target(player.x, player.y);
            
            if (try_move(dir[0], dir[1])) {
                moves--;
            } else {
                // If can't move towards player, try random direction
                var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
                var random_dir = directions[irandom(3)];
                
                if (try_move(random_dir[0], random_dir[1])) {
                    moves--;
                } else {
                    // Can't move anywhere, skip turn
                    moves = 0;
                }
            }
        }
    } else {
        // No player found, skip turn
        moves = 0;
    }
}