// Movement Functions for Grid-Based Movement

// Check if a grid position has a tile (solid collision)
function is_tile_at_position(grid_x, grid_y) {
    var tiles_layer = layer_get_id("Tiles_1");
    if (tiles_layer == -1) return false;
    
    var tilemap_id = layer_tilemap_get_id(tiles_layer);
    if (tilemap_id == -1) return false;
    
    var tile_data = tilemap_get_at_pixel(tilemap_id, grid_x * grid_size, grid_y * grid_size);
    return (tile_data != 0);
}

// Check if a grid position is occupied by any entity (for movement only)
function is_grid_position_occupied(grid_x, grid_y, exclude_self = true) {
    // Check all entities that might occupy grid positions
    with (obj_player) {
        if (exclude_self && id == other.id) continue;
        
        var entity_grid_x, entity_grid_y;
        if (is_animating) {
            // Use target position if animating
            entity_grid_x = move_target_x div global.grid_size;
            entity_grid_y = move_target_y div global.grid_size;
        } else {
            // Use current position
            entity_grid_x = x div global.grid_size;
            entity_grid_y = y div global.grid_size;
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
            entity_grid_x = move_target_x div global.grid_size;
            entity_grid_y = move_target_y div global.grid_size;
        } else {
            // Use current position
            entity_grid_x = x div global.grid_size;
            entity_grid_y = y div global.grid_size;
        }
        
        if (entity_grid_x == grid_x && entity_grid_y == grid_y) {
            return true;
        }
    }
    
    return false;
}

// Check if a grid position is blocked for movement (entities + tiles)
function is_grid_position_blocked_for_movement(grid_x, grid_y, exclude_self = true) {
    // First check for solid tiles
    if (is_tile_at_position(grid_x, grid_y)) {
        return true;
    }
    
    // Then check for entities
    return is_grid_position_occupied(grid_x, grid_y, exclude_self);
}

// Try to move an object in a direction
// Returns true if movement was successful, false if blocked
function try_move(move_x, move_y) {
    var current_grid_x = x div global.grid_size;
    var current_grid_y = y div global.grid_size;
    var new_grid_x = current_grid_x + move_x;
    var new_grid_y = current_grid_y + move_y;
    
    // Calculate world position (centered on grid)
    var new_world_x = new_grid_x * global.grid_size + (global.grid_size / 2);
    var new_world_y = new_grid_y * global.grid_size + (global.grid_size / 2);
    
    // Check if the new position is within room bounds
    if (new_world_x < global.grid_size/2 || new_world_x >= room_width - global.grid_size/2 || 
        new_world_y < global.grid_size/2 || new_world_y >= room_height - global.grid_size/2) {
        return false;
    }
    
    // Check if target grid position is already occupied (tiles or entities)
    if (is_grid_position_blocked_for_movement(new_grid_x, new_grid_y, true)) {
        return false;
    }
    
    // Movement successful - start smooth animation
    start_smooth_movement(new_world_x, new_world_y);
    return true;
}

// Snap object to grid center
function snap_to_grid() {
    x = round(x / global.grid_size) * global.grid_size + (global.grid_size / 2);
    y = round(y / global.grid_size) * global.grid_size + (global.grid_size / 2);
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
    var current_grid_x = x div global.grid_size;
    var current_grid_y = y div global.grid_size;
    var new_grid_x = current_grid_x + move_x;
    var new_grid_y = current_grid_y + move_y;
    
    // Calculate world position (centered on grid)
    var new_world_x = new_grid_x * global.grid_size + (global.grid_size / 2);
    var new_world_y = new_grid_y * global.grid_size + (global.grid_size / 2);
    
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
    if (new_world_x < global.grid_size/2 || new_world_x >= room_width - global.grid_size/2 || 
        new_world_y < global.grid_size/2 || new_world_y >= room_height - global.grid_size/2) {
        return 0; // blocked by room bounds
    }
    
    // Check for tiles at the target position (solid collision)
    if (is_tile_at_position(new_grid_x, new_grid_y)) {
        return 0; // blocked by tile
    }
    
    // Check for enemies at the target position
    if (object_index == obj_player) {
        // Check for enemy at the target grid position
        var enemy_at_target = noone;
        with (obj_enemy) {
            var enemy_grid_x = x div global.grid_size;
            var enemy_grid_y = y div global.grid_size;
            if (enemy_grid_x == new_grid_x && enemy_grid_y == new_grid_y) {
                enemy_at_target = id;
                break;
            }
        }
        
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
    
    // No enemy or tile, try normal movement
    if (try_move(move_x, move_y)) {
        return 1; // moved
    } else {
        return 0; // blocked
    }
}