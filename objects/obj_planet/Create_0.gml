// Initialize planet system if needed
if (!variable_global_exists("planet_types")) {
    init_planet_system();
}

// Initialize planet tile configuration if needed
init_planet_tile_config();

// Set planet level based on current game level
level = global.current_level;

// Generate planet data based on level
planet_data = generate_planet_data(level);

// Set visual appearance based on planet type
image_speed = 0;
image_index = planet_data.type_id; // Use planet type for sprite frame

// Get color from tile configuration
var biome_config = get_biome_config(planet_data.type_data.biome);
image_blend = biome_config.color; // Tint planet with biome color

// Landing confirmation tracking
landing_triggered = false;

show_debug_message("Created " + planet_data.name + " (" + planet_data.type_data.name + ") at level " + string(level));

