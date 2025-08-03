turn_manager = instance_find(obj_turn_manager, 0);

// Random background music selection
var music_tracks = [Sound1, Sound3, Sound4]; // Add more tracks here as available
var random_track = music_tracks[irandom(array_length(music_tracks) - 1)];
global.Music = audio_play_sound(random_track, 1, true);
