damage = 1;
hp_max = 6;
hp = 6;
moves_max = 1;
moves = 1;
init = 15;
is_myturn = false;
grid_size = 64;

// Snap to grid on creation
snap_to_grid();
turn_manager = instance_find(obj_turn_manager, 0);
       