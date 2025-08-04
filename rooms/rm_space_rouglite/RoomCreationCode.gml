// Space Room Creation Code
show_debug_message("Space room started - checking turn system");

// Ensure turn manager is in proper state for space combat
var turn_manager = instance_find(obj_turn_manager, 0);
if (turn_manager != noone) {
    show_debug_message("Turn manager found - state: " + string(turn_manager.game_state));
    
    // Always reinitialize turns when entering space room to ensure proper state
    if (turn_manager.game_state == "playing") {
        turn_manager.initialize_turns();
        show_debug_message("Turn system reinitialized for space combat");
    }
} else {
    show_debug_message("Warning: No turn manager found in space room");
}