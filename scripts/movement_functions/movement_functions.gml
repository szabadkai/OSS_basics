// Movement Functions for Grid-Based Movement

// Check if a grid position is occupied by any entity
function is_grid_position_occupied(grid_x, grid_y, exclude_self = true) {
    // Check all entities that might occupy grid positions
    with (obj_player) {
        if (exclude_self && id == other.id) continue;
        
        var entity_grid_x, entity_grid_y;
        if (is_animating) {
            // Use target position if animating
            entity_grid_x = move_target_x;
            entity_grid_y = move_target_y;
        } else {
            // Use current position
            entity_grid_x = x;
            entity_grid_y = y;
        }
        
        if (entity_grid_x == grid_x && entity_grid_y == grid_y) {
            return true;
        }
    }
    
    with (obj_enemy) {
        if (exclude_self && id == other.id) continue;
        
        var entity_grid_x, entity_grid_y;
        if (is_animating) {
            // Use target position if animating
            entity_grid_x = move_target_x;
            entity_grid_y = move_target_y;
        } else {
            // Use current position
            entity_grid_x = x;
            entity_grid_y = y;
        }
        
        if (entity_grid_x == grid_x && entity_grid_y == grid_y) {
            return true;
        }
    }
    
    return false;
}

// Try to move an object in a direction
// Returns true if movement was successful, false if blocked
function try_move(move_x, move_y) {
    var new_x = x + move_x * grid_size;
    var new_y = y + move_y * grid_size;
    
    // Check if the new position is within room bounds
    if (new_x < 0 || new_x >= room_width || new_y < 0 || new_y >= room_height) {
        return false;
    }
    
    // Check if target grid position is already occupied
    if (is_grid_position_occupied(new_x, new_y, true)) {
        return false;
    }
    
    // Movement successful - start smooth animation
    start_smooth_movement(new_x, new_y);
    return true;
}

// Snap object to grid
function snap_to_grid() {
    x = round(x / grid_size) * grid_size;
    y = round(y / grid_size) * grid_size;
}

// Get direction from one object to another (for AI)
function get_direction_to_target(target_x, target_y) {
    var dx = target_x - x;
    var dy = target_y - y;
    
    // Return the primary direction
    if (abs(dx) > abs(dy)) {
        return dx > 0 ? [1, 0] : [-1, 0]; // Right or Left
    } else {
        return dy > 0 ? [0, 1] : [0, -1]; // Down or Up
    }
}

// Check if target is in attack range (adjacent squares, no diagonals)
function in_attack_range(target_x, target_y) {
    var dx = abs(target_x - x);
    var dy = abs(target_y - y);
    
    // Adjacent squares (cardinal directions only)
    return (dx == grid_size && dy == 0) || (dx == 0 && dy == grid_size);
}

// Start smooth movement animation to target position
function start_smooth_movement(target_x, target_y, duration = 0.2) {
    // Set animation state
    is_animating = true;
    
    // Store start and target positions
    move_start_x = x;
    move_start_y = y;
    move_target_x = target_x;
    move_target_y = target_y;
    
    // Animation timing
    move_timer = 0;
    move_duration = duration;
}

// Update smooth movement animation (call in Step event)
function update_smooth_movement() {
    if (is_animating) {
        move_timer += 1 / room_speed;
        
        if (move_timer >= move_duration) {
            // Animation complete
            x = move_target_x;
            y = move_target_y;
            is_animating = false;
            move_timer = 0;
        } else {
            // Interpolate position using easing function
            var progress = move_timer / move_duration;
            var eased_progress = ease_out_cubic(progress);
            
            x = lerp(move_start_x, move_target_x, eased_progress);
            y = lerp(move_start_y, move_target_y, eased_progress);
        }
    }
}

// Easing function for smooth animation
function ease_out_cubic(t) {
    return 1 - power(1 - t, 3);
}

// Try to move, but attack if there's an enemy in the way (player only)
// Returns: 0 = blocked, 1 = moved, 2 = attacked
function try_move_or_attack(move_x, move_y) {
    var new_x = x + move_x * grid_size;
    var new_y = y + move_y * grid_size;
    
    // Set player facing direction based on movement
    if (object_index == obj_player) {
        if (move_x > 0) {
            image_angle = 270; // Right
        } else if (move_x < 0) {
            image_angle = 90; // Left
        } else if (move_y < 0) {
            image_angle = 0; // Up
        } else if (move_y > 0) {
            image_angle = 180; // Down
        }
    }
    
    // Check if the new position is within room bounds
    if (new_x < 0 || new_x >= room_width || new_y < 0 || new_y >= room_height) {
        return 0; // blocked by room bounds
    }
    
    // Check for enemies at the target position
    if (object_index == obj_player) {
        var enemy_at_target = instance_place(new_x, new_y, obj_enemy);
        if (enemy_at_target != noone) {
            // Attack the enemy instead of moving
            enemy_at_target.hp -= damage;
            audio_play_sound(Sound2, 1, false);
            // Check if enemy died
            if (enemy_at_target.hp <= 0) {
                instance_destroy(enemy_at_target);
                
                // Check for victory immediately
                var turn_manager = instance_find(obj_turn_manager, 0);
                if (turn_manager != noone) {
                    turn_manager.check_game_state();
                }
            }
            
            return 2; // attacked
        }
    }
    
    // No enemy, try normal movement
    if (try_move(move_x, move_y)) {
        return 1; // moved
    } else {
        return 0; // blocked
    }
}