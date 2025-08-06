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
            show_debug_message("Fighter hurt animation complete - destroying now");
            instance_destroy();
            return; // Exit to prevent further processing
        }
    } else {
        // Flash between red and white (faster for fighter)
        var flash_speed = 12; // Faster flashes for agile fighter
        var flash_cycle = hurt_timer * flash_speed;
        if (floor(flash_cycle) % 2 == 0) {
            image_blend = c_red;
        } else {
            image_blend = c_white;
        }
    }
}

// Fighter AI - Aggressive pursuit with multiple moves per turn
if (is_myturn && moves > 0 && !is_animating && !is_dying) {
    var player = instance_find(obj_player, 0);
    
    if (player != noone) {
        // Fighter behavior: Use all moves to get closer and attack
        var actions_this_turn = 0;
        var max_actions = moves_max; // Fighter can do multiple actions
        
        while (moves > 0 && actions_this_turn < max_actions && !is_animating) {
            // Check if player is in attack range
            if (in_attack_range(player.x, player.y)) {
                // Attack the player
                if (variable_instance_exists(player, "take_damage")) {
                    player.take_damage(damage);
                } else {
                    // Debug enemy damage
                    show_debug_message("Fighter attacking player for " + string(damage) + " damage");
                    // Fallback to direct damage
                    player.hp -= damage;
                    if (player.hp <= 0) {
                        instance_destroy(player);
                    }
                }
                moves--;
                actions_this_turn++;
                
                show_debug_message("Fighter attacked player with " + string(damage) + " damage");
                
                // Check for defeat immediately
                var turn_manager = instance_find(obj_turn_manager, 0);
                if (turn_manager != noone) {
                    turn_manager.check_game_state();
                }
                
                // Fighter uses remaining moves to try to stay close or retreat
                break;
            } else {
                // Move towards player aggressively
                var dir = get_direction_to_target(player.x, player.y);
                
                if (try_move(dir[0], dir[1])) {
                    moves--;
                    actions_this_turn++;
                    
                    // Short delay between moves for visual clarity
                    if (moves > 0) {
                        // Continue moving if we still have moves and aren't at target
                        continue;
                    }
                } else {
                    // If can't move towards player, try flanking maneuvers
                    var flanking_dirs = [];
                    
                    // Try perpendicular directions first (flanking)
                    if (abs(dir[0]) > abs(dir[1])) {
                        // Primary direction is horizontal, try vertical flanking
                        array_push(flanking_dirs, [0, -1]);
                        array_push(flanking_dirs, [0, 1]);
                        array_push(flanking_dirs, [dir[0], 0]); // Original direction
                    } else {
                        // Primary direction is vertical, try horizontal flanking  
                        array_push(flanking_dirs, [-1, 0]);
                        array_push(flanking_dirs, [1, 0]);
                        array_push(flanking_dirs, [0, dir[1]]); // Original direction
                    }
                    
                    var moved = false;
                    for (var i = 0; i < array_length(flanking_dirs); i++) {
                        if (try_move(flanking_dirs[i][0], flanking_dirs[i][1])) {
                            moves--;
                            actions_this_turn++;
                            moved = true;
                            break;
                        }
                    }
                    
                    if (!moved) {
                        // Can't move anywhere, end turn
                        moves = 0;
                        break;
                    }
                }
            }
        }
        
        // If fighter still has moves but couldn't use them, end turn
        if (actions_this_turn >= max_actions) {
            moves = 0;
        }
    } else {
        // No player found, skip turn
        moves = 0;
    }
}