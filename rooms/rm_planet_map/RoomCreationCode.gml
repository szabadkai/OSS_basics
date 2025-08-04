// Planet Map Room Creation Code
show_debug_message("Planet map room started - generating planet surface");

// Disable turn manager on planet (prevent win condition from triggering)
var turn_manager = instance_find(obj_turn_manager, 0);
if (turn_manager != noone) {
    turn_manager.game_state = "planet_exploration";
    show_debug_message("Set turn manager to planet exploration mode");
}

// Generate planet surface terrain using 16px tiles
if (layer_exists("Tiles_Planet")) {
    show_debug_message("Generating terrain on planet surface...");
    
    var tilemap_id = layer_tilemap_get_id("Tiles_Planet");
    if (tilemap_id != -1) {
        // Clear existing tiles
        tilemap_clear(tilemap_id, 0);
        
        // Get room dimensions in 16px tile units
        var tile_width = room_width div 16;
        var tile_height = room_height div 16;
        var total_tiles = tile_width * tile_height;
        
        show_debug_message("Planet room: " + string(room_width) + "x" + string(room_height) + " = " + string(tile_width) + "x" + string(tile_height) + " tiles (" + string(total_tiles) + " total)");
        
        // Fill most of the surface with random tiles
        var placed_count = 0;
        for (var tx = 0; tx < tile_width; tx++) {
            for (var ty = 0; ty < tile_height; ty++) {
                // 90% chance to place a tile
                if (random(100) < 90) {
                    // Use random tile from tileset (1-based indexing, 0 = empty)
                    var tile_index = 1 + irandom(20); // Use first 21 tiles from the tileset
                    tilemap_set(tilemap_id, tile_index, tx, ty);
                    placed_count++;
                }
            }
        }
        
        show_debug_message("Generated " + string(placed_count) + " terrain tiles on planet surface");
    } else {
        show_debug_message("Error: Could not get tilemap for Tiles_Planet layer");
    }
} else {
    show_debug_message("Warning: Tiles_Planet layer not found - no terrain generated");
}

// Create the back-to-space object so player can return by pressing B
instance_create_layer(0, 0, "Instances", ___backto);

show_debug_message("Planet map initialized - press B to return to space");