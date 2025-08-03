draw_set_color(c_white);
draw_set_font(-1);

var margin = 16;
var line_height = 20;
var y_pos = margin;

// Player status and controls (only during game)
if (turn_manager == noone) {
    turn_manager = instance_find(obj_turn_manager, 0);
}

if (turn_manager != noone && turn_manager.game_state == "playing") {
    var player = instance_find(obj_player, 0);
    if (player != noone) {
        // Player health
        draw_text(margin, y_pos, "HP: " + string(player.hp) + "/" + string(player.hp_max));
        y_pos += line_height;
        
        // Current turn info
        if (player.is_myturn) {
            draw_set_color(c_yellow);
            draw_text(margin, y_pos, "YOUR TURN - Moves: " + string(player.moves));
            draw_set_color(c_white);
            y_pos += line_height;
            
            // Controls help
            draw_set_color(c_ltgray);
            draw_text(margin, y_pos, "WASD: Move/Attack");
            y_pos += line_height;
            draw_text(margin, y_pos, "SPACE: Skip Turn");
            draw_set_color(c_white);
        } else {
            draw_set_color(c_gray);
            draw_text(margin, y_pos, "Enemy Turn");
            draw_set_color(c_white);
        }
        y_pos += line_height;
        
        // Enemy count
        var enemy_count = instance_number(obj_enemy);
        draw_text(margin, y_pos, "Enemies: " + string(enemy_count));
    }
}

// Big center screen victory/defeat messages
if (turn_manager != noone) {
    var center_x = display_get_gui_width() / 2;
    var center_y = display_get_gui_height() / 2;
    
    if (turn_manager.game_state == "player_win") {
        // Victory message
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // Background box
        draw_set_color(c_black);
        draw_set_alpha(0.8);
        draw_rectangle(center_x - 200, center_y - 80, center_x + 200, center_y + 80, false);

        // Victory text
        draw_set_alpha(1);
        draw_set_color(c_lime);
        draw_text_transformed(center_x, center_y - 20, "VICTORY!", 3, 3, 0);

        draw_set_color(c_white);
        draw_text_transformed(center_x, center_y + 20, "Press ENTER to restart", 1.5, 1.5, 0);

        // Reset alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

    } else if (turn_manager.game_state == "player_lose") {
        // Defeat message
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

          // Background box
          draw_set_color(c_black);
             draw_set_alpha(0.8);
            draw_rectangle(center_x - 200, center_y - 80, center_x + 200, center_y + 80, false);

          // Defeat text
          draw_set_alpha(1);
          draw_set_color(c_red);
          draw_text_transformed(center_x, center_y - 20, "DEFEAT!", 3, 3, 0);

          draw_set_color(c_white);
          draw_text_transformed(center_x, center_y + 20, "Press ENTER to restart", 1.5, 1.5, 0);

         // Reset alignment
          draw_set_halign(fa_left);
          draw_set_valign(fa_top);
      }
 }