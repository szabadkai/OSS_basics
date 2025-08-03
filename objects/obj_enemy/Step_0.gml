// Enemy AI - only act during enemy's turn
if (is_myturn && moves > 0) {
    var player = instance_find(obj_player, 0);
    
    if (player != noone) {
        // Check if player is in attack range
        if (in_attack_range(player.x, player.y)) {
            // Attack the player
            player.hp -= damage;
            moves--;
            
            // Check if player died
            if (player.hp <= 0) {
                instance_destroy(player);
                
                // Check for defeat immediately
                var turn_manager = instance_find(obj_turn_manager, 0);
                if (turn_manager != noone) {
                    turn_manager.check_game_state();
                }
            }
        } else {
            // Move towards player
            var dir = get_direction_to_target(player.x, player.y);
            
            if (try_move(dir[0], dir[1])) {
                moves--;
            } else {
                // If can't move towards player, try random direction
                var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
                var random_dir = directions[irandom(3)];
                
                if (try_move(random_dir[0], random_dir[1])) {
                    moves--;
                } else {
                    // Can't move anywhere, skip turn
                    moves = 0;
                }
            }
        }
    } else {
        // No player found, skip turn
        moves = 0;
    }
}