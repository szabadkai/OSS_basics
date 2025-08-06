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
        
        // Enemy count (all types)
        var enemy_count = instance_number(obj_enemy) + instance_number(obj_enemy_fighter) + instance_number(obj_enemy_heavy);
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
            var weapon_text = "W: " + player.upgrades.weapon.name;
            
            // Add range and pattern info for special weapons
            if (variable_struct_exists(player.upgrades.weapon.effects, "max_range")) {
                var range = player.upgrades.weapon.effects.max_range;
                weapon_text += " (R:" + string(range) + ")";
                
                if (variable_struct_exists(player.upgrades.weapon.effects, "firing_pattern")) {
                    var pattern = player.upgrades.weapon.effects.firing_pattern;
                    switch (pattern) {
                        case "line": weapon_text += " Line"; break;
                        case "cone": weapon_text += " Cone"; break;
                        case "indirect": weapon_text += " Indirect"; break;
                    }
                }
            }
            
            draw_text(margin, y_pos, weapon_text);
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
        
    } else if (turn_manager.game_state == "planet_exploration") {
        // Planet Exploration Info Panel
        draw_set_color(c_white);
        draw_set_font(-1);
        
        var info_margin = 16;
        var info_line_height = 18;
        var info_y = info_margin;
        
        // Get planet information
        if (variable_global_exists("current_planet")) {
            var planet = global.current_planet;
            
            // Calculate backdrop height precisely based on actual content
            var backdrop_height = 12; // Small base padding
            
            // Planet name height (accounting for wrapping)
            if (string_length(planet.data.name) > 15) {
                backdrop_height += 2 * info_line_height; // Two lines for wrapped name
            } else {
                backdrop_height += info_line_height; // Single line
            }
            backdrop_height += 4; // Extra spacing after name
            
            // Planet type height (accounting for wrapping)
            var planet_type_text = planet.data.type_data.name;
            if (string_length(planet_type_text) > 20) {
                backdrop_height += 2 * info_line_height; // Two lines for wrapped type
            } else {
                backdrop_height += info_line_height; // Single line
            }
            
            // Level line
            backdrop_height += info_line_height;
            
            // Resource pools section
            if (variable_struct_exists(planet.data, "resource_pools")) {
                var pools = planet.data.resource_pools;
                var pool_names = struct_get_names(pools);
                backdrop_height += (array_length(pool_names) + 1) * info_line_height; // +1 for "Resource Pools:" header
            }
            
            // Controls section
            backdrop_height += 8 + info_line_height; // "Controls:" header with spacing
            backdrop_height += info_line_height; // "B - Return to Space"
            backdrop_height += 2 * info_line_height; // "Explore the surface..." (always wraps)
            backdrop_height += 8; // Bottom padding
            
            // Planet header with precisely sized background
            var backdrop_width = 240; // More compact width
            draw_set_color(c_black);
            draw_set_alpha(0.7);
            draw_rectangle(info_margin - 8, info_y - 4, info_margin + backdrop_width, info_y + backdrop_height, false);
            draw_set_alpha(1);
            
            // Planet name and type (with text wrapping)
            var biome_config = get_biome_config(planet.data.type_data.biome);
            draw_set_color(biome_config.color);
            
            // Wrap planet name if too long (max ~15 characters for 1.4 scale)
            var planet_name = planet.data.name;
            if (string_length(planet_name) > 15) {
                var words = string_split(planet_name, " ");
                var line1 = "";
                var line2 = "";
                var char_count = 0;
                
                for (var i = 0; i < array_length(words); i++) {
                    if (char_count + string_length(words[i]) <= 15) {
                        line1 += words[i] + " ";
                        char_count += string_length(words[i]) + 1;
                    } else {
                        line2 += words[i] + " ";
                    }
                }
                
                draw_text_transformed(info_margin, info_y, string_trim(line1), 1.4, 1.4, 0);
                info_y += info_line_height;
                if (string_length(line2) > 0) {
                    draw_text_transformed(info_margin, info_y, string_trim(line2), 1.4, 1.4, 0);
                    info_y += info_line_height;
                }
            } else {
                draw_text_transformed(info_margin, info_y, planet_name, 1.4, 1.4, 0);
                info_y += info_line_height;
            }
            info_y += 4; // Extra spacing after name
            
            draw_set_color(c_ltgray);
            var planet_type_text = planet.data.type_data.name;
            // Wrap planet type if too long
            if (string_length(planet_type_text) > 20) {
                var type_words = string_split(planet_type_text, " ");
                var type_line1 = "";
                var type_line2 = "";
                var type_char_count = 0;
                
                for (var j = 0; j < array_length(type_words); j++) {
                    if (type_char_count + string_length(type_words[j]) <= 20) {
                        type_line1 += type_words[j] + " ";
                        type_char_count += string_length(type_words[j]) + 1;
                    } else {
                        type_line2 += type_words[j] + " ";
                    }
                }
                
                draw_text(info_margin, info_y, string_trim(type_line1));
                info_y += info_line_height;
                if (string_length(type_line2) > 0) {
                    draw_text(info_margin, info_y, string_trim(type_line2));
                    info_y += info_line_height;
                }
            } else {
                draw_text(info_margin, info_y, planet_type_text);
                info_y += info_line_height;
            }
            
            // Level and difficulty
            draw_set_color(c_yellow);
            draw_text(info_margin, info_y, "Level: " + string(planet.data.level));
            info_y += info_line_height;
            
            // Resource potential
            draw_set_color(c_white);
            draw_text(info_margin, info_y, "Resource Pools:");
            info_y += info_line_height;
            
            if (variable_struct_exists(planet.data, "resource_pools")) {
                var pools = planet.data.resource_pools;
                var pool_names = struct_get_names(pools);
                
                for (var i = 0; i < array_length(pool_names); i++) {
                    var resource_name = pool_names[i];
                    var amount = pools[$ resource_name];
                    
                    // Color code by resource type
                    switch (resource_name) {
                        case "fuel": draw_set_color(c_orange); break;
                        case "materials": draw_set_color(c_silver); break;
                        case "intel": draw_set_color(c_aqua); break;
                        case "crew": draw_set_color(c_lime); break;
                        default: draw_set_color(c_white); break;
                    }
                    
                    draw_text(info_margin + 12, info_y, string_upper(string_char_at(resource_name, 1)) + string_copy(resource_name, 2, string_length(resource_name)) + ": " + string(amount));
                    info_y += info_line_height;
                }
            }
            
            // Controls
            draw_set_color(c_yellow);
            draw_text(info_margin, info_y + 8, "Controls:");
            info_y += info_line_height + 8;
            
            draw_set_color(c_ltgray);
            draw_text(info_margin, info_y, "B - Return to Space");
            info_y += info_line_height;
            
            // Wrap the exploration text (limit to ~18 characters)
            var explore_text = "Explore the surface for resources";
            if (string_length(explore_text) > 18) {
                var explore_words = string_split(explore_text, " ");
                var explore_line1 = "";
                var explore_line2 = "";
                var explore_char_count = 0;
                
                for (var k = 0; k < array_length(explore_words); k++) {
                    if (explore_char_count + string_length(explore_words[k]) <= 18) {
                        explore_line1 += explore_words[k] + " ";
                        explore_char_count += string_length(explore_words[k]) + 1;
                    } else {
                        explore_line2 += explore_words[k] + " ";
                    }
                }
                
                draw_text(info_margin, info_y, string_trim(explore_line1));
                info_y += info_line_height;
                if (string_length(explore_line2) > 0) {
                    draw_text(info_margin, info_y, string_trim(explore_line2));
                }
            } else {
                draw_text(info_margin, info_y, explore_text);
            }
        } else {
            // Fallback if no planet data
            draw_set_color(c_white);
            draw_text(info_margin, info_y, "Planet Exploration");
            info_y += info_line_height;
            draw_set_color(c_ltgray);
            draw_text(info_margin, info_y, "B - Return to Space");
        }
      }
 }