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

// Crew type constants for encounters
#macro CREW_ENGINEER 0
#macro CREW_NAVIGATOR 1
#macro CREW_GUNNER 2
#macro CREW_MEDIC 3
#macro CREW_SCIENTIST 4

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
    
    // Generate exploration sites first
    var exploration_sites = generate_exploration_sites(planet_type, level);
    
    // Generate planet-specific data
    var planet_data = {
        type_id: planet_type_id,
        type_data: planet_type,
        level: level,
        name: generate_planet_name(planet_type, level),
        danger_rating: level,
        resource_quality: level,
        exploration_sites: exploration_sites,
        resource_pools: calculate_resource_pools(exploration_sites),
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

// Calculate total resource pools from exploration sites
function calculate_resource_pools(exploration_sites) {
    var pools = {
        fuel: 0,
        materials: 0,
        intel: 0,
        crew: 0
    };
    
    // Aggregate resources from all exploration sites
    for (var i = 0; i < array_length(exploration_sites); i++) {
        var site = exploration_sites[i];
        for (var j = 0; j < array_length(site.resources); j++) {
            var resource = site.resources[j];
            
            // Map resource types to pool categories
            switch (resource.type) {
                case RESOURCE_CONSUMABLE:
                    pools.fuel += resource.quality;
                    break;
                case RESOURCE_MATERIAL:
                    pools.materials += resource.quality;
                    break;
                case RESOURCE_INTEL:
                    pools.intel += resource.quality;
                    break;
                case RESOURCE_CREW:
                    pools.crew += resource.quality;
                    break;
                case RESOURCE_UPGRADE:
                    // Upgrades contribute to materials
                    pools.materials += resource.quality;
                    break;
                default:
                    pools.materials += resource.quality;
                    break;
            }
        }
    }
    
    return pools;
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

// Generate appropriate planet names
function generate_planet_name(planet_type, level) {
    var desert_prefixes = ["Arid", "Dusty", "Scorched", "Barren", "Burning", "Sandy"];
    var desert_suffixes = ["Prime", "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Theta"];
    var desert_names = ["Tatooine", "Arrakis", "Kharak", "Jakku", "Jedha", "Geonosis"];
    
    var forest_prefixes = ["Verdant", "Lush", "Wild", "Green", "Living", "Fertile"];
    var forest_suffixes = ["Prime", "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Theta"];
    var forest_names = ["Endor", "Dagobah", "Yavin", "Kashyyyk", "Felucia", "Takodana"];
    
    switch (planet_type.biome) {
        case "desert":
            // Mix of sci-fi references and generated names
            if (irandom(100) < 30) {
                // Use a classic desert planet name
                return desert_names[irandom(array_length(desert_names) - 1)] + " " + roman_numeral(level);
            } else {
                // Generate a name
                var prefix = desert_prefixes[irandom(array_length(desert_prefixes) - 1)];
                var suffix = desert_suffixes[irandom(array_length(desert_suffixes) - 1)];
                return prefix + " " + suffix;
            }
            
        case "forest":
            // Mix of sci-fi references and generated names
            if (irandom(100) < 30) {
                // Use a classic forest planet name
                return forest_names[irandom(array_length(forest_names) - 1)] + " " + roman_numeral(level);
            } else {
                // Generate a name
                var prefix = forest_prefixes[irandom(array_length(forest_prefixes) - 1)];
                var suffix = forest_suffixes[irandom(array_length(forest_suffixes) - 1)];
                return prefix + " " + suffix;
            }
            
        default:
            // Fallback for unknown biomes
            return planet_type.name + " " + roman_numeral(level);
    }
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
    
    // Tile mappings by function (arrays for variety)
    desert_config.tiles = {};
    desert_config.tiles.base = [148, 85, 108];      // Sand tiles variety
    desert_config.tiles.feature = [74, 75, 76];      // Rock formations variety
    desert_config.tiles.center = [184, 185];         // Ancient ruins variety
    desert_config.tiles.rare = [164, 165, 166];      // Rare artifacts variety
    
    // Generation probabilities
    desert_config.probabilities = {};
    desert_config.probabilities.base = 60;     // 60% chance for base terrain
    desert_config.probabilities.feature = 30;  // 30% chance for features
    desert_config.probabilities.rare = 10;     // 10% chance for rare tiles
    
    // Tile descriptions for debugging
    desert_config.descriptions = {};
    desert_config.descriptions[$ "148"] = "Sand Dune";
    desert_config.descriptions[$ "149"] = "Sandy Rocks";
    desert_config.descriptions[$ "150"] = "Desert Floor";
    desert_config.descriptions[$ "74"] = "Rock Formation";
    desert_config.descriptions[$ "75"] = "Stone Outcrop";
    desert_config.descriptions[$ "76"] = "Boulder Field";
    desert_config.descriptions[$ "184"] = "Ancient Ruins";
    desert_config.descriptions[$ "185"] = "Desert Temple";
    desert_config.descriptions[$ "164"] = "Rare Artifact";
    desert_config.descriptions[$ "165"] = "Crystal Formation";
    desert_config.descriptions[$ "166"] = "Ancient Obelisk";
    
    global.planet_tile_config[$ "desert"] = desert_config;
    
    // Forest World Tile Configuration  
    var forest_config = {};
    forest_config.biome_name = "Forest";
    forest_config.color = c_lime;
    
    // Tile mappings by function (arrays for variety)
    forest_config.tiles = {};
    forest_config.tiles.base = [7, 8, 9];        // Forest tiles variety  
    forest_config.tiles.feature = [10, 11, 12];  // Clearing/grass variety
    forest_config.tiles.center = [13, 14];       // Ancient tree variety
    forest_config.tiles.rare = [15, 16, 17];     // Rare forest features
    
    // Generation probabilities
    forest_config.probabilities = {};
    forest_config.probabilities.base = 70;     // 70% chance for base terrain
    forest_config.probabilities.feature = 20;  // 20% chance for features
    forest_config.probabilities.rare = 10;     // 10% chance for rare tiles
    
    // Tile descriptions for debugging
    forest_config.descriptions = {};
    forest_config.descriptions[$ "7"] = "Dense Forest";
    forest_config.descriptions[$ "8"] = "Forest Path";
    forest_config.descriptions[$ "9"] = "Tree Grove";
    forest_config.descriptions[$ "10"] = "Grass Clearing";
    forest_config.descriptions[$ "11"] = "Meadow";
    forest_config.descriptions[$ "12"] = "Wildflower Field";
    forest_config.descriptions[$ "13"] = "Ancient Tree";
    forest_config.descriptions[$ "14"] = "Elder Oak";
    forest_config.descriptions[$ "15"] = "Mushroom Circle";
    forest_config.descriptions[$ "16"] = "Sacred Grove";
    forest_config.descriptions[$ "17"] = "Forest Shrine";
    
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
    var tile_array;
    
    switch (tile_function) {
        case TILE_FUNCTION_BASE:
            tile_array = config.tiles.base;
            break;
        case TILE_FUNCTION_FEATURE:
            tile_array = config.tiles.feature;
            break;
        case TILE_FUNCTION_CENTER:
            tile_array = config.tiles.center;
            break;
        case TILE_FUNCTION_RARE:
            tile_array = config.tiles.rare;
            break;
        default:
            tile_array = config.tiles.base;
            break;
    }
    
    // Randomly select from the tile array for variety
    if (is_array(tile_array)) {
        return tile_array[irandom(array_length(tile_array) - 1)];
    } else {
        return tile_array; // Backwards compatibility for single tiles
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

// Crew Management System
function create_crew_member(crew_type, crew_name = "") {
    var crew_data = {
        type: crew_type,
        name: crew_name,
        experience: 0,
        health: 100,
        specialties: [],
        encounter_bonuses: {}
    };
    
    // Set default name if not provided
    if (crew_name == "") {
        var names = get_crew_names(crew_type);
        crew_data.name = names[irandom(array_length(names) - 1)];
    }
    
    // Set crew type-specific bonuses and specialties
    switch (crew_type) {
        case "Engineer":
            crew_data.specialties = ["Tech Repairs", "System Analysis"];
            crew_data.encounter_bonuses = {
                tech_problems: 25,
                machinery: 30,
                repairs: 35
            };
            break;
            
        case "Navigator":
            crew_data.specialties = ["Stellar Navigation", "Terrain Analysis"];
            crew_data.encounter_bonuses = {
                navigation: 30,
                exploration: 25,
                path_finding: 35
            };
            break;
            
        case "Gunner":
            crew_data.specialties = ["Combat Tactics", "Weapon Systems"];
            crew_data.encounter_bonuses = {
                combat: 35,
                intimidation: 25,
                security: 30
            };
            break;
            
        case "Medic":
            crew_data.specialties = ["Medical Treatment", "Biological Analysis"];
            crew_data.encounter_bonuses = {
                medical: 35,
                biology: 30,
                survival: 25
            };
            break;
            
        case "Scientist":
            crew_data.specialties = ["Research", "Analysis"];
            crew_data.encounter_bonuses = {
                research: 35,
                analysis: 30,
                alien_tech: 25
            };
            break;
            
        default:
            crew_data.specialties = ["General Operations"];
            crew_data.encounter_bonuses = {};
            break;
    }
    
    return crew_data;
}

function get_crew_names(crew_type) {
    switch (crew_type) {
        case "Engineer":
            return ["Chief Torres", "Lt. LaForge", "Eng. Scotty", "Tech O'Brien", "Mech Tucker"];
        case "Navigator":
            return ["Lt. Singh", "Nav. Chen", "Pilot Wash", "Com. Sulu", "Lt. Paris"];
        case "Gunner":
            return ["Sgt. Rodriguez", "Lt. Worf", "Gun. Jayne", "Sec. Tuvok", "Lt. Reed"];
        case "Medic":
            return ["Dr. McCoy", "Med. Crusher", "Doc Holiday", "Dr. Bashir", "Med. Phlox"];
        case "Scientist":
            return ["Dr. Spock", "Sci. Data", "Dr. McKay", "Lt. Jadzia", "Ens. Sato"];
        default:
            return ["Crew Member"];
    }
}

// Planet Encounter System
function generate_planet_encounter(planet_data, selected_crew) {
    var encounter = {
        title: "",
        description: "",
        stage: 0, // Current encounter stage
        stages: [], // Array of encounter stages
        outcomes: [], // Possible outcomes based on choices
        planet_type: planet_data.type_id,
        hostility_level: irandom(3), // 0=peaceful, 1=cautious, 2=hostile, 3=dangerous
        selected_crew: selected_crew
    };
    
    // Generate encounter based on planet type
    switch (planet_data.type_id) {
        case PLANET_DESERT:
            encounter = generate_desert_encounter(encounter);
            break;
        case PLANET_FOREST:
            encounter = generate_forest_encounter(encounter);
            break;
        default:
            encounter = generate_generic_encounter(encounter);
            break;
    }
    
    // Filter all stages to only include available choices
    encounter = filter_encounter_choices(encounter, selected_crew);
    
    return encounter;
}

// Filter encounter choices to only show options for available crew
function filter_encounter_choices(encounter, selected_crew) {
    // Build list of available crew types
    var available_crew_types = [];
    for (var i = 0; i < array_length(selected_crew); i++) {
        array_push(available_crew_types, selected_crew[i].type);
    }
    
    // Filter each stage's choices
    for (var s = 0; s < array_length(encounter.stages); s++) {
        var stage = encounter.stages[s];
        var filtered_choices = [];
        
        for (var c = 0; c < array_length(stage.choices); c++) {
            var choice = stage.choices[c];
            var crew_required = choice.crew_bonus;
            
            // Always include "none" choices (no crew bonus required)
            if (crew_required == "none") {
                array_push(filtered_choices, choice);
                continue;
            }
            
            // Include choice only if required crew type is available
            var crew_available = false;
            for (var t = 0; t < array_length(available_crew_types); t++) {
                if (available_crew_types[t] == crew_required) {
                    crew_available = true;
                    break;
                }
            }
            
            if (crew_available) {
                array_push(filtered_choices, choice);
            }
        }
        
        // Update stage with filtered choices
        stage.choices = filtered_choices;
        
        show_debug_message("Stage " + string(s + 1) + ": " + string(array_length(filtered_choices)) + " choices available");
    }
    
    return encounter;
}

function generate_desert_encounter(encounter) {
    var templates = [
        {
            title: "Ancient Ruins Discovery",
            description: "Your team discovers weathered stone structures partially buried in the desert sand. Strange energy readings emanate from within.",
            stages: [
                {
                    question: "How do you approach the ruins?",
                    choices: [
                        { text: "Send Engineer to scan the energy source", crew_bonus: "Engineer", bonus_type: "tech_problems", difficulty: 60 },
                        { text: "Have Navigator chart safe entry routes", crew_bonus: "Navigator", bonus_type: "path_finding", difficulty: 70 },
                        { text: "Proceed cautiously without equipment", crew_bonus: "none", bonus_type: "", difficulty: 85 }
                    ]
                },
                {
                    question: "Inside, you find an active alien console. What's your next move?",
                    choices: [
                        { text: "Engineer attempts to interface with it", crew_bonus: "Engineer", bonus_type: "alien_tech", difficulty: 50 },
                        { text: "Scientist analyzes the technology first", crew_bonus: "Scientist", bonus_type: "research", difficulty: 40 },
                        { text: "Retreat and report the discovery", crew_bonus: "none", bonus_type: "", difficulty: 20 }
                    ]
                }
            ]
        },
        {
            title: "Sandstorm Emergency",
            description: "A massive sandstorm suddenly engulfs your landing party. Visibility drops to zero and equipment begins to malfunction.",
            stages: [
                {
                    question: "The storm is intensifying. How do you ensure survival?",
                    choices: [
                        { text: "Navigator uses instruments to find shelter", crew_bonus: "Navigator", bonus_type: "navigation", difficulty: 55 },
                        { text: "Engineer rigs emergency beacon", crew_bonus: "Engineer", bonus_type: "tech_problems", difficulty: 65 },
                        { text: "Find natural cover and wait it out", crew_bonus: "none", bonus_type: "", difficulty: 80 }
                    ]
                }
            ]
        },
        {
            title: "Crashed Ship Investigation",
            description: "You discover the wreckage of an unknown vessel half-buried in a sand dune. The hull appears to be of alien origin.",
            stages: [
                {
                    question: "How do you investigate the wreckage?",
                    choices: [
                        { text: "Engineer examines the propulsion system", crew_bonus: "Engineer", bonus_type: "machinery", difficulty: 45 },
                        { text: "Scientist studies the alien materials", crew_bonus: "Scientist", bonus_type: "analysis", difficulty: 50 },
                        { text: "Search for survivors or cargo", crew_bonus: "none", bonus_type: "", difficulty: 75 }
                    ]
                }
            ]
        }
    ];
    
    var selected_template = templates[irandom(array_length(templates) - 1)];
    encounter.title = selected_template.title;
    encounter.description = selected_template.description;
    encounter.stages = selected_template.stages;
    
    return encounter;
}

function generate_forest_encounter(encounter) {
    var templates = [
        {
            title: "Wildlife Sanctuary",
            description: "Your team enters a clearing where exotic alien creatures graze peacefully. Some appear intelligent and watch you with curious eyes.",
            stages: [
                {
                    question: "How do you approach these potentially intelligent beings?",
                    choices: [
                        { text: "Scientist attempts peaceful communication", crew_bonus: "Scientist", bonus_type: "biology", difficulty: 35 },
                        { text: "Medic assesses their physiology from distance", crew_bonus: "Medic", bonus_type: "medical", difficulty: 50 },
                        { text: "Maintain distance and observe behavior", crew_bonus: "none", bonus_type: "", difficulty: 70 }
                    ]
                },
                {
                    question: "One creature approaches and seems to be offering something. What do you do?",
                    choices: [
                        { text: "Accept the offering carefully", crew_bonus: "Medic", bonus_type: "biology", difficulty: 45 },
                        { text: "Gunner provides security while others interact", crew_bonus: "Gunner", bonus_type: "security", difficulty: 60 },
                        { text: "Politely decline and withdraw", crew_bonus: "none", bonus_type: "", difficulty: 30 }
                    ]
                }
            ]
        },
        {
            title: "Overgrown Research Station",
            description: "Vines and massive trees have reclaimed what was once a scientific outpost. Power cores still glow faintly through the vegetation.",
            stages: [
                {
                    question: "How do you access the overgrown facility?",
                    choices: [
                        { text: "Engineer attempts to restore power systems", crew_bonus: "Engineer", bonus_type: "repairs", difficulty: 55 },
                        { text: "Navigator finds safe passage through debris", crew_bonus: "Navigator", bonus_type: "path_finding", difficulty: 60 },
                        { text: "Cut through vegetation carefully", crew_bonus: "none", bonus_type: "", difficulty: 85 }
                    ]
                },
                {
                    question: "You discover active research logs. What's your priority?",
                    choices: [
                        { text: "Scientist analyzes the research data", crew_bonus: "Scientist", bonus_type: "research", difficulty: 30 },
                        { text: "Engineer salvages the equipment", crew_bonus: "Engineer", bonus_type: "machinery", difficulty: 50 },
                        { text: "Medic checks for biological contamination", crew_bonus: "Medic", bonus_type: "biology", difficulty: 40 }
                    ]
                }
            ]
        },
        {
            title: "Toxic Plant Encounter",
            description: "Colorful but menacing plants block your path forward. Some crew members report mild dizziness from the spores in the air.",
            stages: [
                {
                    question: "The spores are affecting your team. How do you proceed?",
                    choices: [
                        { text: "Medic provides immediate treatment", crew_bonus: "Medic", bonus_type: "medical", difficulty: 40 },
                        { text: "Engineer rigs air filtration system", crew_bonus: "Engineer", bonus_type: "tech_problems", difficulty: 65 },
                        { text: "Push through quickly before effects worsen", crew_bonus: "none", bonus_type: "", difficulty: 90 }
                    ]
                }
            ]
        }
    ];
    
    var selected_template = templates[irandom(array_length(templates) - 1)];
    encounter.title = selected_template.title;
    encounter.description = selected_template.description;
    encounter.stages = selected_template.stages;
    
    return encounter;
}

function generate_generic_encounter(encounter) {
    encounter.title = "Unknown Planet Survey";
    encounter.description = "Your team conducts a standard survey of this unexplored world.";
    encounter.stages = [
        {
            question: "How do you approach the survey?",
            choices: [
                { text: "Systematic scientific approach", crew_bonus: "Scientist", bonus_type: "research", difficulty: 50 },
                { text: "Quick resource scan", crew_bonus: "Engineer", bonus_type: "analysis", difficulty: 60 },
                { text: "Basic visual survey", crew_bonus: "none", bonus_type: "", difficulty: 80 }
            ]
        }
    ];
    
    return encounter;
}

// Encounter Resolution System
function resolve_encounter_choice(encounter, stage_index, choice_index, selected_crew) {
    if (stage_index >= array_length(encounter.stages)) {
        show_debug_message("Warning: Invalid stage index in encounter resolution");
        return { success: false, message: "Invalid encounter stage" };
    }
    
    var stage = encounter.stages[stage_index];
    if (choice_index >= array_length(stage.choices)) {
        show_debug_message("Warning: Invalid choice index in encounter resolution");
        return { success: false, message: "Invalid choice" };
    }
    
    var choice = stage.choices[choice_index];
    var base_difficulty = choice.difficulty;
    var final_difficulty = base_difficulty;
    
    // Apply crew bonuses
    var crew_bonus = 0;
    if (choice.crew_bonus != "none" && choice.bonus_type != "") {
        for (var i = 0; i < array_length(selected_crew); i++) {
            var crew_member = selected_crew[i];
            if (crew_member.type == choice.crew_bonus) {
                if (variable_struct_exists(crew_member.encounter_bonuses, choice.bonus_type)) {
                    crew_bonus += crew_member.encounter_bonuses[$ choice.bonus_type];
                    show_debug_message(crew_member.name + " (" + crew_member.type + ") provides +" + string(crew_member.encounter_bonuses[$ choice.bonus_type]) + "% to " + choice.bonus_type);
                }
            }
        }
    }
    
    final_difficulty = max(5, base_difficulty - crew_bonus); // Minimum 5% failure chance
    
    // Roll for success (lower roll = success)
    var roll = irandom(99) + 1; // 1-100
    var success = roll <= (100 - final_difficulty);
    
    var result = {
        success: success,
        roll: roll,
        difficulty: final_difficulty,
        crew_bonus: crew_bonus,
        choice_text: choice.text,
        stage_index: stage_index,
        choice_index: choice_index
    };
    
    show_debug_message("Encounter resolution: Roll " + string(roll) + " vs difficulty " + string(final_difficulty) + " = " + (success ? "SUCCESS" : "FAILURE"));
    
    return result;
}

// Calculate encounter rewards based on success/failure and encounter type
function calculate_encounter_rewards(encounter, resolution_results, planet_data) {
    var rewards = {
        resources: { fuel: 0, materials: 0, intel: 0, crew: 0 },
        crew_changes: [],
        ship_healing: 0,
        experience_gained: 0,
        message: ""
    };
    
    var total_successes = 0;
    var total_failures = 0;
    
    // Count successes and failures
    for (var i = 0; i < array_length(resolution_results); i++) {
        if (resolution_results[i].success) {
            total_successes++;
        } else {
            total_failures++;
        }
    }
    
    var success_ratio = total_successes / array_length(resolution_results);
    
    // Base reward calculation based on planet level and success ratio
    var base_reward = planet_data.level;
    var reward_multiplier = 1.0 + (success_ratio * 0.5); // Up to 50% bonus for perfect success
    
    // Encounter type specific rewards
    switch (encounter.planet_type) {
        case PLANET_DESERT:
            if (success_ratio >= 0.5) {
                rewards.resources.materials = floor(base_reward * reward_multiplier);
                if (success_ratio == 1.0) {
                    rewards.resources.intel = 1;
                    rewards.message = "Your team successfully navigates the desert challenges and discovers valuable materials and ancient data.";
                } else {
                    rewards.message = "Despite some setbacks, your team recovers useful materials from the desert.";
                }
            } else {
                rewards.ship_healing = -1; // Equipment damage from harsh conditions
                rewards.message = "The harsh desert conditions damage your equipment and exhaust your crew.";
            }
            break;
            
        case PLANET_FOREST:
            if (success_ratio >= 0.5) {
                rewards.resources.fuel = floor(base_reward * reward_multiplier);
                if (success_ratio == 1.0) {
                    // Chance to recruit local wildlife expert as crew
                    if (irandom(100) < 30) {
                        var new_crew = {
                            type: "recruit",
                            name: "Forest Guide",
                            source: "planet_encounter"
                        };
                        array_push(rewards.crew_changes, new_crew);
                        rewards.message = "Your diplomatic approach pays off! The forest dwellers share their resources and one of them joins your crew.";
                    } else {
                        rewards.message = "Your respectful approach to the forest ecosystem yields valuable organic resources.";
                    }
                } else {
                    rewards.message = "Your crew manages to gather some resources despite encountering difficulties.";
                }
            } else {
                // Crew injury from hostile wildlife/toxins
                for (var j = 0; j < array_length(encounter.selected_crew); j++) {
                    if (irandom(100) < 50) {
                        var crew_injury = {
                            type: "injury",
                            crew_index: j,
                            health_loss: 10 + irandom(20)
                        };
                        array_push(rewards.crew_changes, crew_injury);
                    }
                }
                rewards.message = "Your crew suffers injuries from the hostile forest environment.";
            }
            break;
            
        default:
            // Generic encounter rewards
            if (success_ratio >= 0.5) {
                rewards.resources.materials = floor(base_reward * 0.5);
                rewards.resources.fuel = floor(base_reward * 0.5);
                rewards.message = "Your survey mission yields modest resources.";
            } else {
                rewards.message = "The survey mission encounters unexpected difficulties.";
            }
            break;
    }
    
    // Experience for all crew members who participated
    rewards.experience_gained = floor(5 * (1 + success_ratio));
    
    return rewards;
}

// Apply encounter rewards to player and crew
function apply_encounter_rewards(rewards) {
    var player = instance_find(obj_player, 0);
    if (player == noone) {
        show_debug_message("Warning: No player found to apply rewards to");
        return;
    }
    
    // Apply ship healing/damage
    if (rewards.ship_healing != 0) {
        var old_hp = player.hp;
        if (rewards.ship_healing > 0) {
            player.hp = min(player.hp + rewards.ship_healing, player.hp_max);
            show_debug_message("Ship healed: " + string(old_hp) + " -> " + string(player.hp));
        } else {
            player.hp = max(1, player.hp + rewards.ship_healing);
            show_debug_message("Ship damaged: " + string(old_hp) + " -> " + string(player.hp));
        }
    }
    
    // Apply crew changes (injuries, new recruits)
    for (var i = 0; i < array_length(rewards.crew_changes); i++) {
        var crew_change = rewards.crew_changes[i];
        
        if (crew_change.type == "injury" && crew_change.crew_index < array_length(player.crew_roster)) {
            var crew_member = player.crew_roster[crew_change.crew_index];
            var old_health = crew_member.health;
            crew_member.health = max(0, crew_member.health - crew_change.health_loss);
            show_debug_message(crew_member.name + " injured: " + string(old_health) + "% -> " + string(crew_member.health) + "% health");
        } else if (crew_change.type == "recruit") {
            // Add new crew member
            var new_crew = create_crew_member("Scientist", crew_change.name); // Forest guides are scientists
            player.add_crew_member_direct(new_crew);
            show_debug_message("New crew member recruited: " + crew_change.name);
        }
    }
    
    // Apply experience to selected crew
    if (variable_struct_exists(player, "selected_crew")) {
        for (var j = 0; j < array_length(player.selected_crew); j++) {
            var crew_index = player.selected_crew[j];
            if (crew_index < array_length(player.crew_roster)) {
                player.crew_roster[crew_index].experience += rewards.experience_gained;
                show_debug_message(player.crew_roster[crew_index].name + " gained " + string(rewards.experience_gained) + " experience");
            }
        }
    }
    
    // Log resource gains (these would be stored in global variables or player inventory)
    var resource_names = struct_get_names(rewards.resources);
    for (var k = 0; k < array_length(resource_names); k++) {
        var resource_name = resource_names[k];
        var amount = rewards.resources[$ resource_name];
        if (amount > 0) {
            show_debug_message("Gained " + string(amount) + " " + resource_name);
        }
    }
    
    show_debug_message("Encounter rewards applied: " + rewards.message);
    
    // Mark planet as visited
    if (variable_global_exists("current_planet_instance") && global.current_planet_instance != noone) {
        var planet_obj = global.current_planet_instance;
        if (instance_exists(planet_obj)) {
            // Initialize visited flag if it doesn't exist (for existing planets)
            if (!variable_instance_exists(planet_obj, "visited")) {
                planet_obj.visited = false;
                show_debug_message("Initialized visited flag for existing planet");
            }
            
            // Set visited flag and track which level this visit occurred on
            planet_obj.visited = true;
            planet_obj.visited_level = global.current_level;
            show_debug_message("Planet marked as visited for level " + string(global.current_level) + " - no more encounters available this level");
        }
    }
}