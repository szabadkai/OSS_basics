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
    
    with (obj_enemy_fighter) {
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
    
    with (obj_enemy_heavy) {
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
    
    // Check for asteroids (they block movement)
    with (obj_asteroid) {
        if (exclude_self && id == other.id) continue;
        if (is_destroyed) continue; // Destroyed asteroids don't block
        
        var asteroid_grid_x = x div global.grid_size;
        var asteroid_grid_y = y div global.grid_size;
        
        if (asteroid_grid_x == grid_x && asteroid_grid_y == grid_y) {
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
    
    // Create thruster effect for movement only if visible in viewport
    if (is_in_viewport()) {
        var move_direction = point_direction(x, y, new_world_x, new_world_y);
        var thruster_color = c_blue;
        
        // Different thruster colors for different entity types
        if (object_index == obj_player) {
            thruster_color = c_lime;
        } else if (object_index == obj_enemy_fighter) {
            thruster_color = c_orange;
        } else if (object_index == obj_enemy_heavy) {
            thruster_color = c_red;
        }
        
        create_thruster_effect(x, y, move_direction, thruster_color);
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

// Get direction away from target (opposite of get_direction_to_target)
function get_direction_away_from_target(target_x, target_y) {
    var dx = target_x - x;
    var dy = target_y - y;
    
    // Return the opposite direction
    if (abs(dx) > abs(dy)) {
        return dx > 0 ? [-1, 0] : [1, 0]; // Left or Right (opposite)
    } else {
        return dy > 0 ? [0, -1] : [0, 1]; // Up or Down (opposite)
    }
}

// Check if target is in attack range (adjacent squares, no diagonals)
function in_attack_range(target_x, target_y) {
    var dx = abs(target_x - x);
    var dy = abs(target_y - y);
    
    // Adjacent squares (cardinal directions only)
    return (dx == grid_size && dy == 0) || (dx == 0 && dy == grid_size);
}

// Check if target is within weapon range and firing pattern
function is_valid_weapon_target(target_x, target_y, weapon_upgrade = noone) {
    if (weapon_upgrade == noone) {
        // Default weapon - adjacent range only
        return in_attack_range(target_x, target_y);
    }
    
    var target_grid_x = target_x div global.grid_size;
    var target_grid_y = target_y div global.grid_size;
    var player_grid_x = x div global.grid_size;
    var player_grid_y = y div global.grid_size;
    
    var dx = target_grid_x - player_grid_x;
    var dy = target_grid_y - player_grid_y;
    var distance = max(abs(dx), abs(dy)); // Grid distance
    
    // Check if target is within weapon's maximum range
    if (variable_struct_exists(weapon_upgrade.effects, "max_range")) {
        if (distance > weapon_upgrade.effects.max_range) {
            return false;
        }
    } else {
        // Default range is adjacent
        if (distance > 1) {
            return false;
        }
    }
    
    // Check firing pattern restrictions
    if (variable_struct_exists(weapon_upgrade.effects, "firing_pattern")) {
        var pattern = weapon_upgrade.effects.firing_pattern;
        
        switch (pattern) {
            case "line":
                // Rail Gun - must be in straight line (cardinal directions only)
                return (dx == 0 && dy != 0) || (dy == 0 && dx != 0);
                
            case "cone":
                // Shotgun Array - cone pattern in facing direction
                return is_target_in_cone(target_grid_x, target_grid_y);
                
            case "indirect":
                // Missile Pod - can fire around corners, no line of sight needed
                return true;
                
            default:
                // Unknown pattern, use default adjacent range
                return distance <= 1;
        }
    }
    
    // No special pattern, use range check only
    return true;
}

// Check if target is within shotgun cone based on player facing direction
function is_target_in_cone(target_grid_x, target_grid_y) {
    var player_grid_x = x div global.grid_size;
    var player_grid_y = y div global.grid_size;
    
    var dx = target_grid_x - player_grid_x;
    var dy = target_grid_y - player_grid_y;
    
    // Determine player facing direction based on image_angle
    // 0 = Up, 90 = Left, 180 = Down, 270 = Right
    switch (image_angle) {
        case 0: // Facing Up
            return dy < 0 && abs(dx) <= abs(dy);
        case 90: // Facing Left
            return dx < 0 && abs(dy) <= abs(dx);
        case 180: // Facing Down
            return dy > 0 && abs(dx) <= abs(dy);
        case 270: // Facing Right
            return dx > 0 && abs(dy) <= abs(dx);
        default:
            // Default to facing up if angle is unclear
            return dy < 0 && abs(dx) <= abs(dy);
    }
}

// Get all valid targets within weapon range and pattern
function get_valid_weapon_targets(weapon_upgrade = noone) {
    var valid_targets = [];
    
    // Check all enemy types
    with (obj_enemy) {
        if (other.is_valid_weapon_target(x, y, weapon_upgrade)) {
            array_push(valid_targets, id);
        }
    }
    with (obj_enemy_fighter) {
        if (other.is_valid_weapon_target(x, y, weapon_upgrade)) {
            array_push(valid_targets, id);
        }
    }
    with (obj_enemy_heavy) {
        if (other.is_valid_weapon_target(x, y, weapon_upgrade)) {
            array_push(valid_targets, id);
        }
    }
    
    return valid_targets;
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

// Check if object is visible in current viewport
function is_in_viewport() {
    // Get camera position and view size
    var cam_x = camera_get_view_x(view_camera[0]);
    var cam_y = camera_get_view_y(view_camera[0]);
    var cam_w = camera_get_view_width(view_camera[0]);
    var cam_h = camera_get_view_height(view_camera[0]);
    
    // Add buffer zone to prevent pop-in/out during movement
    var buffer = 64;
    
    // Check if object is within viewport bounds (with buffer)
    return (x >= cam_x - buffer && x <= cam_x + cam_w + buffer && 
            y >= cam_y - buffer && y <= cam_y + cam_h + buffer);
}

// Update smooth movement animation (call in Step event)
function update_smooth_movement() {
    if (is_animating) {
        // Only animate if object is visible in viewport
        if (is_in_viewport()) {
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
        } else {
            // Object not visible, skip animation and jump to final position
            x = move_target_x;
            y = move_target_y;
            is_animating = false;
            move_timer = 0;
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
        
        // Check for ranged weapon attacks before attempting movement
        var player_weapon = upgrades.weapon;
        if (player_weapon != noone && variable_struct_exists(player_weapon.effects, "max_range")) {
            var max_range = player_weapon.effects.max_range;
            if (max_range > 1) {
                // Check if there are valid ranged targets in the direction we're trying to move
                var target_found = false;
                
                // Look for enemies in the movement direction up to weapon range
                for (var range = 1; range <= max_range; range++) {
                    var check_x = current_grid_x + (move_x * range);
                    var check_y = current_grid_y + (move_y * range);
                    var check_world_x = check_x * global.grid_size + (global.grid_size / 2);
                    var check_world_y = check_y * global.grid_size + (global.grid_size / 2);
                    
                    // Check if position is within bounds
                    if (check_world_x < global.grid_size/2 || check_world_x >= room_width - global.grid_size/2 || 
                        check_world_y < global.grid_size/2 || check_world_y >= room_height - global.grid_size/2) {
                        break;
                    }
                    
                    // Find target (enemy or asteroid) at this position
                    var target_at_range = noone;
                    with (obj_enemy) {
                        var enemy_grid_x = x div global.grid_size;
                        var enemy_grid_y = y div global.grid_size;
                        if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                            target_at_range = id;
                            break;
                        }
                    }
                    if (target_at_range == noone) {
                        with (obj_enemy_fighter) {
                            var enemy_grid_x = x div global.grid_size;
                            var enemy_grid_y = y div global.grid_size;
                            if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                                target_at_range = id;
                                break;
                            }
                        }
                    }
                    if (target_at_range == noone) {
                        with (obj_enemy_heavy) {
                            var enemy_grid_x = x div global.grid_size;
                            var enemy_grid_y = y div global.grid_size;
                            if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                                target_at_range = id;
                                break;
                            }
                        }
                    }
                    // Check for asteroids
                    if (target_at_range == noone) {
                        with (obj_asteroid) {
                            if (is_destroyed) continue;
                            var asteroid_grid_x = x div global.grid_size;
                            var asteroid_grid_y = y div global.grid_size;
                            if (asteroid_grid_x == check_x && asteroid_grid_y == check_y) {
                                target_at_range = id;
                                break;
                            }
                        }
                    }
                    
                    if (target_at_range != noone) {
                        // Check if this target is valid for our weapon
                        if (is_valid_weapon_target(target_at_range.x, target_at_range.y, player_weapon)) {
                            // Perform ranged attack
                            execute_weapon_attack(target_at_range, player_weapon);
                            return 2; // attacked
                        }
                    }
                    
                    // Stop checking further if we hit a tile (for line weapons like Rail Gun)
                    if (is_tile_at_position(check_x, check_y) && 
                        variable_struct_exists(player_weapon.effects, "firing_pattern") && 
                        player_weapon.effects.firing_pattern == "line") {
                        break;
                    }
                }
            }
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
    
    // Check for enemies and asteroids at the target position (melee attack)
    if (object_index == obj_player) {
        // Check for any enemy type at the target grid position
        var target_at_position = noone;
        with (obj_enemy) {
            var enemy_grid_x = x div global.grid_size;
            var enemy_grid_y = y div global.grid_size;
            if (enemy_grid_x == new_grid_x && enemy_grid_y == new_grid_y) {
                target_at_position = id;
                break;
            }
        }
        // Check for fighter
        if (target_at_position == noone) {
            with (obj_enemy_fighter) {
                var enemy_grid_x = x div global.grid_size;
                var enemy_grid_y = y div global.grid_size;
                if (enemy_grid_x == new_grid_x && enemy_grid_y == new_grid_y) {
                    target_at_position = id;
                    break;
                }
            }
        }
        // Check for heavy cruiser
        if (target_at_position == noone) {
            with (obj_enemy_heavy) {
                var enemy_grid_x = x div global.grid_size;
                var enemy_grid_y = y div global.grid_size;
                if (enemy_grid_x == new_grid_x && enemy_grid_y == new_grid_y) {
                    target_at_position = id;
                    break;
                }
            }
        }
        // Check for asteroids (can be attacked to destroy them)
        if (target_at_position == noone) {
            with (obj_asteroid) {
                if (is_destroyed) continue; // Can't attack destroyed asteroids
                var asteroid_grid_x = x div global.grid_size;
                var asteroid_grid_y = y div global.grid_size;
                if (asteroid_grid_x == new_grid_x && asteroid_grid_y == new_grid_y) {
                    target_at_position = id;
                    break;
                }
            }
        }
        
        if (target_at_position != noone) {
            // Attack the target instead of moving (melee attack)
            execute_weapon_attack(target_at_position, upgrades.weapon);
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

// Execute weapon attack based on weapon type and effects
function execute_weapon_attack(target, weapon_upgrade) {
    if (!instance_exists(target)) return;
    
    // Calculate critical hit for player attacks
    var player_crit_chance = 10; // Base 10% crit chance
    if (weapon_upgrade != noone && variable_struct_exists(weapon_upgrade.effects, "crit_chance")) {
        player_crit_chance = weapon_upgrade.effects.crit_chance;
    }
    
    if (weapon_upgrade != noone && variable_struct_exists(weapon_upgrade.effects, "area_attack") && weapon_upgrade.effects.area_attack) {
        // Chain Gun: Execute chain attack from upgrade system (has its own crit handling)
        execute_chain_gun_attack(target, damage);
    } else if (weapon_upgrade != noone && variable_struct_exists(weapon_upgrade.effects, "weapon_type")) {
        // Special weapon types with unique behaviors
        var weapon_type = weapon_upgrade.effects.weapon_type;
        
        switch (weapon_type) {
            case "shotgun":
                // Shotgun Array: Hit all enemies in cone (has its own crit handling)
                execute_shotgun_attack(weapon_upgrade);
                break;
                
            case "rail_gun":
                // Rail Gun: Piercing line attack (has its own crit handling)
                execute_railgun_attack(target, weapon_upgrade);
                break;
                
            case "missile":
                // Missile Pod: Create missile projectile
                var crit_result = calculate_critical_hit(damage, player_crit_chance);
                create_projectile(x, y, target.x, target.y, target, crit_result.damage, crit_result.is_critical, "missile");
                break;
                
            default:
                // Normal single-target attack with laser projectile
                var crit_result = calculate_critical_hit(damage, player_crit_chance);
                create_projectile(x, y, target.x, target.y, target, crit_result.damage, crit_result.is_critical, "laser");
                break;
        }
    } else {
        // Normal single-target attack with laser projectile
        var crit_result = calculate_critical_hit(damage, player_crit_chance);
        create_projectile(x, y, target.x, target.y, target, crit_result.damage, crit_result.is_critical, "laser");
    }
    
    audio_play_sound(Sound2, 1, false);
    
    // Check for victory immediately
    var turn_manager = instance_find(obj_turn_manager, 0);
    if (turn_manager != noone) {
        turn_manager.check_game_state();
    }
}