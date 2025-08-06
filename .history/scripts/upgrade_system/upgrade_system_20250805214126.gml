// Ship Upgrade System - Modular upgrades for Thrusters, Weapons, and Shields

// Upgrade slot types
#macro SLOT_THRUSTER 0
#macro SLOT_WEAPON 1
#macro SLOT_SHIELD 2

// Initialize global upgrade definitions
function init_upgrade_system() {
    global.upgrades = [];
    
    // THRUSTER UPGRADES (Movement & Mobility)
    array_push(global.upgrades, {
        id: "basic_thrusters",
        name: "Basic Thrusters",
        description: "+1 Move per turn",
        slot: SLOT_THRUSTER,
        tier: 1,
        effects: { moves_bonus: 1 }
    });
    
    array_push(global.upgrades, {
        id: "boost_engines",
        name: "Boost Engines", 
        description: "+2 Moves per turn",
        slot: SLOT_THRUSTER,
        tier: 2,
        effects: { moves_bonus: 2 }
    });
    
    array_push(global.upgrades, {
        id: "agility_boosters",
        name: "Agility Boosters",
        description: "+5 Initiative (act earlier)",
        slot: SLOT_THRUSTER,
        tier: 2,
        effects: { init_bonus: 5 }
    });
    
    // WEAPON UPGRADES (Combat)
    array_push(global.upgrades, {
        id: "laser_cannon",
        name: "Laser Cannon",
        description: "+1 Damage",
        slot: SLOT_WEAPON,
        tier: 1,
        effects: { damage_bonus: 1 }
    });
    
    array_push(global.upgrades, {
        id: "plasma_rifle",
        name: "Plasma Rifle",
        description: "+2 Damage", 
        slot: SLOT_WEAPON,
        tier: 2,
        effects: { damage_bonus: 2 }
    });
    
    array_push(global.upgrades, {
        id: "chain_gun",
        name: "Chain Gun",
        description: "Attack hits all adjacent enemies",
        slot: SLOT_WEAPON,
        tier: 3,
        effects: { area_attack: true }
    });
    
    array_push(global.upgrades, {
        id: "rail_gun",
        name: "Rail Gun",
        description: "Long range straight line attack",
        slot: SLOT_WEAPON,
        tier: 2,
        effects: { 
            damage_bonus: 1,
            weapon_type: "rail_gun",
            max_range: 4,
            firing_pattern: "line"
        }
    });
    
    array_push(global.upgrades, {
        id: "missile_pod",
        name: "Missile Pod", 
        description: "Medium range, can fire around corners",
        slot: SLOT_WEAPON,
        tier: 2,
        effects: {
            damage_bonus: 1,
            weapon_type: "missile",
            max_range: 3,
            firing_pattern: "indirect"
        }
    });
    
    array_push(global.upgrades, {
        id: "shotgun_array",
        name: "Shotgun Array",
        description: "Short range cone attack",
        slot: SLOT_WEAPON,
        tier: 2,
        effects: {
            damage_bonus: 1,
            weapon_type: "shotgun",
            max_range: 2,
            firing_pattern: "cone"
        }
    });
    
    // SHIELD UPGRADES (Defense & Survival)
    array_push(global.upgrades, {
        id: "energy_shield",
        name: "Energy Shield",
        description: "+1 Max HP",
        slot: SLOT_SHIELD,
        tier: 1,
        effects: { hp_bonus: 1 }
    });
    
    array_push(global.upgrades, {
        id: "armor_plating",
        name: "Armor Plating",
        description: "+2 Max HP",
        slot: SLOT_SHIELD,
        tier: 2,
        effects: { hp_bonus: 2 }
    });
    
    array_push(global.upgrades, {
        id: "regenerative_hull",
        name: "Regenerative Hull",
        description: "Heal 1 HP at start of each level",
        slot: SLOT_SHIELD,
        tier: 2,
        effects: { regen: 1 }
    });
    
    array_push(global.upgrades, {
        id: "targeting_computer",
        name: "Targeting Computer",
        description: "+10% Critical Hit Chance",
        slot: SLOT_WEAPON,
        tier: 2,
        effects: { crit_chance: 20 } // 20% total (10% base + 10% bonus)
    });
    
    show_debug_message("Upgrade system initialized with " + string(array_length(global.upgrades)) + " upgrades");
}

// Get upgrades available for a specific level (tier gating)
function get_available_upgrades(level) {
    var available = [];
    
    for (var i = 0; i < array_length(global.upgrades); i++) {
        var upgrade = global.upgrades[i];
        
        // Tier 1: Available from level 1
        // Tier 2: Available from level 3
        // Tier 3: Available from level 5
        var min_level = 1 + (upgrade.tier - 1) * 2;
        
        if (level >= min_level) {
            array_push(available, upgrade);
        }
    }
    
    return available;
}

// Get random upgrade selection (2 upgrades for player to choose from)
function get_upgrade_selection(level) {
    var available = get_available_upgrades(level);
    var selection = [];
    
    if (array_length(available) < 2) {
        // Not enough upgrades available, return what we have
        return available;
    }
    
    // Pick 2 random upgrades without duplicates
    var indices = [];
    for (var i = 0; i < array_length(available); i++) {
        array_push(indices, i);
    }
    
    // Shuffle and pick first 2
    for (var i = 0; i < array_length(indices); i++) {
        var j = irandom(array_length(indices) - 1);
        var temp = indices[i];
        indices[i] = indices[j];
        indices[j] = temp;
    }
    
    array_push(selection, available[indices[0]]);
    array_push(selection, available[indices[1]]);
    
    return selection;
}

// Get upgrade by ID
function get_upgrade_by_id(upgrade_id) {
    for (var i = 0; i < array_length(global.upgrades); i++) {
        if (global.upgrades[i].id == upgrade_id) {
            return global.upgrades[i];
        }
    }
    return noone;
}

// Get slot name for display
function get_slot_name(slot_type) {
    switch (slot_type) {
        case SLOT_THRUSTER: return "Thruster";
        case SLOT_WEAPON: return "Weapon";
        case SLOT_SHIELD: return "Shield";
        default: return "Unknown";
    }
}

// Get slot color for UI
function get_slot_color(slot_type) {
    switch (slot_type) {
        case SLOT_THRUSTER: return c_aqua;
        case SLOT_WEAPON: return c_red;
        case SLOT_SHIELD: return c_lime;
        default: return c_white;
    }
}

// Chain Gun attack - chains from initial target through connected enemies
function execute_chain_gun_attack(initial_target, player_damage) {
    if (!instance_exists(initial_target)) return 0;
    
    var enemies_hit = [initial_target];
    var visited_positions = [];
    var queue = [];
    
    // Get initial target position
    var initial_grid_x = initial_target.x div global.grid_size;
    var initial_grid_y = initial_target.y div global.grid_size;
    
    // Add initial target to queue and visited
    array_push(queue, [initial_grid_x, initial_grid_y]);
    array_push(visited_positions, [initial_grid_x, initial_grid_y]);
    
    // Cardinal directions only (up, down, left, right)
    var chain_directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    
    // Chain through connected enemies using BFS
    while (array_length(queue) > 0) {
        var current_pos = queue[0];
        array_delete(queue, 0, 1);
        
        var cur_x = current_pos[0];
        var cur_y = current_pos[1];
        
        // Check all cardinal directions from current enemy
        for (var d = 0; d < array_length(chain_directions); d++) {
            var check_x = cur_x + chain_directions[d][0];
            var check_y = cur_y + chain_directions[d][1];
            
            // Skip if already visited this position
            var already_visited = false;
            for (var v = 0; v < array_length(visited_positions); v++) {
                if (visited_positions[v][0] == check_x && visited_positions[v][1] == check_y) {
                    already_visited = true;
                    break;
                }
            }
            
            if (!already_visited) {
                // Check if there's an enemy at this position
                with (obj_enemy) {
                    var enemy_grid_x = x div global.grid_size;
                    var enemy_grid_y = y div global.grid_size;
                    if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                        // Found connected enemy, add to chain
                        var already_in_chain = false;
                        for (var j = 0; j < array_length(enemies_hit); j++) {
                            if (enemies_hit[j] == id) {
                                already_in_chain = true;
                                break;
                            }
                        }
                        if (!already_in_chain) {
                            array_push(enemies_hit, id);
                            array_push(queue, [check_x, check_y]);
                            array_push(visited_positions, [check_x, check_y]);
                        }
                    }
                }
            }
        }
    }
    
    // Damage all chained enemies using their take_damage function with critical hit chance
    show_debug_message("Chain Gun chained through " + string(array_length(enemies_hit)) + " enemies");
    for (var i = 0; i < array_length(enemies_hit); i++) {
        var enemy = enemies_hit[i];
        if (instance_exists(enemy)) {
            // Each enemy in chain has independent crit chance
            var crit_result = calculate_critical_hit(player_damage, 10);
            enemy.take_damage(crit_result.damage, crit_result.is_critical);
        }
    }
    
    return array_length(enemies_hit);
}

// Shotgun Array attack - hits all enemies in cone pattern
function execute_shotgun_attack(weapon_upgrade) {
    var enemies_hit = [];
    var player_damage = other.damage; // Get damage from calling player
    
    // Get all valid targets within shotgun cone
    with (obj_enemy) {
        if (other.is_target_in_cone(x div global.grid_size, y div global.grid_size)) {
            var distance = max(abs((x div global.grid_size) - (other.x div global.grid_size)), 
                             abs((y div global.grid_size) - (other.y div global.grid_size)));
            if (distance <= weapon_upgrade.effects.max_range) {
                array_push(enemies_hit, id);
            }
        }
    }
    with (obj_enemy_fighter) {
        if (other.is_target_in_cone(x div global.grid_size, y div global.grid_size)) {
            var distance = max(abs((x div global.grid_size) - (other.x div global.grid_size)), 
                             abs((y div global.grid_size) - (other.y div global.grid_size)));
            if (distance <= weapon_upgrade.effects.max_range) {
                array_push(enemies_hit, id);
            }
        }
    }
    with (obj_enemy_heavy) {
        if (other.is_target_in_cone(x div global.grid_size, y div global.grid_size)) {
            var distance = max(abs((x div global.grid_size) - (other.x div global.grid_size)), 
                             abs((y div global.grid_size) - (other.y div global.grid_size)));
            if (distance <= weapon_upgrade.effects.max_range) {
                array_push(enemies_hit, id);
            }
        }
    }
    
    // Damage all enemies in cone with critical hit chance
    show_debug_message("Shotgun Array hit " + string(array_length(enemies_hit)) + " enemies in cone");
    for (var i = 0; i < array_length(enemies_hit); i++) {
        var enemy = enemies_hit[i];
        if (instance_exists(enemy)) {
            // Each enemy in cone has independent crit chance
            var crit_result = calculate_critical_hit(player_damage, 10);
            enemy.take_damage(crit_result.damage, crit_result.is_critical);
        }
    }
    
    return array_length(enemies_hit);
}

// Rail Gun attack - pierces through enemies in a straight line
function execute_railgun_attack(initial_target, weapon_upgrade) {
    if (!instance_exists(initial_target)) return 0;
    
    var enemies_hit = [];
    var player_damage = other.damage; // Get damage from calling player
    var max_range = weapon_upgrade.effects.max_range;
    
    // Get player position and direction to target
    var player_grid_x = other.x div global.grid_size;
    var player_grid_y = other.y div global.grid_size;
    var target_grid_x = initial_target.x div global.grid_size;
    var target_grid_y = initial_target.y div global.grid_size;
    
    var dx = target_grid_x - player_grid_x;
    var dy = target_grid_y - player_grid_y;
    
    // Normalize direction to unit vector
    var dir_x = 0;
    var dir_y = 0;
    if (abs(dx) > abs(dy)) {
        dir_x = sign(dx);
        dir_y = 0;
    } else {
        dir_x = 0;
        dir_y = sign(dy);
    }
    
    // Trace line from player position up to max range
    for (var range = 1; range <= max_range; range++) {
        var check_x = player_grid_x + (dir_x * range);
        var check_y = player_grid_y + (dir_y * range);
        
        // Check bounds
        var check_world_x = check_x * global.grid_size + (global.grid_size / 2);
        var check_world_y = check_y * global.grid_size + (global.grid_size / 2);
        if (check_world_x < global.grid_size/2 || check_world_x >= room_width - global.grid_size/2 || 
            check_world_y < global.grid_size/2 || check_world_y >= room_height - global.grid_size/2) {
            break;
        }
        
        // Check for tile blocking the line
        if (is_tile_at_position(check_x, check_y)) {
            break; // Rail gun stops at walls
        }
        
        // Check for enemies at this position
        with (obj_enemy) {
            var enemy_grid_x = x div global.grid_size;
            var enemy_grid_y = y div global.grid_size;
            if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                var already_hit = false;
                for (var j = 0; j < array_length(enemies_hit); j++) {
                    if (enemies_hit[j] == id) {
                        already_hit = true;
                        break;
                    }
                }
                if (!already_hit) {
                    array_push(enemies_hit, id);
                }
            }
        }
        with (obj_enemy_fighter) {
            var enemy_grid_x = x div global.grid_size;
            var enemy_grid_y = y div global.grid_size;
            if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                var already_hit = false;
                for (var j = 0; j < array_length(enemies_hit); j++) {
                    if (enemies_hit[j] == id) {
                        already_hit = true;
                        break;
                    }
                }
                if (!already_hit) {
                    array_push(enemies_hit, id);
                }
            }
        }
        with (obj_enemy_heavy) {
            var enemy_grid_x = x div global.grid_size;
            var enemy_grid_y = y div global.grid_size;
            if (enemy_grid_x == check_x && enemy_grid_y == check_y) {
                var already_hit = false;
                for (var j = 0; j < array_length(enemies_hit); j++) {
                    if (enemies_hit[j] == id) {
                        already_hit = true;
                        break;
                    }
                }
                if (!already_hit) {
                    array_push(enemies_hit, id);
                }
            }
        }
    }
    
    // Damage all enemies in line with critical hit chance
    show_debug_message("Rail Gun pierced through " + string(array_length(enemies_hit)) + " enemies");
    for (var i = 0; i < array_length(enemies_hit); i++) {
        var enemy = enemies_hit[i];
        if (instance_exists(enemy)) {
            // Each enemy in line has independent crit chance
            var crit_result = calculate_critical_hit(player_damage, 10);
            enemy.take_damage(crit_result.damage, crit_result.is_critical);
        }
    }
    
    return array_length(enemies_hit);
}

// Calculate critical hit chance and damage
function calculate_critical_hit(base_damage, crit_chance = 10) {
    var is_critical = false;
    var final_damage = base_damage;
    
    // Roll for critical hit (default 10% chance)
    if (irandom(99) < crit_chance) {
        is_critical = true;
        final_damage = base_damage * 2; // Double damage on crit
        show_debug_message("CRITICAL HIT! " + string(base_damage) + " -> " + string(final_damage) + " damage");
    }
    
    return {
        damage: final_damage,
        is_critical: is_critical
    };
}

// Create floating damage text with critical hit styling
function create_damage_text(target_x, target_y, damage_amount, is_critical = false) {
    // Create a temporary object for damage text animation at a higher depth (appears on top)
    var damage_text = instance_create_depth(target_x, target_y, -100, obj_damage_text);
    
    if (instance_exists(damage_text)) {
        with (damage_text) {
            damage_value = damage_amount;
            is_crit = is_critical;
            
            // Set animation properties
            start_y = target_y;
            target_y_offset = -40; // Float upward
            alpha = 1.0;
            scale = is_critical ? 0.8 : 0.3; // Much more subtle sizing
            color = is_critical ? c_yellow : c_white;
            
            // Animation duration
            animation_duration = 1.5; // 1.5 seconds
            animation_timer = 0;
        }
        
        // Debug positioning
        show_debug_message("Created damage text at (" + string(target_x) + ", " + string(target_y) + ") with damage " + string(damage_amount));
    }
}