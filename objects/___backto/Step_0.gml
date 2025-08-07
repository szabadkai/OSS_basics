if (keyboard_check_pressed(ord("B"))) {
    show_debug_message("B pressed - returning to space");
    
    // Reset turn manager to combat mode before returning
    var turn_manager = instance_find(obj_turn_manager, 0);
    if (turn_manager != noone) {
        show_debug_message("Resetting turn manager from " + string(turn_manager.game_state) + " to playing");
        turn_manager.game_state = "playing";
        show_debug_message("Turn manager reset to playing mode");
    }
    
    room_goto(rm_space_rouglite);
}

// E key functionality removed - encounters now start automatically



