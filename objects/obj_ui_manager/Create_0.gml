turn_manager = instance_find(obj_turn_manager, 0);

// Random background music selection
var music_tracks = [Sound1, Sound3, Sound4]; // Add more tracks here as available
var random_track = music_tracks[irandom(array_length(music_tracks) - 1)];
global.Music = audio_play_sound(random_track, 1, true);

// Text wrapping utility function
wrap_text = function(text, max_chars_per_line) {
    var words = string_split(text, " ");
    var lines = [];
    var current_line = "";
    
    for (var i = 0; i < array_length(words); i++) {
        var word = words[i];
        
        // Check if adding this word would exceed the line limit
        if (string_length(current_line + " " + word) > max_chars_per_line && current_line != "") {
            // Current line is full, start a new one
            array_push(lines, current_line);
            current_line = word;
        } else {
            // Add word to current line
            if (current_line == "") {
                current_line = word;
            } else {
                current_line += " " + word;
            }
        }
    }
    
    // Don't forget the last line
    if (current_line != "") {
        array_push(lines, current_line);
    }
    
    return lines;
};
