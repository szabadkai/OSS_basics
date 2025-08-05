// Room Generator - spawns enemies randomly
grid_size = global.grid_size;

// Calculate level-based difficulty
calculate_level_params = function() {
    // Ensure global level exists
    if (!variable_global_exists("current_level")) {
        global.current_level = 1;
    }
    var level = global.current_level;
    
    // Enemy count scaling: start with 15, add 3 per level, cap at 25
    var base_enemies = 15;
    var enemies_per_level = 3;
    var max_enemies = 25;
    enemy_count = min(base_enemies + (level - 1) * enemies_per_level, max_enemies);
    
    // Enemy stat scaling
    var hp_bonus = floor((level - 1) / 2); // +1 HP every 2 levels
    var damage_bonus = floor((level - 1) / 3); // +1 damage every 3 levels
    
    enemy_base_hp = 1 + hp_bonus;
    enemy_base_damage = 1 + damage_bonus;
    
    show_debug_message("Level " + string(level) + " params: " + string(enemy_count) + " enemies, " + string(enemy_base_hp) + " HP, " + string(enemy_base_damage) + " damage");
};

// Initialize level parameters
calculate_level_params();

// Check if a position is reachable from the player using simple pathfinding
is_position_reachable = function(target_grid_x, target_grid_y, occupied_positions) {
    var player = instance_find(obj_player, 0);
    if (player == noone) return false;
    
    var player_grid_x = player.x div grid_size;
    var player_grid_y = player.y div grid_size;
    
    // If target is the same as player position, it's reachable
    if (target_grid_x == player_grid_x && target_grid_y == player_grid_y) {
        return true;
    }
    
    // Simple flood fill to check reachability
    var room_grid_width = room_width div grid_size;
    var room_grid_height = room_height div grid_size;
    var visited = [];
    var queue = [];
    
    // Initialize visited array
    for (var i = 0; i < room_grid_width; i++) {
        visited[i] = [];
        for (var j = 0; j < room_grid_height; j++) {
            visited[i][j] = false;
        }
    }
    
    // Mark occupied positions as visited (blocked)
    for (var k = 0; k < array_length(occupied_positions); k++) {
        var occ_x = occupied_positions[k][0];
        var occ_y = occupied_positions[k][1];
        if (occ_x >= 0 && occ_x < room_grid_width && occ_y >= 0 && occ_y < room_grid_height) {
            visited[occ_x][occ_y] = true;
        }
    }
    
    // Also mark tile positions as blocked
    var tiles_layer = layer_get_id("Tiles_1");
    if (tiles_layer != -1) {
        var tilemap_id = layer_tilemap_get_id(tiles_layer);
        if (tilemap_id != -1) {
            for (var tx = 0; tx < room_grid_width; tx++) {
                for (var ty = 0; ty < room_grid_height; ty++) {
                    var tile_data = tilemap_get_at_pixel(tilemap_id, tx * grid_size, ty * grid_size);
                    if (tile_data != 0) {
                        visited[tx][ty] = true;
                    }
                }
            }
        }
    }
    
    // Start BFS from player position
    array_push(queue, [player_grid_x, player_grid_y]);
    visited[player_grid_x][player_grid_y] = true;
    
    // Directions: up, down, left, right
    var directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    
    while (array_length(queue) > 0) {
        var current = queue[0];
        array_delete(queue, 0, 1);
        
        var cur_x = current[0];
        var cur_y = current[1];
        
        // Check if we reached the target
        if (cur_x == target_grid_x && cur_y == target_grid_y) {
            return true;
        }
        
        // Explore neighbors
        for (var d = 0; d < array_length(directions); d++) {
            var new_x = cur_x + directions[d][0];
            var new_y = cur_y + directions[d][1];
            
            // Check bounds
            if (new_x >= 0 && new_x < room_grid_width && new_y >= 0 && new_y < room_grid_height) {
                // Check if not visited and not blocked
                if (!visited[new_x][new_y]) {
                    visited[new_x][new_y] = true;
                    array_push(queue, [new_x, new_y]);
                }
            }
        }
    }
    
    return false; // Target not reachable
};

// Spawn planet function
spawn_planet = function(occupied_positions) {
    var grid_size = global.grid_size;
    var room_grid_width = room_width div grid_size;
    var room_grid_height = room_height div grid_size;
    
    var planet_spawned = false;
    var attempts = 0;
    var max_attempts = 200; // Increased attempts due to reachability check
    
    while (!planet_spawned && attempts < max_attempts) {
        attempts++;
        
        // Generate random grid position
        var grid_x = irandom(room_grid_width - 1);
        var grid_y = irandom(room_grid_height - 1);
        
        // Calculate world position (centered on tile)
        var world_x = grid_x * grid_size + (grid_size / 2);
        var world_y = grid_y * grid_size + (grid_size / 2);
        
        // Check bounds
        if (world_x < grid_size/2 || world_x >= room_width - grid_size/2 || 
            world_y < grid_size/2 || world_y >= room_height - grid_size/2) {
            continue;
        }
        
        // Check if position is already occupied
        var position_free = true;
        for (var i = 0; i < array_length(occupied_positions); i++) {
            if (occupied_positions[i][0] == grid_x && occupied_positions[i][1] == grid_y) {
                position_free = false;
                break;
            }
        }
        
        // Check if position is reachable from player
        if (position_free && is_position_reachable(grid_x, grid_y, occupied_positions)) {
            // Spawn planet
            var planet = instance_create_layer(world_x, world_y, "Instances", obj_planet);
            
            // Store planet data globally for planet map room access
            with (planet) {
                global.current_planet = {
                    data: planet_data
                };
            }
            
            planet_spawned = true;
            
            show_debug_message("Spawned reachable planet (level " + string(global.current_level) + ") at grid(" + string(grid_x) + ", " + string(grid_y) + ") -> world(" + string(world_x) + ", " + string(world_y) + ")");
        } else if (position_free) {
            show_debug_message("Position (" + string(grid_x) + ", " + string(grid_y) + ") is free but not reachable - trying another location");
        }
    }
    
    if (!planet_spawned) {
        show_debug_message("Warning: Failed to spawn reachable planet after " + string(max_attempts) + " attempts");
        // As fallback, try to spawn in an adjacent position to player
        var player = instance_find(obj_player, 0);
        if (player != noone) {
            var player_grid_x = player.x div grid_size;
            var player_grid_y = player.y div grid_size;
            var fallback_positions = [
                [player_grid_x + 1, player_grid_y],
                [player_grid_x - 1, player_grid_y],
                [player_grid_x, player_grid_y + 1],
                [player_grid_x, player_grid_y - 1],
                [player_grid_x + 1, player_grid_y + 1],
                [player_grid_x - 1, player_grid_y - 1],
                [player_grid_x + 1, player_grid_y - 1],
                [player_grid_x - 1, player_grid_y + 1]
            ];
            
            for (var f = 0; f < array_length(fallback_positions); f++) {
                var fb_x = fallback_positions[f][0];
                var fb_y = fallback_positions[f][1];
                
                // Check bounds and availability
                if (fb_x >= 0 && fb_x < room_grid_width && fb_y >= 0 && fb_y < room_grid_height) {
                    var fb_free = true;
                    for (var j = 0; j < array_length(occupied_positions); j++) {
                        if (occupied_positions[j][0] == fb_x && occupied_positions[j][1] == fb_y) {
                            fb_free = false;
                            break;
                        }
                    }
                    
                    if (fb_free) {
                        var fb_world_x = fb_x * grid_size + (grid_size / 2);
                        var fb_world_y = fb_y * grid_size + (grid_size / 2);
                        var planet = instance_create_layer(fb_world_x, fb_world_y, "Instances", obj_planet);
                        
                        // Set planet level based on current game level
                        with(planet) {
                            level = global.current_level;
                            image_index = level;
                        }
                        
                        show_debug_message("Fallback: Spawned planet (level " + string(global.current_level) + ") adjacent to player at grid(" + string(fb_x) + ", " + string(fb_y) + ")");
                        break;
                    }
                }
            }
        }
    }
};

// Generate random enemy positions
generate_enemies = function() {
    // Recalculate level parameters
    calculate_level_params();
    
    // Clear existing enemies and planets first
    with(obj_enemy) {
        instance_destroy();
    }
    with(obj_planet) {
        instance_destroy();
    }
    
    // Get player position to avoid spawning on player
    var player = instance_find(obj_player, 0);
    var player_grid_x = -1;
    var player_grid_y = -1;
    
    if (player != noone) {
        player_grid_x = player.x div grid_size;
        player_grid_y = player.y div grid_size;
    }
    
    // Calculate room dimensions in grid units
    // Since entities are centered on tiles, we need to ensure they don't spawn outside bounds
    var room_grid_width = room_width div grid_size;
    var room_grid_height = room_height div grid_size;
    
    show_debug_message("Room dimensions: " + string(room_width) + "x" + string(room_height) + " pixels = " + string(room_grid_width) + "x" + string(room_grid_height) + " grid cells");
    
    // Track occupied positions
    var occupied_positions = [];
    if (player != noone) {
        array_push(occupied_positions, [player_grid_x, player_grid_y]);
    }
    
    // Spawn enemies
    var spawned = 0;
    var attempts = 0;
    var max_attempts = 1000; // Prevent infinite loops
    
    while (spawned < enemy_count && attempts < max_attempts) {
        attempts++;
        
        // Generate random grid position
        // Make sure we stay within bounds when entities are centered on tiles
        var grid_x = irandom(room_grid_width - 1);
        var grid_y = irandom(room_grid_height - 1);
        
        // Additional safety check: ensure the centered position is within room bounds
        var world_x = grid_x * grid_size + (grid_size / 2);
        var world_y = grid_y * grid_size + (grid_size / 2);
        
        // Skip if the centered position would be outside the room (using same bounds logic as movement functions)
        if (world_x < grid_size/2 || world_x >= room_width - grid_size/2 || 
            world_y < grid_size/2 || world_y >= room_height - grid_size/2) {
            show_debug_message("Skipping out-of-bounds position: grid(" + string(grid_x) + ", " + string(grid_y) + ") -> world(" + string(world_x) + ", " + string(world_y) + ")");
            continue;
        }
        
        // Check if position is already occupied
        var position_free = true;
        for (var i = 0; i < array_length(occupied_positions); i++) {
            if (occupied_positions[i][0] == grid_x && occupied_positions[i][1] == grid_y) {
                position_free = false;
                break;
            }
        }
        
        if (position_free) {
            // world_x and world_y are already calculated above for bounds checking
            
            // Spawn enemy
            var enemy = instance_create_layer(world_x, world_y, "Instances", obj_enemy);
            
            // Apply level-based stat scaling
            with(enemy) {
                hp_max = other.enemy_base_hp;
                hp = other.enemy_base_hp;
                damage = other.enemy_base_damage;
            }
            
            // Add position to occupied list
            array_push(occupied_positions, [grid_x, grid_y]);
            spawned++;
            
            show_debug_message("Spawned enemy " + string(spawned) + " at grid(" + string(grid_x) + ", " + string(grid_y) + ") -> world(" + string(world_x) + ", " + string(world_y) + ")");
        }
    }
    
    if (spawned < enemy_count) {
        show_debug_message("Warning: Only spawned " + string(spawned) + " out of " + string(enemy_count) + " enemies");
    }
    
    // Spawn planet after enemies are placed
    spawn_planet(occupied_positions);
    
    show_debug_message("Room generation complete. Spawned " + string(spawned) + " enemies in " + string(attempts) + " attempts");
};

// Generate enemies on room start
generate_enemies();

// Generate random tiles at 5% coverage on Tiles_1 layer
show_debug_message("Starting tile generation after enemy generation...");
show_debug_message("Current enemy count: " + string(instance_number(obj_enemy)));
var tiles_placed = generate_random_tiles(5, "Tiles_1");
show_debug_message("Tile generation complete. Placed " + string(tiles_placed) + " tiles.");