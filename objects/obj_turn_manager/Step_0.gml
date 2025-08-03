// Handle game state transitions
if (game_state == "player_win") {
    // Player won - regenerate room for new challenge
    if (keyboard_check_pressed(vk_enter)) {
        show_debug_message("Enter pressed - regenerating room (victory)");
        game_restart();
    }
} else if (game_state == "player_lose") {
    // Player lost - regenerate room to try again
    if (keyboard_check_pressed(vk_enter)) {
        show_debug_message("Enter pressed - regenerating room (defeat)");
        game_restart();
    }
}

// R key restart - works anytime during gameplay
if (keyboard_check_pressed(ord("R"))) {
    show_debug_message("R pressed - restarting game");
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