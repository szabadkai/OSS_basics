// Autotiling Functions for 47-tile autotiling system

// Get neighbor mask for autotiling (GameMaker's 47-tile system)
function get_neighbor_mask(grid_x, grid_y, layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    var mask = 0;
    
    // GameMaker's standard bit positions for 47-tile autotiling:
    // NW=1, N=2, NE=4, W=8, E=16, SW=32, S=64, SE=128
    
    // Check orthogonal neighbors first
    var n_exists = false;
    var e_exists = false;
    var s_exists = false;
    var w_exists = false;
    
    // North
    var tile_data = tilemap_get_at_pixel(tilemap_id, grid_x * 32, (grid_y - 1) * 32);
    if (tile_data != 0) {
        mask |= 2;  // N bit
        n_exists = true;
    }
    
    // East
    tile_data = tilemap_get_at_pixel(tilemap_id, (grid_x + 1) * 32, grid_y * 32);
    if (tile_data != 0) {
        mask |= 16; // E bit
        e_exists = true;
    }
    
    // South
    tile_data = tilemap_get_at_pixel(tilemap_id, grid_x * 32, (grid_y + 1) * 32);
    if (tile_data != 0) {
        mask |= 64; // S bit
        s_exists = true;
    }
    
    // West
    tile_data = tilemap_get_at_pixel(tilemap_id, (grid_x - 1) * 32, grid_y * 32);
    if (tile_data != 0) {
        mask |= 8;  // W bit
        w_exists = true;
    }
    
    // Check diagonal neighbors only if adjacent orthogonal neighbors exist
    // Northwest (only if N and W exist)
    if (n_exists && w_exists) {
        tile_data = tilemap_get_at_pixel(tilemap_id, (grid_x - 1) * 32, (grid_y - 1) * 32);
        if (tile_data != 0) {
            mask |= 1;  // NW bit
        }
    }
    
    // Northeast (only if N and E exist)
    if (n_exists && e_exists) {
        tile_data = tilemap_get_at_pixel(tilemap_id, (grid_x + 1) * 32, (grid_y - 1) * 32);
        if (tile_data != 0) {
            mask |= 4;  // NE bit
        }
    }
    
    // Southwest (only if S and W exist)
    if (s_exists && w_exists) {
        tile_data = tilemap_get_at_pixel(tilemap_id, (grid_x - 1) * 32, (grid_y + 1) * 32);
        if (tile_data != 0) {
            mask |= 32; // SW bit
        }
    }
    
    // Southeast (only if S and E exist)
    if (s_exists && e_exists) {
        tile_data = tilemap_get_at_pixel(tilemap_id, (grid_x + 1) * 32, (grid_y + 1) * 32);
        if (tile_data != 0) {
            mask |= 128; // SE bit
        }
    }
    
    return mask;
}

// Simplified tile selection - just use a basic tile without autotiling
function get_autotile_index(neighbor_mask) {
    // Use tile 24 for all tiles
    return 24;
}

// Simplified tile placement - just place a basic tile
function place_autotile(grid_x, grid_y, layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    
    // Just place tile 24 
    var tile_index = 24;
    
    // Place the tile using tilemap_set_at_pixel
    tilemap_set_at_pixel(tilemap_id, tile_index, grid_x * 32, grid_y * 32);
    
    show_debug_message("Placed basic tile at (" + string(grid_x) + ", " + string(grid_y) + ") -> tile " + string(tile_index));
    
    return tile_index;
}

// Update autotiles around a position (when a tile is added/removed)
function update_autotiles_around(grid_x, grid_y, layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    
    // Update the tile at the position
    var current_tile = tilemap_get_at_pixel(tilemap_id, grid_x * 32, grid_y * 32);
    if (current_tile != 0) {
        place_autotile(grid_x, grid_y, layer_id);
    }
    
    // Update all 8 neighbors
    var neighbor_offsets = [
        [0, -1],  // N
        [1, -1],  // NE
        [1, 0],   // E
        [1, 1],   // SE
        [0, 1],   // S
        [-1, 1],  // SW
        [-1, 0],  // W
        [-1, -1]  // NW
    ];
    
    for (var i = 0; i < 8; i++) {
        var neighbor_x = grid_x + neighbor_offsets[i][0];
        var neighbor_y = grid_y + neighbor_offsets[i][1];
        
        // Check if neighbor has a tile
        var neighbor_tile = tilemap_get_at_pixel(tilemap_id, neighbor_x * 32, neighbor_y * 32);
        if (neighbor_tile != 0) {
            place_autotile(neighbor_x, neighbor_y, layer_id);
        }
    }
}

// Generate tile clusters with 5-15 tiles each, max 3 connections per tile
function generate_random_tiles(percentage, layer_id) {
    var room_grid_width = room_width div 32;
    var room_grid_height = room_height div 32;
    var total_tiles = room_grid_width * room_grid_height;
    var tiles_to_place = floor(total_tiles * (percentage / 100));
    
    var tilemap_id = layer_tilemap_get_id(layer_id);
    var placed_positions = [];
    var placed_count = 0;
    var cluster_count = 0;
    
    show_debug_message("Generating " + string(tiles_to_place) + " tiles in clusters (" + string(percentage) + "% of " + string(total_tiles) + " total)");
    show_debug_message("Current entities: " + string(instance_number(obj_player)) + " players, " + string(instance_number(obj_enemy)) + " enemies");
    
    // Generate clusters until we've placed enough tiles
    while (placed_count < tiles_to_place) {
        cluster_count++;
        
        // Determine cluster size (5-15 tiles)
        var cluster_size = 5 + irandom(10); // 5-15 tiles
        var remaining_tiles = tiles_to_place - placed_count;
        cluster_size = min(cluster_size, remaining_tiles);
        
        show_debug_message("Generating cluster " + string(cluster_count) + " with " + string(cluster_size) + " tiles");
        
        // Find a valid starting position for the cluster
        var start_x = -1;
        var start_y = -1;
        var attempts = 0;
        
        while (start_x == -1 && attempts < 100) {
            attempts++;
            var test_x = irandom(room_grid_width - 1);
            var test_y = irandom(room_grid_height - 1);
            
            if (is_position_valid_for_cluster_start(test_x, test_y, tilemap_id)) {
                start_x = test_x;
                start_y = test_y;
            }
        }
        
        if (start_x == -1) {
            show_debug_message("Could not find valid cluster start position, stopping generation");
            break;
        }
        
        // Generate the cluster starting from this position
        var cluster_tiles = generate_cluster(start_x, start_y, cluster_size, tilemap_id);
        
        // Add cluster tiles to our tracking arrays
        for (var i = 0; i < array_length(cluster_tiles); i++) {
            array_push(placed_positions, cluster_tiles[i]);
            placed_count++;
        }
        
        show_debug_message("Placed cluster " + string(cluster_count) + " with " + string(array_length(cluster_tiles)) + " tiles");
    }
    
    show_debug_message("Generated " + string(cluster_count) + " clusters with " + string(placed_count) + " total tiles");
    
    return placed_count;
}

// Check if a position is valid for starting a cluster
function is_position_valid_for_cluster_start(grid_x, grid_y, tilemap_id) {
    // Check if position already has a tile
    var existing_tile = tilemap_get_at_pixel(tilemap_id, grid_x * 32, grid_y * 32);
    if (existing_tile != 0) {
        return false;
    }
    
    // Check for entities at this position
    with (obj_player) {
        var player_grid_x = x div 32;
        var player_grid_y = y div 32;
        if (player_grid_x == grid_x && player_grid_y == grid_y) {
            return false;
        }
    }
    
    with (obj_enemy) {
        var enemy_grid_x = x div 32;
        var enemy_grid_y = y div 32;
        if (enemy_grid_x == grid_x && enemy_grid_y == grid_y) {
            return false;
        }
    }
    
    // Check that we're not too close to existing clusters (minimum 2 tile gap)
    for (var dx = -2; dx <= 2; dx++) {
        for (var dy = -2; dy <= 2; dy++) {
            var check_x = grid_x + dx;
            var check_y = grid_y + dy;
            if (check_x >= 0 && check_x < (room_width div 32) && check_y >= 0 && check_y < (room_height div 32)) {
                var check_tile = tilemap_get_at_pixel(tilemap_id, check_x * 32, check_y * 32);
                if (check_tile != 0) {
                    return false; // Too close to existing tiles
                }
            }
        }
    }
    
    return true;
}

// Generate a single cluster of tiles using controlled growth
function generate_cluster(start_x, start_y, target_size, tilemap_id) {
    var cluster_tiles = [];
    var growth_candidates = [];
    
    // Place the first tile
    tilemap_set_at_pixel(tilemap_id, 24, start_x * 32, start_y * 32);
    array_push(cluster_tiles, [start_x, start_y]);
    
    // Add adjacent positions as growth candidates
    add_growth_candidates(start_x, start_y, growth_candidates, tilemap_id);
    
    // Grow the cluster
    while (array_length(cluster_tiles) < target_size && array_length(growth_candidates) > 0) {
        // Pick a random growth candidate
        var candidate_index = irandom(array_length(growth_candidates) - 1);
        var candidate = growth_candidates[candidate_index];
        var cand_x = candidate[0];
        var cand_y = candidate[1];
        
        // Remove this candidate from the list
        array_delete(growth_candidates, candidate_index, 1);
        
        // Check if this position would exceed the 3-connection limit
        var connections = count_tile_connections(cand_x, cand_y, tilemap_id);
        if (connections > 3) {
            continue; // Skip this position
        }
        
        // Place the tile
        tilemap_set_at_pixel(tilemap_id, 24, cand_x * 32, cand_y * 32);
        array_push(cluster_tiles, [cand_x, cand_y]);
        
        // Add new growth candidates from this position
        add_growth_candidates(cand_x, cand_y, growth_candidates, tilemap_id);
    }
    
    show_debug_message("Generated cluster with " + string(array_length(cluster_tiles)) + " tiles (target was " + string(target_size) + ")");
    return cluster_tiles;
}

// Add valid adjacent positions as growth candidates
function add_growth_candidates(center_x, center_y, growth_candidates, tilemap_id) {
    var directions = [[0, -1], [1, 0], [0, 1], [-1, 0]]; // N, E, S, W
    
    for (var i = 0; i < array_length(directions); i++) {
        var new_x = center_x + directions[i][0];
        var new_y = center_y + directions[i][1];
        
        // Check bounds
        if (new_x < 0 || new_x >= (room_width div 32) || new_y < 0 || new_y >= (room_height div 32)) {
            continue;
        }
        
        // Check if position is already occupied
        var existing_tile = tilemap_get_at_pixel(tilemap_id, new_x * 32, new_y * 32);
        if (existing_tile != 0) {
            continue;
        }
        
        // Check for entities
        var blocked = false;
        with (obj_player) {
            if (x div 32 == new_x && y div 32 == new_y) {
                blocked = true;
            }
        }
        with (obj_enemy) {
            if (x div 32 == new_x && y div 32 == new_y) {
                blocked = true;
            }
        }
        
        if (blocked) {
            continue;
        }
        
        // Check if already in candidates list
        var already_candidate = false;
        for (var j = 0; j < array_length(growth_candidates); j++) {
            if (growth_candidates[j][0] == new_x && growth_candidates[j][1] == new_y) {
                already_candidate = true;
                break;
            }
        }
        
        if (!already_candidate) {
            array_push(growth_candidates, [new_x, new_y]);
        }
    }
}

// Count how many connections a tile would have if placed
function count_tile_connections(grid_x, grid_y, tilemap_id) {
    var connections = 0;
    var directions = [[0, -1], [1, 0], [0, 1], [-1, 0]]; // N, E, S, W
    
    for (var i = 0; i < array_length(directions); i++) {
        var check_x = grid_x + directions[i][0];
        var check_y = grid_y + directions[i][1];
        
        // Check bounds
        if (check_x < 0 || check_x >= (room_width div 32) || check_y < 0 || check_y >= (room_height div 32)) {
            continue;
        }
        
        // Check if there's a tile at this position
        var tile_data = tilemap_get_at_pixel(tilemap_id, check_x * 32, check_y * 32);
        if (tile_data != 0) {
            connections++;
        }
    }
    
    return connections;
}

// Clear all tiles from a layer
function clear_tiles(layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    tilemap_clear(tilemap_id, 0);
}

// Place a single tile and update autotiling around it
function place_single_tile(grid_x, grid_y, layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    
    // Place basic tile
    var basic_tile_data = tile_set_index(0, 1);
    tilemap_set_at_pixel(tilemap_id, basic_tile_data, grid_x * 32, grid_y * 32);
    
    // Update autotiling for this tile and neighbors
    update_autotiles_around(grid_x, grid_y, layer_id);
}

// Remove a tile and update autotiling around it
function remove_tile(grid_x, grid_y, layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    
    // Remove the tile
    tilemap_set_at_pixel(tilemap_id, 0, grid_x * 32, grid_y * 32);
    
    // Update autotiling for neighbors
    update_autotiles_around(grid_x, grid_y, layer_id);
}