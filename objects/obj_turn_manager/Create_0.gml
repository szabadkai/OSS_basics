// Turn Manager - handles turn-based game flow
current_turn = 0;
turn_entities = [];
turn_index = 0;
game_state = "playing"; // "playing", "player_win", "player_lose", "upgrade_selection", "planet_landing_confirm", "planet_exploration"

// Initialize upgrade system
if (!variable_global_exists("upgrades")) {
    init_upgrade_system();
}

// Initialize planet system
if (!variable_global_exists("planet_types")) {
    init_planet_system();
}

// Level progression system
if (!variable_global_exists("current_level")) {
    global.current_level = 1;
}
level_complete_timer = 0;
level_complete_duration = 2.0; // Show victory message for 2 seconds

// Upgrade selection system
upgrade_selections = []; // Array of 2 upgrade options
selected_upgrade = -1; // Which upgrade player has chosen (-1 = none yet)

// Planet landing confirmation system
planet_landing_confirmed = false; // Whether player confirmed landing

// Reset level to 1 (used on game restart/defeat)
reset_level = function() {
    global.current_level = 1;
    
    // Reset player upgrades
    var player = instance_find(obj_player, 0);
    if (player != noone) {
        player.upgrades.thruster = noone;
        player.upgrades.weapon = noone;
        player.upgrades.shield = noone;
        player.recalculate_stats();
    }
    
    show_debug_message("Level and upgrades reset to starting state");
};

// Trigger planet landing confirmation
trigger_planet_landing = function() {
    if (game_state == "playing") {
        game_state = "planet_landing_confirm";
        planet_landing_confirmed = false;
        show_debug_message("Planet landing confirmation triggered");
    }
};



// Initialize turn order based on initiative
initialize_turns = function() {
    turn_entities = [];
    
    // Add player to turn order
    with(obj_player) {
        array_push(other.turn_entities, {
            object_id: id,
            initiative: init,
            type: "player"
        });
    }
    
    // Add enemies to turn order
    with(obj_enemy) {
        array_push(other.turn_entities, {
            object_id: id,
            initiative: init,
            type: "enemy"
        });
    }
    
    // Sort by initiative (highest first)
    array_sort(turn_entities, function(a, b) {
        return b.initiative - a.initiative;
    });
    
    // Reset turn tracking
    turn_index = 0;
    current_turn = 1;
    
    // Set initial turn
    if (array_length(turn_entities) > 0) {
        set_active_entity();
    }
};

// Set the active entity for current turn
set_active_entity = function() {
    // Reset all entities' turn flags
    with(obj_player) {
        is_myturn = false;
        moves = moves_max;
    }
    with(obj_enemy) {
        is_myturn = false;
        moves = moves_max;
    }
    
    // Set current entity as active
    if (turn_index < array_length(turn_entities)) {
        var current_entity = turn_entities[turn_index];
        with(current_entity.object_id) {
            is_myturn = true;
            moves = moves_max;
        }
    }
};

// Advance to next turn
next_turn = function() {
    turn_index++;
    
    // If we've gone through all entities, start new round
    if (turn_index >= array_length(turn_entities)) {
        turn_index = 0;
        current_turn++;
        
        // Clean up dead entities from turn order
        var alive_entities = [];
        for (var i = 0; i < array_length(turn_entities); i++) {
            if (instance_exists(turn_entities[i].object_id)) {
                array_push(alive_entities, turn_entities[i]);
            }
        }
        turn_entities = alive_entities;
    }
    
    // Check win/lose conditions
    check_game_state();
    
    // Set next active entity if game is still playing
    if (game_state == "playing" && array_length(turn_entities) > 0) {
        set_active_entity();
    }
};

// Check for win/lose conditions
check_game_state = function() {
    // Only check win/lose conditions during actual combat
    if (game_state != "playing") {
        return;
    }
    
    var player_alive = instance_exists(obj_player);
    var enemies_alive = instance_number(obj_enemy) > 0;
    
    var old_state = game_state;
    
    if (!player_alive) {
        game_state = "player_lose";
    } else if (!enemies_alive) {
        game_state = "player_win";
    }
    
    // Log state changes
    if (old_state != game_state) {
        show_debug_message("Game state changed from " + string(old_state) + " to " + string(game_state));
        show_debug_message("Player alive: " + string(player_alive) + ", Enemies alive: " + string(enemies_alive));
    }
};


// Initialize the turn system
initialize_turns();