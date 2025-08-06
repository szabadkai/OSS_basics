// Update animation
animation_timer += 1 / room_speed;

if (animation_timer >= animation_duration) {
    // Animation complete, destroy object
    instance_destroy();
} else {
    // Animate position and alpha
    var progress = animation_timer / animation_duration;
    var eased_progress = ease_out_cubic(progress);
    
    // Float upward
    y = start_y + (target_y_offset * eased_progress);
    
    // Fade out
    alpha = 1.0 - progress;
    
    // Scale effect for critical hits
    if (is_crit) {
        var pulse = sin(animation_timer * 10) * 0.05; // Subtle pulsing effect
        scale = 0.8 + pulse;
    }
}