// Update thruster effect animation
timer += 1 / room_speed;

if (timer >= duration) {
    // Effect duration complete
    instance_destroy();
} else {
    // Animate thruster effect
    var progress = timer / duration;
    
    // Fade out over time
    alpha = 1.0 - progress;
    image_alpha = alpha;
    
    // Scale down over time for trailing effect
    var current_scale = lerp(initial_scale, final_scale, progress);
    image_xscale = current_scale;
    image_yscale = current_scale;
}