
global.grid_size = 32;

// Upgrade system will be initialized by turn manager

// Base stats (before upgrades)
base_damage = 1;
base_hp_max = 2;
base_moves_max = 1;
base_init = 15;

// Ship upgrade slots
upgrades = {
    thruster: noone,  // Thruster slot upgrade
    weapon: noone,    // Weapon slot upgrade
    shield: noone     // Shield slot upgrade
};

// Current stats (will be calculated from base + upgrades)
damage = base_damage;
hp_max = base_hp_max;
hp = base_hp_max;
moves_max = base_moves_max;
moves = base_moves_max;
is_myturn = false;
grid_size = global.grid_size;
init = base_init;

// Special abilities
has_area_attack = false;
has_regeneration = false;

// Animation variables
is_animating = false;
move_start_x = 0;
move_start_y = 0;
move_target_x = 0;
move_target_y = 0;
move_timer = 0;
move_duration = 0.2;

// Ship upgrade functions
apply_upgrade = function(upgrade_data) {
    var slot_name = "";
    switch (upgrade_data.slot) {
        case SLOT_THRUSTER: 
            upgrades.thruster = upgrade_data;
            slot_name = "thruster";
            break;
        case SLOT_WEAPON:
            upgrades.weapon = upgrade_data;
            slot_name = "weapon";
            break;
        case SLOT_SHIELD:
            upgrades.shield = upgrade_data;
            slot_name = "shield";
            break;
    }
    
    show_debug_message("Applied upgrade: " + upgrade_data.name + " to " + slot_name + " slot");
    recalculate_stats();
};

// Recalculate all stats from base + upgrades
recalculate_stats = function() {
    var old_hp_max = hp_max;
    
    // Reset to base stats
    damage = base_damage;
    hp_max = base_hp_max;
    moves_max = base_moves_max;
    init = base_init;
    
    // Reset special abilities
    has_area_attack = false;
    has_regeneration = false;
    
    // Apply thruster upgrades
    if (upgrades.thruster != noone) {
        var effects = upgrades.thruster.effects;
        if (variable_struct_exists(effects, "moves_bonus")) {
            moves_max += effects.moves_bonus;
        }
        if (variable_struct_exists(effects, "init_bonus")) {
            init += effects.init_bonus;
        }
    }
    
    // Apply weapon upgrades
    if (upgrades.weapon != noone) {
        var effects = upgrades.weapon.effects;
        if (variable_struct_exists(effects, "damage_bonus")) {
            damage += effects.damage_bonus;
        }
        if (variable_struct_exists(effects, "area_attack")) {
            has_area_attack = effects.area_attack;
        }
    }
    
    // Apply shield upgrades
    if (upgrades.shield != noone) {
        var effects = upgrades.shield.effects;
        if (variable_struct_exists(effects, "hp_bonus")) {
            hp_max += effects.hp_bonus;
        }
        if (variable_struct_exists(effects, "regen")) {
            has_regeneration = true;
        }
    }
    
    // Adjust current HP if max HP increased
    if (hp_max > old_hp_max) {
        hp += (hp_max - old_hp_max); // Gain the extra HP
    }
    
    // Ensure current moves match new max
    if (!is_myturn) {
        moves = moves_max;
    }
    
    show_debug_message("Stats recalculated - HP: " + string(hp) + "/" + string(hp_max) + 
                      ", Damage: " + string(damage) + ", Moves: " + string(moves_max) + 
                      ", Init: " + string(init));
};

// Snap to grid on creation
snap_to_grid();
turn_manager = instance_find(obj_turn_manager, 0);
       