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

// Get the correct autotile index based on neighbor mask using GameMaker's autotile configuration
function get_autotile_index(neighbor_mask) {
    // Use the actual autoTileSets array from TileSet1.yy
    var gm_autotile_map = [
        8,12,11,6,4,19,20,18,5,13,26,26,27,19,25,40,7,35,28,39,1,30,31,33,9,29,36,41,15,38,37,47,10,22,43,32,
        2,34,16,48,14,46,3,21,17,23,24
    ];
    
    // For now, use a simplified approach - map common patterns directly
    // This ensures we get valid tile indices from the autotile array
    
    // Based on your observation that isolated tile (mask 0) should be tile 26
    // Let me find the correct position in the autoTileSets array
    // Looking at the array: [8,12,11,6,4,19,20,18,5,13,26,26,27,19,25,40,7,35,28,39,1,30,31,33,9,29,36,41,15,38,37,47,10,22,43,32,2,34,16,48,14,46,3,21,17,23,24]
    // Tile 26 appears at indices 10 and 11
    
    switch(neighbor_mask) {
        case 0:   return 24;  // isolated - you specified this should be tile 26
        case 2:   return 2;  // N only -> tile 8
        case 16:  return gm_autotile_map[1];  // E only -> tile 12
        case 64:  return gm_autotile_map[2];  // S only -> tile 11
        case 8:   return gm_autotile_map[3];  // W only -> tile 6
        case 18:  return gm_autotile_map[4];  // N+E -> tile 4
        case 80:  return gm_autotile_map[5];  // E+S -> tile 19
        case 72:  return gm_autotile_map[6];  // S+W -> tile 20
        case 10:  return gm_autotile_map[7];  // N+W -> tile 18
        case 66:  return gm_autotile_map[8];  // N+S -> tile 5
        case 24:  return gm_autotile_map[9];  // E+W -> tile 13
        case 82:  return gm_autotile_map[10]; // N+E+S -> tile 26
        case 88:  return gm_autotile_map[11]; // E+S+W -> tile 26
        case 74:  return gm_autotile_map[12]; // N+S+W -> tile 27
        case 26:  return gm_autotile_map[13]; // N+E+W -> tile 19
        case 90:  return gm_autotile_map[14]; // N+E+S+W -> tile 25
        
        default:
            // For unmapped patterns, return tile 26 as fallback (isolated tile appearance)
            show_debug_message("Using isolated tile fallback for unknown mask " + string(neighbor_mask) + " -> tile 26");
            return 26;
    }
}

// Place an autotile at the specified grid position using GameMaker's autotile system
function place_autotile(grid_x, grid_y, layer_id) {
    var tilemap_id = layer_tilemap_get_id(layer_id);
    
    // Get the neighbor mask for this position
    var mask = get_neighbor_mask(grid_x, grid_y, layer_id);
    
    // Get the appropriate tile index from the autotile configuration
    var tile_index = get_autotile_index(mask);

    
    // Place the tile using tilemap_set_at_pixel
    tilemap_set_at_pixel(tilemap_id, tile_index, grid_x * 32, grid_y * 32);
    
    show_debug_message("Placed autotile at (" + string(grid_x) + ", " + string(grid_y) + ") with mask " + string(mask) + " -> tile " + string(tile_index));
    
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

// Generate random tiles at specified percentage of room coverage
function generate_random_tiles(percentage, layer_id) {
    var room_grid_width = room_width div 32;
    var room_grid_height = room_height div 32;
    var total_tiles = room_grid_width * room_grid_height;
    var tiles_to_place = floor(total_tiles * (percentage / 100));
    
    var tilemap_id = layer_tilemap_get_id(layer_id);
    var placed_positions = [];
    var placed_count = 0;
    var max_attempts = tiles_to_place * 10; // Prevent infinite loops
    var attempts = 0;
    
    show_debug_message("Generating " + string(tiles_to_place) + " random tiles (" + string(percentage) + "% of " + string(total_tiles) + " total)");
    show_debug_message("Current entities: " + string(instance_number(obj_player)) + " players, " + string(instance_number(obj_enemy)) + " enemies");
    
    while (placed_count < tiles_to_place && attempts < max_attempts) {
        attempts++;
        
        // Generate random grid position
        var grid_x = irandom(room_grid_width - 1);
        var grid_y = irandom(room_grid_height - 1);
        
        // Check if position is already occupied by a tile
        var existing_tile = tilemap_get_at_pixel(tilemap_id, grid_x * 32, grid_y * 32);
        if (existing_tile != 0) {
            continue; // Position already has a tile
        }
        
        // Check if position is occupied by game objects (player/enemies)
        // Use a more relaxed check - only avoid exact grid overlaps
        var blocked = false;
        
        // Check for player at this exact grid position
        with (obj_player) {
            var player_grid_x = x div 32;
            var player_grid_y = y div 32;
            if (player_grid_x == grid_x && player_grid_y == grid_y) {
                blocked = true;
                break;
            }
        }
        
        // Check for enemies at this exact grid position
        if (!blocked) {
            with (obj_enemy) {
                var enemy_grid_x = x div 32;
                var enemy_grid_y = y div 32;
                if (enemy_grid_x == grid_x && enemy_grid_y == grid_y) {
                    blocked = true;
                    break;
                }
            }
        }
        
        if (blocked) {
            continue; // Position is blocked by game objects
        }
        
        // Place a basic tile (we'll autotile it after)
        var basic_tile_data = tile_set_index(0, 1); // Use tile index 1 as base
        tilemap_set_at_pixel(tilemap_id, basic_tile_data, grid_x * 32, grid_y * 32);
        
        show_debug_message("Placed base tile at (" + string(grid_x) + ", " + string(grid_y) + ")");
        
        // Track placed position
        array_push(placed_positions, [grid_x, grid_y]);
        placed_count++;
    }
    
    show_debug_message("Placed " + string(placed_count) + " tiles in " + string(attempts) + " attempts");
    
    // Now apply autotiling to all placed tiles and update their neighbors
    show_debug_message("Starting autotiling pass for " + string(array_length(placed_positions)) + " tiles");
    for (var i = 0; i < array_length(placed_positions); i++) {
        var pos = placed_positions[i];
        show_debug_message("Autotiling tile " + string(i+1) + "/" + string(array_length(placed_positions)) + " at (" + string(pos[0]) + ", " + string(pos[1]) + ")");
        update_autotiles_around(pos[0], pos[1], layer_id);
    }
    
    show_debug_message("Autotiling complete for " + string(array_length(placed_positions)) + " tiles");
    
    return placed_count;
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