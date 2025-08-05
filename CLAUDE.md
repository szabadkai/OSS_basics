# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GameMaker Studio project for a roguelike space opera game. The project uses GameMaker Language (GML) and follows GameMaker Studio's project structure with .yyp project files and .yy resource definitions.

## Development Environment

- **Engine**: GameMaker Studio 2024.13.1.193
- **Language**: GameMaker Language (GML)
- **Project Type**: Standard GameMaker game project
- **Platform**: Multi-platform (configured for Windows, HTML5, Android, iOS, Linux, Mac, Opera GX, PlayStation, Xbox, Switch)

## Project Structure

### Core Components
- **Main Project File**: `RougueLikeOpera.yyp` - Contains project configuration and resource references
- **Objects**: Game entities with behavior scripts located in `objects/`
  - `obj_player` - Player character with stats system (hp, damage, moves, initiative)
  - `obj_enemy` - Enemy entities with similar stats system
- **Sprites**: Visual assets in `sprites/` including ship graphics, UI elements, and background textures
- **Rooms**: Game levels/scenes in `rooms/`
  - `rm_space_rouglite` - Main game room with layered starfield background
- **Scripts**: Reusable code functions (currently minimal)

### Key Game Systems
- **Turn-based Combat**: Player and enemies have initiative-based turn system
- **Stats System**: HP, damage, moves per turn, and maximum move limits
- **Collision Detection**: Separate collision events for different object types
- **Camera System**: View follows player object with configurable borders

### Visual Design
- Space-themed with layered starfield backgrounds
- Grid-based layout with 32px grid
- Multiple parallax background layers for depth
- Ship sprites for player and enemies

## Architecture Overview

### Manager System Pattern
The game follows a manager-based architecture with dedicated objects handling different systems:
- **Turn Manager** (`obj_turn_manager`): Controls initiative-based turn order, maintains game state, handles win/lose conditions, level progression
- **UI Manager** (`obj_ui_manager`): Manages interface rendering, upgrade selection screens, planet landing confirmations
- **Room Generator** (`obj_room_generator`): Handles procedural enemy and planet placement using grid-based positioning with reachability validation

### Game State Management
The turn manager maintains multiple game states that control different phases:
- `"playing"` - Active turn-based combat
- `"player_win"` - Victory state with auto-advance timer
- `"player_lose"` - Defeat state with restart option
- `"upgrade_selection"` - Post-level ship upgrade selection (2 random choices)
- `"planet_landing_confirm"` - Planet discovery confirmation dialog
- `"planet_exploration"` - Planet surface exploration interface

### Turn-Based Combat System
Central game loop managed by `obj_turn_manager` with these key components:
- Initiative system determining turn order (stored in `turn_entities` array)
- Turn tracking with `current_turn` and `turn_index` variables
- Automatic cleanup of destroyed entities from turn order
- Move-based action system with per-entity move counters

### Modular Ship Upgrade System
Progressive upgrade system through `upgrade_system.gml` script:
- **Three Upgrade Slots**: Thruster (movement), Weapon (combat), Shield (defense)
- **Tier-Based Unlocking**: Higher tier upgrades unlock as levels progress
- **Post-Combat Selection**: Player chooses 1 of 2 random upgrades after clearing each level
- **Stat Recalculation**: Player stats dynamically updated when upgrades applied
- **Special Abilities**: Some upgrades add unique mechanics (area attacks, regeneration)

### Grid-Based Movement Architecture
Movement system unified through `movement_functions.gml` script providing:
- Grid collision detection with animation state awareness
- Smooth interpolated movement between grid positions using easing functions
- Combined movement/attack logic for player actions
- AI pathfinding utilities for enemy behavior
- Breadth-first search for reachability validation

### Level Progression System
Multi-level roguelike progression:
- **Auto-Advance**: Levels progress automatically after defeating all enemies
- **Scaling Difficulty**: Enemy count, HP, and damage increase with level
- **Planet Discovery**: Each level contains discoverable planet objects
- **Dual Environment**: Space combat + planet exploration rooms

### Planet Exploration System
Two-phase exploration mechanic:
- **Space Discovery**: Planet objects spawn in space combat rooms, trigger landing confirmation on contact
- **Room Transition**: Confirmed landings transition to dedicated planet map room (`rm_planet_map`)
- **Textual Interface**: Planet exploration uses text-based UI showing sites, resources, and danger levels
- **Resource Generation**: Procedural resource and hazard generation based on planet types

### Entity System
All game entities (player/enemies) share common patterns:
- Stats system: hp, damage, moves_max, init (initiative)
- Turn state: is_myturn boolean, moves remaining counter
- Animation state: is_animating, move timing variables
- Damage system: `take_damage()` function with visual feedback and death delays

## Development Workflow

### Building and Running
GameMaker Studio projects are built and run through the GameMaker IDE:
1. Open the project file `RougueLikeOpera.yyp` in GameMaker Studio
2. Use F5 or the Run button to test the game
3. Use F6 for full compile and run
4. Platform-specific builds are created through the IDE's build tools

### File Organization
- **GML Scripts**: Event-based scripts in object folders (Create_0.gml, Step_0.gml, Draw_0.gml, etc.)
- **Resource Files**: JSON-based .yy files define sprites, objects, rooms, and other assets
- **Asset Files**: PNG images stored in sprite subfolders with layers/
- **Project Configuration**: Various options/ folders contain platform-specific settings

### Code Conventions
- Variable naming uses snake_case (e.g., `hp_max`, `moves_max`, `is_myturn`)
- Boolean flags prefixed with "is_" (e.g., `is_animating`, `is_myturn`)
- Stats variables follow pattern: base_stat, max_stat, current_stat
- Object naming uses obj_ prefix followed by descriptive name
- Manager objects use function variables for complex logic (e.g., `initialize_turns = function()`)
- Global variables prefixed with `global.` (e.g., `global.grid_size`, `global.current_level`)

### Game Logic Patterns
- Create events initialize object properties and stats
- Step events handle per-frame logic and state updates  
- Collision events manage object interactions
- Draw_64 events handle GUI rendering (used for UI managers)
- Turn management through boolean flags and move counters
- Cross-object communication via `with()` statements and `instance_find()`
- Manager references cached in Create events for performance

### Critical Development Patterns
- **Object Registration**: New objects must be added to both `RougueLikeOpera.yyp` resources list and appropriate parent folders
- **Script Dependencies**: Core scripts (`upgrade_system.gml`, `movement_functions.gml`) must be registered in project file
- **Global Variable Safety**: Always check `variable_global_exists()` before accessing globals in Create events
- **State Validation**: Use `object_exists()` checks before calling `with()` statements on optional objects
- **Debug Integration**: Use `show_debug_message()` for development debugging rather than console output

## Important Notes
- This is a GameMaker Studio project, not a traditional text-based codebase
- No traditional build tools (npm, make, etc.) - all building done through GameMaker IDE
- GML files are event scripts, not standalone modules
- Resource files (.yy) are auto-generated by GameMaker IDE and should be edited carefully
- Project uses GameMaker's built-in asset pipeline for sprites, sounds, etc.

## Code Best Practices
- Always make sure that every reference to an outside object is acquired in the Create method
- Only implement a feature if explicitly instructed
- Use manager pattern for complex systems requiring cross-object coordination
- Manager references cached in Create events using `instance_find()`
- When adding new objects or scripts, always update the project file (`RougueLikeOpera.yyp`) resources list
- Use safety checks (`object_exists()`, `variable_global_exists()`) before accessing external objects or globals
- Prefer `show_debug_message()` over other output methods for debugging

## Common Development Issues and Solutions

### Object/Script Registration Errors
**Symptom**: `Variable <unknown_object>` or `not set before reading` errors
**Solution**: Add missing objects/scripts to `RougueLikeOpera.yyp` resources list in correct alphabetical order

### Missing Planet System Functions  
**Symptom**: `generate_planet_data` not found errors
**Solution**: Ensure `planet_system` script is registered in project file resources

### UI Not Displaying
**Symptom**: Black screen or missing UI elements
**Solution**: Check object creation in room creation code, verify Draw_64 events are properly configured

### Room Transition Issues
**Symptom**: Room transitions fail or game state gets stuck
**Solution**: Verify game state is reset to `"playing"` before room transitions, check target room exists

## References
- You can find reference to the framework https://manual.gamemaker.io/monthly/en/#t=Content.htm here