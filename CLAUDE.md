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
- **Turn Manager** (`obj_turn_manager`): Controls initiative-based turn order, maintains game state, handles win/lose conditions
- **UI Manager** (`obj_ui_manager`): Manages interface rendering and background music selection
- **Room Generator** (`obj_room_generator`): Handles procedural enemy placement using grid-based positioning

### Turn-Based Combat System
Central game loop managed by `obj_turn_manager` with these key components:
- Initiative system determining turn order (stored in `turn_entities` array)
- Turn tracking with `current_turn` and `turn_index` variables
- Game state management ("playing", "player_win", "player_lose")
- Automatic cleanup of destroyed entities from turn order

### Grid-Based Movement Architecture
Movement system unified through `movement_functions.gml` script providing:
- Grid collision detection with animation state awareness
- Smooth interpolated movement between grid positions using easing functions
- Combined movement/attack logic for player actions
- AI pathfinding utilities for enemy behavior

### Entity System
All game entities (player/enemies) share common patterns:
- Stats system: hp, damage, moves_max, init (initiative)
- Turn state: is_myturn boolean, moves remaining counter
- Animation state: is_animating, move timing variables

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

### Game Logic Patterns
- Create events initialize object properties and stats
- Step events handle per-frame logic and state updates  
- Collision events manage object interactions
- Draw events handle custom rendering (minimal usage currently)
- Turn management through boolean flags and move counters
- Cross-object communication via `with()` statements and `instance_find()`

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
- Global variables prefixed with `global.` (e.g., `global.grid_size`, `global.Music`)
- Manager references cached in Create events using `instance_find()`

## References
- You can find reference to the framework https://manual.gamemaker.io/monthly/en/#t=Content.htm here