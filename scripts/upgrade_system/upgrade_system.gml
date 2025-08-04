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