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
            show_debug_message("Heavy Cruiser hurt animation complete - destroying now");
            instance_destroy();
            return; // Exit to prevent further processing
        }
    } else {
        // Flash between red and white (slower for heavy cruiser)
        var flash_speed = 6; // Slower flashes for heavy enemy
        var flash_cycle = hurt_timer * flash_speed;
        if (floor(flash_cycle) % 2 == 0) {
            image_blend = c_red;
        } else {
            image_blend = c_white;
        }
    }
}

// Heavy Cruiser AI - Defensive positioning and powerful attacks
if (is_myturn && moves > 0 && !is_animating && !is_dying) {
    var player = instance_find(obj_player, 0);
    
    if (player != noone) {
        var distance_to_player = point_distance(x, y, player.x, player.y) / grid_size;
        
        // Check if player is in attack range
        if (in_attack_range(player.x, player.y)) {
            // Heavy cruiser has powerful attacks
            if (variable_instance_exists(player, "take_damage")) {
                player.take_damage(damage);
            } else {
                // Fallback to direct damage
                player.hp -= damage;
                if (player.hp <= 0) {
                    instance_destroy(player);
                }
            }
            moves--;
            
            show_debug_message("Heavy Cruiser attacked player with " + string(damage) + " heavy damage");
            
            // Check for defeat immediately
            var turn_manager = instance_find(obj_turn_manager, 0);
            if (turn_manager != noone) {
                turn_manager.check_game_state();
            }
        } else {
            // Heavy Cruiser defensive positioning
            if (distance_to_player < preferred_range) {
                // Too close - try to back away while maintaining line of sight
                var retreat_dir = get_direction_away_from_target(player.x, player.y);
                
                if (try_move(retreat_dir[0], retreat_dir[1])) {
                    moves--;
                    show_debug_message("Heavy Cruiser retreating to optimal range");
                } else {
                    // Can't retreat, hold position and end turn
                    moves = 0;
                }
            } else if (distance_to_player > 3) {
                // Too far - advance slowly to engagement range
                var dir = get_direction_to_target(player.x, player.y);
                
                if (try_move(dir[0], dir[1])) {
                    moves--;
                    show_debug_message("Heavy Cruiser advancing to engagement range");
                } else {
                    // Can't advance, try alternate route
                    var alt_directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
                    var moved = false;
                    
                    for (var i = 0; i < array_length(alt_directions); i++) {
                        if (try_move(alt_directions[i][0], alt_directions[i][1])) {
                            moves--;
                            moved = true;
                            break;
                        }
                    }
                    
                    if (!moved) {
                        moves = 0; // Can't move, end turn
                    }
                }
            } else {
                // At optimal range - hold position and prepare for next turn
                moves = 0;
                show_debug_message("Heavy Cruiser holding optimal defensive position");
            }
        }
    } else {
        // No player found, skip turn
        moves = 0;
    }
}