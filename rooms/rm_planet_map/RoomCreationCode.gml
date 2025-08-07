// Planet Map Room Creation Code
show_debug_message("Planet map room started - generating planet surface");

// Disable turn manager on planet (prevent win condition from triggering)
var turn_manager = instance_find(obj_turn_manager, 0);
if (turn_manager != noone) {
    turn_manager.game_state = "planet_exploration";
    show_debug_message("Set turn manager to planet exploration mode");
}

// Generate 16x9 tile grid in center of planet room using layered approach
if (layer_exists("Tiles_Base") && layer_exists("Tiles_Planet")) {
    show_debug_message("Generating 16x9 planet surface in center with layered tiles...");
    
    var base_tilemap_id = layer_tilemap_get_id("Tiles_Base");
    var feature_tilemap_id = layer_tilemap_get_id("Tiles_Planet");
    
    if (base_tilemap_id != -1 && feature_tilemap_id != -1) {
        // Ensure Tiles_Base layer has the same tileset as Tiles_Planet
        var base_tileset = tilemap_get_tileset(base_tilemap_id);
        var feature_tileset = tilemap_get_tileset(feature_tilemap_id);
        if (base_tileset != feature_tileset) {
            tilemap_tileset(base_tilemap_id, feature_tileset);
            show_debug_message("Set Tiles_Base to use same tileset as Tiles_Planet");
        }
        
        // Clear existing tiles on both layers
        tilemap_clear(base_tilemap_id, 0);
        tilemap_clear(feature_tilemap_id, 0);
        
        // Get room dimensions in 16px tile units (since Tiles_Planet uses 16px grid)
        var tile_width = room_width div 16;
        var tile_height = room_height div 16;
        
        show_debug_message("Planet room: " + string(room_width) + "x" + string(room_height) + " = " + string(tile_width) + "x" + string(tile_height) + " tiles");
        
        // Calculate center position for 16x9 grid
        var center_x = tile_width div 2;
        var center_y = tile_height div 2;
        
        // Define 16x9 area (16 tiles wide, 9 tiles tall)
        var grid_width = 16;
        var grid_height = 9;
        var start_x = center_x - (grid_width div 2);
        var start_y = center_y - (grid_height div 2);
        var end_x = start_x + grid_width - 1;
        var end_y = start_y + grid_height - 1;
        
        // Ensure we stay within bounds
        start_x = max(0, start_x);
        start_y = max(0, start_y);
        end_x = min(tile_width - 1, end_x);
        end_y = min(tile_height - 1, end_y);
        
        // Get planet information for generation
        var placed_count = 0;
        var biome_name = "desert"; // Default fallback
        var planet_type_name = "Unknown";
        
        if (variable_global_exists("current_planet")) {
            var planet = global.current_planet;
            if (variable_struct_exists(planet, "data") && variable_struct_exists(planet.data, "type_data")) {
                if (variable_struct_exists(planet.data.type_data, "biome")) {
                    biome_name = planet.data.type_data.biome;
                }
                if (variable_struct_exists(planet.data.type_data, "name")) {
                    planet_type_name = planet.data.type_data.name;
                }
            }
        }
        
        // Generate tiles using proper layered approach: base layer and feature layer
        for (var tx = start_x; tx <= end_x; tx++) {
            for (var ty = start_y; ty <= end_y; ty++) {
                // Step 1: Always place base tile on Tiles_Base layer
                var base_tile = get_tile_for_function(biome_name, TILE_FUNCTION_BASE);
                tilemap_set(base_tilemap_id, base_tile, tx, ty);
                placed_count++;
                
                // Step 2: Determine if we should place a feature on Tiles_Planet layer
                var is_center = (tx == center_x && ty == center_y);
                var random_value = irandom(99); // 0-99 for percentage
                
                var feature_tile = -1;
                if (is_center) {
                    // Center always gets a special feature
                    feature_tile = get_tile_for_function(biome_name, TILE_FUNCTION_CENTER);
                } else {
                    // Use probability to determine feature placement
                    var tile_function = determine_tile_function(biome_name, is_center, random_value);
                    if (tile_function != TILE_FUNCTION_BASE) {
                        feature_tile = get_tile_for_function(biome_name, tile_function);
                    }
                }
                
                // Step 3: Place feature tile on Tiles_Planet layer if determined
                if (feature_tile != -1) {
                    tilemap_set(feature_tilemap_id, feature_tile, tx, ty);
                    
                    // Debug: Show what was placed at center
                    if (is_center) {
                        var tile_desc = get_tile_description(biome_name, feature_tile);
                        show_debug_message("Center feature placed: " + tile_desc + " (index " + string(feature_tile) + ") over base " + string(base_tile));
                    }
                }
            }
        }
        
        show_debug_message("Generated 16x9 " + planet_type_name + " (" + biome_name + ") surface: " + string(placed_count) + " base tiles with features at center(" + string(center_x) + ", " + string(center_y) + ")");
    } else {
        show_debug_message("Error: Could not get tilemap for one or both tile layers (Base: " + string(base_tilemap_id) + ", Planet: " + string(feature_tilemap_id) + ")");
    }
} else {
    show_debug_message("Warning: Required tile layers not found - need both Tiles_Base and Tiles_Planet for terrain generation");
}

// Create the back-to-space object so player can return by pressing B
instance_create_layer(0, 0, "Instances", ___backto);

// Create UI manager for planet info display
if (!instance_exists(obj_ui_manager)) {
    instance_create_layer(0, 0, "Instances", obj_ui_manager);
    show_debug_message("Created UI manager for planet exploration");
}

show_debug_message("Planet map initialized - auto-starting encounter");

// Auto-start encounter when entering planet
var turn_manager = instance_find(obj_turn_manager, 0);
var player = instance_find(obj_player, 0);

if (turn_manager != noone && player != noone) {
    // Check if we have the necessary data to start encounter
    if (turn_manager.game_state == "planet_exploration" && 
        variable_global_exists("current_planet") && 
        global.current_planet != noone &&
        array_length(player.selected_crew) >= 2) {
        
        // Auto-start encounter with selected crew
        if (turn_manager.start_encounter(global.current_planet.data, player.selected_crew)) {
            show_debug_message("Planet encounter auto-started successfully");
        } else {
            show_debug_message("Failed to auto-start encounter - check planet data");
        }
    } else {
        show_debug_message("Cannot auto-start encounter - missing requirements:");
        show_debug_message("- Game state: " + string(turn_manager.game_state) + " (need planet_exploration)");
        show_debug_message("- Current planet: " + string(variable_global_exists("current_planet") ? "exists" : "missing"));
        show_debug_message("- Selected crew: " + string(array_length(player.selected_crew)) + " (need 2+)");
    }
} else {
    show_debug_message("Cannot find turn manager or player for auto-encounter");
}