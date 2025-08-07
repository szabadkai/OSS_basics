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
        // Yes - proceed to crew selection
        planet_landing_confirmed = true;
        game_state = "crew_selection";
        crew_selection_stage = 0; // Initialize crew selection
        selected_crew_ids = [];
        show_debug_message("Player confirmed planet landing - selecting crew");
    } else if (keyboard_check_pressed(ord("N"))) {
        // No - stay in space
        planet_landing_confirmed = false;
        game_state = "playing";
        show_debug_message("Player declined planet landing - resuming space combat");
    }
} else if (game_state == "crew_selection") {
    // Handle crew selection input
    var player = instance_find(obj_player, 0);
    if (player != noone && array_length(player.crew_roster) > 0) {
        // Number keys to select crew (1-8)
        for (var i = 0; i < min(8, array_length(player.crew_roster)); i++) {
            if (keyboard_check_pressed(ord("1") + i)) {
                // Toggle crew member selection
                var crew_index = i;
                var already_selected = false;
                var selected_index = -1;
                
                // Check if already selected
                for (var j = 0; j < array_length(selected_crew_ids); j++) {
                    if (selected_crew_ids[j] == crew_index) {
                        already_selected = true;
                        selected_index = j;
                        break;
                    }
                }
                
                if (already_selected) {
                    // Deselect
                    array_delete(selected_crew_ids, selected_index, 1);
                    show_debug_message("Deselected crew member " + string(crew_index + 1));
                } else if (array_length(selected_crew_ids) < 2) {
                    // Select (max 2)
                    array_push(selected_crew_ids, crew_index);
                    show_debug_message("Selected crew member " + string(crew_index + 1));
                }
            }
        }
        
        // Confirm selection with ENTER (must have exactly 2 crew)
        if (keyboard_check_pressed(vk_enter) && array_length(selected_crew_ids) == 2) {
            // Apply selection to player
            player.select_crew_for_mission(selected_crew_ids);
            
            // Go to planet map room where encounters will be triggered
            game_state = "playing";
            show_debug_message("Crew selection confirmed - landing on planet");
            room_goto(rm_planet_map);
        }
        
        // Cancel with ESC
        if (keyboard_check_pressed(vk_escape)) {
            game_state = "playing";
            selected_crew_ids = [];
            show_debug_message("Crew selection cancelled - staying in space");
        }
    } else {
        // No crew available, go directly to planet
        show_debug_message("No crew available - proceeding to planet");
        game_state = "playing";
        room_goto(rm_planet_map);
    }
} else if (game_state == "encounter_active") {
    // Handle encounter choice input
    if (current_encounter != noone && encounter_stage < array_length(current_encounter.stages)) {
        var current_stage = current_encounter.stages[encounter_stage];
        var player = instance_find(obj_player, 0);
        
        // Number keys to select choices (1-3)
        for (var i = 0; i < min(3, array_length(current_stage.choices)); i++) {
            if (keyboard_check_pressed(ord("1") + i)) {
                // Resolve the choice using player's selected crew
                var selected_crew_data = [];
                if (player != noone && variable_struct_exists(player, "selected_crew")) {
                    selected_crew_data = player.selected_crew;
                }
                var result = resolve_encounter_choice(current_encounter, encounter_stage, i, selected_crew_data);
                array_push(encounter_results, result);
                
                encounter_stage++;
                show_debug_message("Encounter choice " + string(i + 1) + " selected - " + (result.success ? "SUCCESS" : "FAILURE"));
                
                // Check if encounter is complete
                if (encounter_stage >= array_length(current_encounter.stages)) {
                    // Calculate final rewards
                    var planet_data = variable_global_exists("current_planet") ? global.current_planet.data : noone;
                    if (planet_data != noone) {
                        encounter_rewards = calculate_encounter_rewards(current_encounter, encounter_results, planet_data);
                        game_state = "encounter_result";
                        show_debug_message("Encounter completed - showing results");
                    } else {
                        show_debug_message("Warning: No planet data for reward calculation");
                        game_state = "planet_exploration";
                    }
                }
                break;
            }
        }
    }
} else if (game_state == "encounter_result") {
    // Handle encounter result confirmation
    if (keyboard_check_pressed(vk_enter)) {
        // Apply rewards and return to starmap
        if (encounter_rewards != noone) {
            apply_encounter_rewards(encounter_rewards);
        }
        
        // Reset encounter state
        current_encounter = noone;
        encounter_stage = 0;
        encounter_results = [];
        encounter_rewards = noone;
        
        // Return to space combat mode but prevent immediate win condition check
        game_state = "returning_from_encounter";
        show_debug_message("Encounter rewards applied - returning to starmap");
        
        // Return to starmap room
        room_goto(rm_space_rouglite);
    }
} else if (game_state == "returning_from_encounter") {
    // Wait for room transition to complete, then restart combat
    if (room == rm_space_rouglite) {
        show_debug_message("Back in starmap - reinitializing combat system");
        game_state = "playing";
        initialize_turns();
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