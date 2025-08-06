// Projectile - visual effect for weapon attacks
target_x = x;
target_y = y;
start_x = x;
start_y = y;

// Movement properties
speed_multiplier = 8; // How fast projectile travels (grid units per second)
travel_timer = 0;
travel_duration = 0.15; // Faster travel time to reduce turn-based issues
instant_hit = false; // For enemy attacks, we might want instant hits

// Visual properties
projectile_type = "laser"; // "laser", "missile", "rail", "shotgun"
color = c_yellow;
trail_length = 3; // Number of trail particles
trail_positions = [];

// Target and damage info (for when it hits)
target_object = noone;
damage_amount = 0;
is_critical = false;

// Initialize trail positions
for (var i = 0; i < trail_length; i++) {
    array_push(trail_positions, [x, y]);
}