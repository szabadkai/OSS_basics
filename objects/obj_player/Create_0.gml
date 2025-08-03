
global.grid_size = 32;

damage = 1;
hp_max = 2;
hp = 2;
moves_max = 1;
moves = 1;
is_myturn = false;
grid_size = global.grid_size;
init = 15;

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
turn_manager = instance_find(obj_turn_manager, 0);
       