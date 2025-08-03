is_myturn = false;

//stats
moves_max = 1;
moves = 1;
hp_max = 1;
hp = 1;
damage = 1;
init = 10;
grid_size = global.grid_size;

// Animation variables
is_animating = false;
move_start_x = 0;
move_start_y = 0;
move_target_x = 0;
move_target_y = 0;
move_timer = 0;
move_duration = 0.2;

// Snap to grid on creation
snap_to_grid();