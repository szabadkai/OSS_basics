// Planet Surface Generator - creates varied terrain on planet surface
show_debug_message("Planet Surface Generator starting...");

// Planet surface generation parameters
terrain_coverage = 60; // Percentage of surface covered with terrain
water_coverage = 20;   // Percentage covered with water features
vegetation_coverage = 30; // Percentage covered with vegetation

// Generate different terrain types
generate_planet_surface = function() {
    show_debug_message("Generating planet surface terrain...");
    
    // Ensure the planet tile layer exists
    if (!layer_exists("Tiles_Planet")) {
        show_debug_message("Creating Tiles_Planet layer...");
        create_planet_tile_layer();
    }
    
    // Get the tilemap
    var tilemap_id = layer_tilemap_get_id("Tiles_Planet");
    if (tilemap_id == -1) {
        show_debug_message("Error: No tilemap found on Tiles_Planet layer");
        return 0;
    }
    
    // Clear any existing tiles first
    tilemap_clear(tilemap_id, 0);
    show_debug_message("Cleared existing planet tiles");
    
    // Generate base terrain (rocks, dirt, metal deposits)
    var base_tiles = generate_random_tiles(terrain_coverage, "Tiles_Planet");
    show_debug_message("Generated " + string(base_tiles) + " base terrain tiles");
    
    // Apply autotiling to make terrain look natural
    if (base_tiles > 0) {
        apply_autotiling_to_layer("Tiles_Planet");
        show_debug_message("Applied autotiling to planet surface");
    }
    
    var total_tiles = base_tiles;
    show_debug_message("Planet surface generation complete. Total tiles: " + string(total_tiles));
    
    return total_tiles;
};

// Create planet-specific tile layer if it doesn't exist
create_planet_tile_layer = function() {
    if (!layer_exists("Tiles_Planet")) {
        show_debug_message("Creating Tiles_Planet layer...");
        var layer_id = layer_create(50, "Tiles_Planet");
        var tilemap_id = layer_tilemap_create(layer_id, 0, 0, PlanetTiles, room_width div 32, room_height div 32);
        show_debug_message("Created planet tile layer with tilemap ID: " + string(tilemap_id));
        return layer_id;
    } else {
        show_debug_message("Tiles_Planet layer already exists");
        return layer_get_id("Tiles_Planet");
    }
};

// Initialize and generate the planet surface
var planet_layer = create_planet_tile_layer();
generate_planet_surface();