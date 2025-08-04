if instance_exists(obj_player) {
	if (x == obj_player.x && y == obj_player.y) {
        // Only trigger if we haven't already shown the confirmation
        if (!landing_triggered) {
            show_debug_message("Player reached planet! Showing landing confirmation...");
            landing_triggered = true;
            
            // Trigger planet landing confirmation through turn manager
            var turn_manager = instance_find(obj_turn_manager, 0);
            if (turn_manager != noone) {
                turn_manager.trigger_planet_landing();
            }
        }
    } else {
        // Reset trigger only when player moves away from this tile
        if (landing_triggered) {
            show_debug_message("Player left planet - resetting landing trigger");
            landing_triggered = false;
        }
    }
}
