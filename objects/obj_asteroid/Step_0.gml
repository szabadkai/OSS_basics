// Update hurt animation
if (is_hurt) {
    hurt_timer += 1 / room_speed;
    
    if (hurt_timer >= hurt_duration) {
        // Hurt animation complete
        is_hurt = false;
        hurt_timer = 0;
        image_blend = original_image_blend;
    }
}

// Update destruction animation
if (is_dying) {
    death_timer += 1 / room_speed;
    
    // Fade out and scale down during destruction
    var death_progress = death_timer / death_duration;
    image_alpha = 1.0 - death_progress;
    image_xscale = 1.0 - (death_progress * 0.5); // Shrink slightly
    image_yscale = 1.0 - (death_progress * 0.5);
    
    if (death_timer >= death_duration) {
        // Destruction animation complete - remove from game
        show_debug_message("Asteroid destruction animation complete - destroying instance");
        instance_destroy();
    }
}