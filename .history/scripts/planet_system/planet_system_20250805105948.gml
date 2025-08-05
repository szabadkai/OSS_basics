// Planet System - Comprehensive planet type system for roguelike space exploration

// Planet type constants (simplified)
#macro PLANET_DESERT 0
#macro PLANET_FOREST 1

// Resource type constants  
#macro RESOURCE_UPGRADE 0
#macro RESOURCE_CONSUMABLE 1
#macro RESOURCE_MATERIAL 2
#macro RESOURCE_INTEL 3
#macro RESOURCE_CREW 4

// Initialize planet system (simplified - Desert and Forest only)
function init_planet_system() {
    global.planet_types = [];
    
    // Ensure planet tile configuration is initialized
    init_planet_tile_config();
    
    // Desert Worlds - Level 1+
    array_push(global.planet_types, {
        id: PLANET_DESERT,
        biome: "desert",  // Key for tile configuration
        name: "Desert World",
        description: "Harsh desert with rare minerals and ancient ruins",
        common_resources: [RESOURCE_MATERIAL, RESOURCE_UPGRADE],
        rare_resources: [RESOURCE_INTEL],
        hazards: ["Heat Damage", "Sandstorms", "Solar Radiation"],
        unlock_level: 1,
        site_names: ["Ancient Ruins", "Mining Station", "Crashed Ship", "Oasis Settlement", "Sand Crawler Wreck"]
    });
    
    // Forest Worlds - Level 2+
    array_push(global.planet_types, {
        id: PLANET_FOREST,
        biome: "forest",  // Key for tile configuration
        name: "Forest World",
        description: "Lush biosphere with diverse wildlife and organic resources", 
        common_resources: [RESOURCE_CONSUMABLE, RESOURCE_CREW],
        rare_resources: [RESOURCE_MATERIAL],
        hazards: ["Hostile Wildlife", "Toxic Plants", "Dense Canopy"],
        unlock_level: 2,
        site_names: ["Ancient Grove", "Crashed Pod", "Wildlife Sanctuary", "Overgrown Base", "Sacred Tree"]
    });
    
    show_debug_message("Planet system initialized with " + string(array_length(global.planet_types)) + " planet types (Desert & Forest)");
}

// Get available planet types for current level
function get_available_planet_types(level) {
    // Ensure planet system is initialized
    if (!variable_global_exists("planet_types")) {
        init_planet_system();
    }
    
    var available = [];
    
    for (var i = 0; i < array_length(global.planet_types); i++) {
        var planet_type = global.planet_types[i];
        if (level >= planet_type.unlock_level) {
            array_push(available, planet_type);
        }
    }
    
    return available;
}

// Generate planet data based on level
function generate_planet_data(level, force_type_id = -1) {
    // Ensure planet system is initialized
    if (!variable_global_exists("planet_types")) {
        init_planet_system();
    }
    
    var planet_type_id;
    
    // If specific type requested, use it (if unlocked)
    if (force_type_id >= 0 && force_type_id < array_length(global.planet_types)) {
        var requested_type = global.planet_types[force_type_id];
        if (level >= requested_type.unlock_level) {
            planet_type_id = force_type_id;
        } else {
            // Fallback to random available type
            planet_type_id = -1;
        }
    } else {
        planet_type_id = -1;
    }
    
    // If no type specified or invalid, choose randomly from available types
    if (planet_type_id == -1) {
        var available_types = get_available_planet_types(level);
        if (array_length(available_types) == 0) {
            planet_type_id = PLANET_DESERT; // Fallback to desert
        } else {
            var random_type = available_types[irandom(array_length(available_types) - 1)];
            planet_type_id = random_type.id;
        }
    }
    
    var planet_type = global.planet_types[planet_type_id];
    
    // Generate planet-specific data
    var planet_data = {
        type_id: planet_type_id,
        type_data: planet_type,
        level: level,
        name: planet_type.name + " " + roman_numeral(level),
        danger_rating: level,
        resource_quality: level,
        exploration_sites: generate_exploration_sites(planet_type, level),
        discovered: false
    };
    
    return planet_data;
}

// Generate exploration sites on planet
function generate_exploration_sites(planet_type, level) {
    var sites = [];
    var site_count = 3 + irandom(2); // 3-5 sites per planet
    
    for (var i = 0; i < site_count; i++) {
        var site_name = planet_type.site_names[irandom(array_length(planet_type.site_names) - 1)];
        var site = {
            name: site_name,
            resources: generate_site_resources(planet_type, level),
            danger_level: 1 + irandom(level),
            explored: false,
            hazard: planet_type.hazards[irandom(array_length(planet_type.hazards) - 1)]
        };
        array_push(sites, site);
    }
    
    return sites;
}

// Generate resources for an exploration site
function generate_site_resources(planet_type, level) {
    var resources = [];
    var resource_count = 1 + irandom(2); // 1-3 resources per site
    
    for (var i = 0; i < resource_count; i++) {
        var is_rare = (irandom(100) < 20 + (level * 2)); // Rare chance increases with level
        var resource_pool = is_rare ? planet_type.rare_resources : planet_type.common_resources;
        
        if (array_length(resource_pool) > 0) {
            var resource_type = resource_pool[irandom(array_length(resource_pool) - 1)];
            var resource = {
                type: resource_type,
                quality: level + (is_rare ? 2 : 0),
                is_rare: is_rare,
                name: get_resource_name(resource_type, level, is_rare)
            };
            array_push(resources, resource);
        }
    }
    
    return resources;
}

// Get resource name based on type and quality
function get_resource_name(resource_type, level, is_rare) {
    var prefix = is_rare ? "Rare " : "";
    var tier = "Mk" + string(level) + " ";
    
    switch (resource_type) {
        case RESOURCE_UPGRADE:
            var upgrade_names = ["Thruster Component", "Weapon Part", "Shield Generator", "Engine Module"];
            return prefix + tier + upgrade_names[irandom(array_length(upgrade_names) - 1)];
            
        case RESOURCE_CONSUMABLE:
            var consumable_names = ["Repair Kit", "Energy Cell", "Boost Injector", "Shield Battery"];
            return prefix + tier + consumable_names[irandom(array_length(consumable_names) - 1)];
            
        case RESOURCE_MATERIAL:
            var material_names = ["Refined Metal", "Crystal Matrix", "Polymer Composite", "Exotic Matter"];
            return prefix + tier + material_names[irandom(array_length(material_names) - 1)];
            
        case RESOURCE_INTEL:
            var intel_names = ["Star Chart", "Enemy Data", "Navigation Log", "Tactical Report"];
            return prefix + intel_names[irandom(array_length(intel_names) - 1)];
            
        case RESOURCE_CREW:
            var crew_names = ["Engineer", "Navigator", "Gunner", "Medic", "Scientist"];
            return crew_names[irandom(array_length(crew_names) - 1)];
            
        default:
            return prefix + "Unknown Resource";
    }
}

// Convert number to roman numerals (for planet names)
function roman_numeral(num) {
    if (num <= 0) return "";
    if (num >= 10) return "X" + roman_numeral(num - 10);
    if (num >= 9) return "IX" + roman_numeral(num - 9);
    if (num >= 5) return "V" + roman_numeral(num - 5);
    if (num >= 4) return "IV" + roman_numeral(num - 4);
    if (num >= 1) return "I" + roman_numeral(num - 1);
    return "";
}

//=== PLANET TILE CONFIGURATION SYSTEM ===

// Tile function constants
#macro TILE_FUNCTION_BASE 0        // Basic terrain (most common)
#macro TILE_FUNCTION_FEATURE 1     // Secondary features (rocks, clearings)
#macro TILE_FUNCTION_CENTER 2      // Center focal point (ruins, ancient trees)
#macro TILE_FUNCTION_RARE 3        // Special/rare tiles

// Initialize planet tile configuration
function init_planet_tile_config() {
    if (variable_global_exists("planet_tile_config")) {
        return; // Already initialized
    }
    
    global.planet_tile_config = {};
    
    // Desert World Tile Configuration
    var desert_config = {};
    desert_config.biome_name = "Desert";
    desert_config.color = c_orange;
    
    // Tile mappings by function
    desert_config.tiles = {};
    desert_config.tiles.base = 22;      // Sand tile (most common - 60%)
    desert_config.tiles.feature = 2;   // Rock formations (30%)
    desert_config.tiles.center = 3;    // Ancient ruins (center piece)
    desert_config.tiles.rare = 3;      // Additional ruins/artifacts (10%)
    
    // Generation probabilities
    desert_config.probabilities = {};
    desert_config.probabilities.base = 60;     // 60% chance for base terrain
    desert_config.probabilities.feature = 30;  // 30% chance for features
    desert_config.probabilities.rare = 10;     // 10% chance for rare tiles
    
    // Tile descriptions for debugging
    desert_config.descriptions = {};
    desert_config.descriptions[$ "1"] = "Sand Dune";
    desert_config.descriptions[$ "2"] = "Rock Formation";
    desert_config.descriptions[$ "3"] = "Ancient Ruins";
    
    global.planet_tile_config[$ "desert"] = desert_config;
    
    // Forest World Tile Configuration  
    var forest_config = {};
    forest_config.biome_name = "Forest";
    forest_config.color = c_lime;
    
    // Tile mappings by function
    forest_config.tiles = {};
    forest_config.tiles.base = 7;      // Dense forest (most common - 70%)
    forest_config.tiles.feature = 8;   // Grass clearings (20%)
    forest_config.tiles.center = 9;    // Ancient tree (center piece)
    forest_config.tiles.rare = 9;      // Additional ancient trees (10%)
    
    // Generation probabilities
    forest_config.probabilities = {};
    forest_config.probabilities.base = 70;     // 70% chance for base terrain
    forest_config.probabilities.feature = 20;  // 20% chance for features
    forest_config.probabilities.rare = 10;     // 10% chance for rare tiles
    
    // Tile descriptions for debugging
    forest_config.descriptions = {};
    forest_config.descriptions[$ "7"] = "Dense Forest";
    forest_config.descriptions[$ "8"] = "Grass Clearing";
    forest_config.descriptions[$ "9"] = "Ancient Tree";
    
    global.planet_tile_config[$ "forest"] = forest_config;
    
    show_debug_message("Planet tile configuration initialized with " + string(struct_names_count(global.planet_tile_config)) + " biomes");
}

// Function to get tile configuration for a biome
function get_biome_config(biome_name) {
    // Ensure config is initialized
    init_planet_tile_config();
    
    if (variable_struct_exists(global.planet_tile_config, biome_name)) {
        return global.planet_tile_config[$ biome_name];
    }
    
    // Fallback to desert if biome not found
    show_debug_message("Warning: Biome '" + biome_name + "' not found, using desert fallback");
    return global.planet_tile_config[$ "desert"];
}

// Function to get tile index for a specific function in a biome
function get_tile_for_function(biome_name, tile_function) {
    var config = get_biome_config(biome_name);
    
    switch (tile_function) {
        case TILE_FUNCTION_BASE:
            return config.tiles.base;
        case TILE_FUNCTION_FEATURE:
            return config.tiles.feature;
        case TILE_FUNCTION_CENTER:
            return config.tiles.center;
        case TILE_FUNCTION_RARE:
            return config.tiles.rare;
        default:
            return config.tiles.base;
    }
}

// Function to get tile description for debugging
function get_tile_description(biome_name, tile_index) {
    var config = get_biome_config(biome_name);
    var tile_key = string(tile_index);
    
    if (variable_struct_exists(config.descriptions, tile_key)) {
        return config.descriptions[$ tile_key];
    }
    
    return "Unknown Tile " + string(tile_index);
}

// Function to determine what tile function to use based on position and probability
function determine_tile_function(biome_name, is_center, random_value) {
    if (is_center) {
        return TILE_FUNCTION_CENTER;
    }
    
    var config = get_biome_config(biome_name);
    
    // Use cumulative probability distribution
    if (random_value < config.probabilities.base) {
        return TILE_FUNCTION_BASE;
    } else if (random_value < config.probabilities.base + config.probabilities.feature) {
        return TILE_FUNCTION_FEATURE;
    } else {
        return TILE_FUNCTION_RARE;
    }
}