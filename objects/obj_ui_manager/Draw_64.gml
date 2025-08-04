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
        y_pos += line_height;
        
        // Current level
        draw_set_color(c_aqua);
        draw_text(margin, y_pos, "Level: " + string(global.current_level));
        draw_set_color(c_white);
        y_pos += line_height;
        
        // Ship upgrades display
        draw_set_color(c_ltgray);
        draw_text(margin, y_pos, "Ship Upgrades:");
        y_pos += line_height;
        
        // Show installed upgrades
        if (player.upgrades.thruster != noone) {
            draw_set_color(get_slot_color(SLOT_THRUSTER));
            draw_text(margin, y_pos, "T: " + player.upgrades.thruster.name);
            y_pos += line_height;
        }
        if (player.upgrades.weapon != noone) {
            draw_set_color(get_slot_color(SLOT_WEAPON));
            draw_text(margin, y_pos, "W: " + player.upgrades.weapon.name);
            y_pos += line_height;
        }
        if (player.upgrades.shield != noone) {
            draw_set_color(get_slot_color(SLOT_SHIELD));
            draw_text(margin, y_pos, "S: " + player.upgrades.shield.name);
            y_pos += line_height;
        }
        draw_set_color(c_white);
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
        
        // Show level completion with auto-advance info
        var current_level = global.current_level;
        var time_remaining = turn_manager.level_complete_duration - turn_manager.level_complete_timer;
        
        if (time_remaining > 0) {
            draw_text_transformed(center_x, center_y - 40, "LEVEL " + string(current_level) + " COMPLETE!", 2.5, 2.5, 0);
            draw_set_color(c_yellow);
            draw_text_transformed(center_x, center_y, "Advancing to Level " + string(current_level + 1) + "...", 1.8, 1.8, 0);
            draw_set_color(c_white);
            draw_text_transformed(center_x, center_y + 30, "(" + string(ceil(time_remaining)) + "s)", 1.2, 1.2, 0);
            draw_text_transformed(center_x, center_y + 50, "Press ENTER to skip", 1, 1, 0);
        } else {
            draw_text_transformed(center_x, center_y - 20, "VICTORY!", 3, 3, 0);
            draw_set_color(c_white);
            draw_text_transformed(center_x, center_y + 20, "Press ENTER to restart", 1.5, 1.5, 0);
        }

        // Reset alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

    } else if (turn_manager.game_state == "upgrade_selection") {
        // Upgrade Selection Screen
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // Background box
        draw_set_color(c_black);
        draw_set_alpha(0.9);
        draw_rectangle(center_x - 300, center_y - 150, center_x + 300, center_y + 150, false);

        // Title
        draw_set_alpha(1);
        draw_set_color(c_yellow);
        draw_text_transformed(center_x, center_y - 120, "CHOOSE UPGRADE", 2.5, 2.5, 0);
        
        draw_set_color(c_white);
        draw_text_transformed(center_x, center_y - 90, "Level " + string(global.current_level) + " Complete!", 1.2, 1.2, 0);

        // Display upgrade options
        if (array_length(turn_manager.upgrade_selections) >= 2) {
            var upgrade1 = turn_manager.upgrade_selections[0];
            var upgrade2 = turn_manager.upgrade_selections[1];
            
            // Option 1 (left side) - wider spacing and text wrapping
            var left_x = center_x - 180;
            var box_width = 150;
            
            draw_set_color(get_slot_color(upgrade1.slot));
            draw_text_transformed(left_x, center_y - 50, "[1] " + upgrade1.name, 1.4, 1.4, 0);
            draw_set_color(c_ltgray);
            draw_text_transformed(left_x, center_y - 25, get_slot_name(upgrade1.slot) + " Slot", 0.9, 0.9, 0);
            
            // Wrap description text if too long
            draw_set_color(c_white);
            var desc1 = upgrade1.description;
            if (string_length(desc1) > 18) {
                // Split long descriptions at word boundaries
                var words = string_split(desc1, " ");
                var line1 = "";
                var line2 = "";
                var char_count = 0;
                
                for (var i = 0; i < array_length(words); i++) {
                    if (char_count + string_length(words[i]) < 18) {
                        line1 += words[i] + " ";
                        char_count += string_length(words[i]) + 1;
                    } else {
                        line2 += words[i] + " ";
                    }
                }
                
                draw_text_transformed(left_x, center_y, string_trim(line1), 1.1, 1.1, 0);
                if (string_length(line2) > 0) {
                    draw_text_transformed(left_x, center_y + 18, string_trim(line2), 1.1, 1.1, 0);
                }
            } else {
                draw_text_transformed(left_x, center_y, desc1, 1.1, 1.1, 0);
            }
            
            // Option 2 (right side) - matching formatting
            var right_x = center_x + 180;
            
            draw_set_color(get_slot_color(upgrade2.slot));
            draw_text_transformed(right_x, center_y - 50, "[2] " + upgrade2.name, 1.4, 1.4, 0);
            draw_set_color(c_ltgray);
            draw_text_transformed(right_x, center_y - 25, get_slot_name(upgrade2.slot) + " Slot", 0.9, 0.9, 0);
            
            // Wrap description text if too long
            draw_set_color(c_white);
            var desc2 = upgrade2.description;
            if (string_length(desc2) > 18) {
                // Split long descriptions at word boundaries
                var words2 = string_split(desc2, " ");
                var line1_2 = "";
                var line2_2 = "";
                var char_count2 = 0;
                
                for (var j = 0; j < array_length(words2); j++) {
                    if (char_count2 + string_length(words2[j]) < 18) {
                        line1_2 += words2[j] + " ";
                        char_count2 += string_length(words2[j]) + 1;
                    } else {
                        line2_2 += words2[j] + " ";
                    }
                }
                
                draw_text_transformed(right_x, center_y, string_trim(line1_2), 1.1, 1.1, 0);
                if (string_length(line2_2) > 0) {
                    draw_text_transformed(right_x, center_y + 18, string_trim(line2_2), 1.1, 1.1, 0);
                }
            } else {
                draw_text_transformed(right_x, center_y, desc2, 1.1, 1.1, 0);
            }
        }
        
        // Instructions
        draw_set_color(c_yellow);
        draw_text_transformed(center_x, center_y + 80, "Press 1 or 2 to select upgrade", 1.3, 1.3, 0);

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
          
    } else if (turn_manager.game_state == "planet_landing_confirm") {
        // Planet Landing Confirmation
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // Background box
        draw_set_color(c_black);
        draw_set_alpha(0.9);
        draw_rectangle(center_x - 250, center_y - 100, center_x + 250, center_y + 100, false);

        // Title
        draw_set_alpha(1);
        draw_set_color(c_orange);
        draw_text_transformed(center_x, center_y - 60, "PLANET DETECTED", 2.2, 2.2, 0);
        
        draw_set_color(c_white);
        draw_text_transformed(center_x, center_y - 30, "Land and explore the planet?", 1.4, 1.4, 0);
        
        // Description
        draw_set_color(c_ltgray);
        draw_text_transformed(center_x, center_y - 5, "You may find resources, crew, or danger", 1.1, 1.1, 0);

        // Options
        draw_set_color(c_lime);
        draw_text_transformed(center_x - 80, center_y + 30, "[Y] Yes - Land", 1.3, 1.3, 0);
        draw_set_color(c_red);
        draw_text_transformed(center_x + 80, center_y + 30, "[N] No - Stay", 1.3, 1.3, 0);
        
        draw_set_color(c_yellow);
        draw_text_transformed(center_x, center_y + 60, "Choose wisely - planet exploration uses time", 0.9, 0.9, 0);

        // Reset alignment
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
      }
 }