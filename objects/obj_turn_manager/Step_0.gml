// Handle game state transitions
if (game_state == "player_win") {
    // Auto-advance to upgrade selection after brief victory display
    level_complete_timer += 1 / room_speed;
    
    if (level_complete_timer >= level_complete_duration) {
        // Switch to upgrade selection
        upgrade_selections = get_upgrade_selection(global.current_level);
        selected_upgrade = -1;
        game_state = "upgrade_selection";
        level_complete_timer = 0;
        show_debug_message("Showing upgrade selection for level " + string(global.current_level));
    }
    
    // Still allow manual advance with ENTER
    if (keyboard_check_pressed(vk_enter)) {
        level_complete_timer = level_complete_duration; // Skip to selection immediately
    }
} else if (game_state == "upgrade_selection") {
    // Handle upgrade selection input
    if (keyboard_check_pressed(ord("1")) && array_length(upgrade_selections) >= 1) {
        selected_upgrade = 0;
    } else if (keyboard_check_pressed(ord("2")) && array_length(upgrade_selections) >= 2) {
        selected_upgrade = 1;
    }
    
    // Apply selected upgrade and advance to next level
    if (selected_upgrade >= 0) {
        var player = instance_find(obj_player, 0);
        if (player != noone) {
            player.apply_upgrade(upgrade_selections[selected_upgrade]);
        }
        
        global.current_level++;
        show_debug_message("Advancing to level " + string(global.current_level));
        
        // Apply regenerative healing if player has it
        var player = instance_find(obj_player, 0);
        if (player != noone && player.has_regeneration) {
            var old_hp = player.hp;
            player.hp = min(player.hp + 1, player.hp_max);
            if (player.hp > old_hp) {
                show_debug_message("Regenerative Hull healed player: " + string(old_hp) + " -> " + string(player.hp));
            }
        }
        
        // Regenerate entire level with new parameters (tiles + entities)
        var room_gen = instance_find(obj_room_generator, 0);
        if (room_gen != noone) {
            room_gen.regenerate_level();
        }
        
        // Reset game state
        game_state = "playing";
        initialize_turns();
    }
} else if (game_state == "planet_landing_confirm") {
    // Handle planet landing confirmation input
    if (keyboard_check_pressed(ord("Y"))) {
        // Yes - land on planet
        planet_landing_confirmed = true;
        game_state = "playing"; // Reset state before room transition
        show_debug_message("Player confirmed planet landing");
        room_goto(rm_planet_map);
    } else if (keyboard_check_pressed(ord("N"))) {
        // No - stay in space
        planet_landing_confirmed = false;
        game_state = "playing";
        show_debug_message("Player declined planet landing - resuming space combat");
    }
} else if (game_state == "player_lose") {
    // Player lost - reset level and regenerate room to try again
    if (keyboard_check_pressed(vk_enter)) {
        show_debug_message("Enter pressed - regenerating room (defeat)");
        reset_level();
        game_restart();
    }
}

// R key restart - works anytime during gameplay
if (keyboard_check_pressed(ord("R"))) {
    show_debug_message("R pressed - restarting game");
    reset_level();
    game_restart();
}

// Check if current turn entity has used all moves
if (game_state == "playing" && array_length(turn_entities) > 0) {
    var current_entity = turn_entities[turn_index];
    if (instance_exists(current_entity.object_id)) {
        with(current_entity.object_id) {
            if (moves <= 0) {
                other.next_turn();
            }
        }
    } else {
        // Current entity is dead, advance turn
        show_debug_message("Entity dead, advancing turn. Remaining entities: " + string(array_length(turn_entities)));
        next_turn();
    }
}

// Debug output for non-playing states
if (game_state != "playing") {
    show_debug_message("Turn manager step - game state: " + string(game_state));
}