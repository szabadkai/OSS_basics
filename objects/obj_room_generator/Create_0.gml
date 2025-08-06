// Room Generator - spawns enemies randomly
grid_size = global.grid_size;

// Calculate level-based difficulty
calculate_level_params = function() {
    // Ensure global level exists
    if (!variable_global_exists("current_level")) {
        global.current_level = 1;
    }
    var level = global.current_level;
    
    // Enemy count scaling: start smaller for level 1
    if (level == 1) {
        enemy_count = 3; // Just 3 enemies for first level
    } else {
        // Normal scaling for level 2+: start with 8, add 3 per level, cap at 25
        var base_enemies = 8;
        var enemies_per_level = 3;
        var max_enemies = 25;
        enemy_count = min(base_enemies + (level - 2) * enemies_per_level, max_enemies);
    }
    
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

// Spawn asteroids for tactical cover
spawn_asteroids = function(occupied_positions) {
    var grid_size = global.grid_size;
    var room_grid_width = room_width div grid_size;
    var room_grid_height = room_height div grid_size;
    
    // Determine asteroid count based on level
    var asteroid_count;
    if (global.current_level == 1) {
        asteroid_count = 2; // Start with just 2 asteroids for level 1
    } else {
        asteroid_count = 3 + floor(global.current_level / 2); // Gradually increase
        asteroid_count = min(asteroid_count, 8); // Cap at 8 asteroids
    }
    
    var asteroids_spawned = 0;
    var attempts = 0;
    var max_attempts = 200;
    
    while (asteroids_spawned < asteroid_count && attempts < max_attempts) {
        attempts++;
        
        // Generate random grid position
        var grid_x = irandom(room_grid_width - 1);
        var grid_y = irandom(room_grid_height - 1);
        
        // Calculate world position (centered on grid)
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
        
        // Check if position is reachable from player (asteroids shouldn't block essential paths)
        if (position_free && is_position_reachable(grid_x, grid_y, occupied_positions)) {
            // Spawn asteroid
            var asteroid = instance_create_depth(world_x, world_y, 0, obj_asteroid);
            
            // Add position to occupied list for future spawns
            array_push(occupied_positions, [grid_x, grid_y]);
            asteroids_spawned++;
            
            show_debug_message("Spawned asteroid " + string(asteroids_spawned) + " at grid(" + string(grid_x) + ", " + string(grid_y) + ")");
        }
    }
    
    if (asteroids_spawned < asteroid_count) {
        show_debug_message("Warning: Only spawned " + string(asteroids_spawned) + " out of " + string(asteroid_count) + " asteroids");
    }
    
    show_debug_message("Asteroid generation complete. Spawned " + string(asteroids_spawned) + " asteroids");
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
    var fighters_spawned = 0; // Track fighter count for level 1
    
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
            // Add position to occupied list BEFORE spawning to prevent double placement
            array_push(occupied_positions, [grid_x, grid_y]);
            
            // world_x and world_y are already calculated above for bounds checking
            
            // Determine enemy type based on level and random chance
            var enemy_type_roll = irandom(100);
            var enemy_object = obj_enemy; // Default
            var enemy_type_name = "Standard";
            
            if (global.current_level >= 5) {
                // At level 5+, introduce Heavy Cruisers as end-game enemies
                if (enemy_type_roll < 15) {
                    enemy_object = obj_enemy_heavy;
                    enemy_type_name = "Heavy Cruiser";
                } else if (enemy_type_roll < 50) {
                    enemy_object = obj_enemy_fighter;
                    enemy_type_name = "Fighter";
                } else {
                    enemy_object = obj_enemy;
                    enemy_type_name = "Standard";
                }
            } else if (global.current_level >= 2) {
                // At level 2-4, just fighters and standard enemies
                if (enemy_type_roll < 40) {
                    enemy_object = obj_enemy_fighter;
                    enemy_type_name = "Fighter";
                } else {
                    enemy_object = obj_enemy;
                    enemy_type_name = "Standard";
                }
            } else if (global.current_level >= 1) {
                // At level 1, spawn 1 fighter max for a gentler introduction
                if (enemy_type_roll < 50 && fighters_spawned < 1) {
                    enemy_object = obj_enemy_fighter;
                    enemy_type_name = "Fighter";
                    fighters_spawned++;
                }
            }
            
            // Spawn enemy of chosen type
            var enemy = instance_create_layer(world_x, world_y, "Instances", enemy_object);
            
            // Apply level-based stat scaling to standard enemies only
            // Fighter and Heavy enemies have their own base stats
            if (enemy_object == obj_enemy) {
                with(enemy) {
                    hp_max = other.enemy_base_hp;
                    hp = other.enemy_base_hp;
                    damage = other.enemy_base_damage;
                }
            } else {
                // For specialized enemies, apply minor level scaling
                with(enemy) {
                    var level_hp_bonus = floor((global.current_level - 1) / 3); // +1 HP every 3 levels
                    var level_damage_bonus = floor((global.current_level - 1) / 4); // +1 damage every 4 levels
                    
                    hp_max += level_hp_bonus;
                    hp += level_hp_bonus;
                    damage += level_damage_bonus;
                }
            }
            
            spawned++;
            
            show_debug_message("Spawned " + enemy_type_name + " enemy " + string(spawned) + " at grid(" + string(grid_x) + ", " + string(grid_y) + ") -> world(" + string(world_x) + ", " + string(world_y) + ")");
        }
    }
    
    if (spawned < enemy_count) {
        show_debug_message("Warning: Only spawned " + string(spawned) + " out of " + string(enemy_count) + " enemies");
    }
    
    // Spawn asteroids for tactical cover
    spawn_asteroids(occupied_positions);
    
    // Spawn planet after enemies and asteroids are placed
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