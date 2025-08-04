// Room Generator - spawns enemies randomly
grid_size = global.grid_size;
enemy_count = 15;

// Generate random enemy positions
generate_enemies = function() {
    // Clear existing enemies first
    with(obj_enemy) {
        instance_destroy();
    }
    
    // Get player position to avoid spawning on player
    var player = instance_find(obj_player, 0);
    var player_grid_x = -1;
    var player_grid_y = -1;
    
    if (player != noone) {
        player_grid_x = player.x div grid_size;
        player_grid_y = player.y div grid_size;
    }
    
    // Calculate room dimensions in grid units
    // Since entities are centered on tiles, we need to ensure they don't spawn outside bounds
    var room_grid_width = room_width div grid_size;
    var room_grid_height = room_height div grid_size;
    
    show_debug_message("Room dimensions: " + string(room_width) + "x" + string(room_height) + " pixels = " + string(room_grid_width) + "x" + string(room_grid_height) + " grid cells");
    
    // Track occupied positions
    var occupied_positions = [];
    if (player != noone) {
        array_push(occupied_positions, [player_grid_x, player_grid_y]);
    }
    
    // Spawn enemies
    var spawned = 0;
    var attempts = 0;
    var max_attempts = 1000; // Prevent infinite loops
    
    while (spawned < enemy_count && attempts < max_attempts) {
        attempts++;
        
        // Generate random grid position
        // Make sure we stay within bounds when entities are centered on tiles
        var grid_x = irandom(room_grid_width - 1);
        var grid_y = irandom(room_grid_height - 1);
        
        // Additional safety check: ensure the centered position is within room bounds
        var world_x = grid_x * grid_size + (grid_size / 2);
        var world_y = grid_y * grid_size + (grid_size / 2);
        
        // Skip if the centered position would be outside the room (using same bounds logic as movement functions)
        if (world_x < grid_size/2 || world_x >= room_width - grid_size/2 || 
            world_y < grid_size/2 || world_y >= room_height - grid_size/2) {
            show_debug_message("Skipping out-of-bounds position: grid(" + string(grid_x) + ", " + string(grid_y) + ") -> world(" + string(world_x) + ", " + string(world_y) + ")");
            continue;
        }
        
        // Check if position is already occupied
        var position_free = true;
        for (var i = 0; i < array_length(occupied_positions); i++) {
            if (occupied_positions[i][0] == grid_x && occupied_positions[i][1] == grid_y) {
                position_free = false;
                break;
            }
        }
        
        if (position_free) {
            // world_x and world_y are already calculated above for bounds checking
            
            // Spawn enemy
            var enemy = instance_create_layer(world_x, world_y, "Instances", obj_enemy);
            
            // Add position to occupied list
            array_push(occupied_positions, [grid_x, grid_y]);
            spawned++;
            
            show_debug_message("Spawned enemy " + string(spawned) + " at grid(" + string(grid_x) + ", " + string(grid_y) + ") -> world(" + string(world_x) + ", " + string(world_y) + ")");
        }
    }
    
    if (spawned < enemy_count) {
        show_debug_message("Warning: Only spawned " + string(spawned) + " out of " + string(enemy_count) + " enemies");
    }
    
    show_debug_message("Room generation complete. Spawned " + string(spawned) + " enemies in " + string(attempts) + " attempts");
};

// Generate enemies on room start
generate_enemies();

// Generate random tiles at 5% coverage on Tiles_1 layer
show_debug_message("Starting tile generation after enemy generation...");
show_debug_message("Current enemy count: " + string(instance_number(obj_enemy)));
var tiles_placed = generate_random_tiles(5, "Tiles_1");
show_debug_message("Tile generation complete. Placed " + string(tiles_placed) + " tiles.");