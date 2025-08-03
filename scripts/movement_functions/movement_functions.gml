// Movement Functions for Grid-Based Movement

// Try to move an object in a direction
// Returns true if movement was successful, false if blocked
function try_move(move_x, move_y) {
    var new_x = x + move_x * grid_size;
    var new_y = y + move_y * grid_size;
    
    // Check if the new position is within room bounds
    if (new_x < 0 || new_x >= room_width || new_y < 0 || new_y >= room_height) {
        return false;
    }
    
    // Check for collision with solid objects at the new position
    var old_x = x;
    var old_y = y;
    x = new_x;
    y = new_y;
    
    var collision = false;
    
    // Check collision with other entities
    if (object_index == obj_player) {
        collision = place_meeting(x, y, obj_enemy);
    } else if (object_index == obj_enemy) {
        collision = place_meeting(x, y, obj_player) || place_meeting(x, y, obj_enemy);
    }
    
    // If collision detected, revert position
    if (collision) {
        x = old_x;
        y = old_y;
        return false;
    }
    
    // Movement successful
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

// Try to move, but attack if there's an enemy in the way (player only)
// Returns: 0 = blocked, 1 = moved, 2 = attacked
function try_move_or_attack(move_x, move_y) {
    var new_x = x + move_x * grid_size;
    var new_y = y + move_y * grid_size;
    
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