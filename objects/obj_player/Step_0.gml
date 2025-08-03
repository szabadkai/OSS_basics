// Player input handling - only process during player's turn and when game is playing
var turn_manager = instance_find(obj_turn_manager, 0);
var game_is_playing = (turn_manager != noone && turn_manager.game_state == "playing");

if (is_myturn && moves > 0 && game_is_playing) {
    var action_taken = false;
    
    // Movement/Attack input - try to move, attack if enemy is in the way
    var result = 0;
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        result = try_move_or_attack(0, -1);
        action_taken = (result > 0);
    } else if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        result = try_move_or_attack(0, 1);
        action_taken = (result > 0);
    } else if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        result = try_move_or_attack(-1, 0);
        action_taken = (result > 0);
    } else if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        result = try_move_or_attack(1, 0);
        action_taken = (result > 0);
    }
    
    // Consume move if action was taken (moved or attacked)
    if (action_taken) {
        moves--;
    }
    
    // Skip turn with Space key
    if (keyboard_check_pressed(vk_space)) {
        moves = 0;
        show_debug_message("Player skipped turn");
    }
}