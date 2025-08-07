if instance_exists(obj_player) {
    // Initialize visited flags if they don't exist (for existing planets)
    if (!variable_instance_exists(id, "visited")) {
        visited = false;
        visited_level = -1;
        show_debug_message("Initialized visited flags for existing planet");
    }
    
    // Check if planet was visited on current level
    var visited_this_level = (visited_level == global.current_level);
    
	if (x == obj_player.x && y == obj_player.y) {
        // Only trigger if we haven't already shown the confirmation and planet hasn't been visited this level
        if (!landing_triggered && !visited_this_level) {
            show_debug_message("Player reached planet! (visited_level: " + string(visited_level) + ", current_level: " + string(global.current_level) + ")");
            landing_triggered = true;
            
            // Trigger planet landing confirmation through turn manager
            var turn_manager = instance_find(obj_turn_manager, 0);
            if (turn_manager != noone) {
                turn_manager.trigger_planet_landing();
            }
        } else if (visited_this_level) {
            // Planet already explored this level
            if (!landing_triggered) {
                show_debug_message("Planet already explored this level - no more encounters available");
                landing_triggered = true; // Prevent spam messages
            }
        }
    } else {
        // Player moved away - allow re-triggering if planet becomes available again
        landing_triggered = false;
    }
}
