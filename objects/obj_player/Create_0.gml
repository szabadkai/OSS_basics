damage = 1;
hp_max = 1;
hp = 1;
moves_max = 1;
moves = 1;
is_myturn = false;
grid_size = 64;
init = 15
// Snap to grid on creation
snap_to_grid();
turn_manager = instance_find(obj_turn_manager, 0);
       