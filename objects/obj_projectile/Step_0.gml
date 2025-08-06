// Update projectile movement
travel_timer += 1 / room_speed;

if (travel_timer >= travel_duration) {
    // Projectile reached target - just destroy (damage already applied)
    instance_destroy();
} else {
    // Move projectile toward target
    var progress = travel_timer / travel_duration;
    var old_x = x;
    var old_y = y;
    
    // Smooth movement with easing
    var eased_progress = ease_out_cubic(progress);
    x = lerp(start_x, target_x, eased_progress);
    y = lerp(start_y, target_y, eased_progress);
    
    // Update trail positions
    // Shift all trail positions back one
    for (var i = trail_length - 1; i > 0; i--) {
        trail_positions[i][0] = trail_positions[i-1][0];
        trail_positions[i][1] = trail_positions[i-1][1];
    }
    // Set first trail position to current position
    trail_positions[0][0] = old_x;
    trail_positions[0][1] = old_y;
    
    // Set rotation based on movement direction
    if (target_x != start_x || target_y != start_y) {
        image_angle = point_direction(start_x, start_y, target_x, target_y);
    }
}