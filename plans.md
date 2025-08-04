# Roguelike Space Opera - Development Plan

## Project Overview
This is a GameMaker Studio roguelike space opera with turn-based combat, grid-based movement, and a modular upgrade system. The core gameplay loop is solid - players move through levels, fight enemies, collect upgrades, and restart fresh on death (pure roguelike approach).

## Current State Assessment
**✅ Working Systems:**
- Turn-based combat with initiative system
- Grid-based movement and collision detection
- Modular upgrade system (thrusters, weapons, shields)
- Basic UI and game state management
- Room generation with procedural enemy placement
- Level progression with upgrade selection between levels

**📋 Core Architecture:**
- Manager-based system (Turn Manager, UI Manager, Room Generator)
- Grid-based movement with smooth animation
- Stats system with base + upgrade calculations
- Initiative-based turn order

## Development Priorities

### Phase 1: Audio Implementation (High Priority)
**Essential Audio Feedback:**
- **Player movement sound** - thruster/engine noise when moving between grid positions
- **Attack/weapon fire sound** - satisfying combat feedback when hitting enemies
- **Player damage sound** - audio cue when player takes damage
- **UI selection sounds** - confirmation beeps for upgrade choices and menu navigation
- **Turn transition cues** - subtle audio indicator for turn changes
- **Victory/defeat stings** - level complete and game over audio
- **Error sounds** - feedback for invalid actions (blocked moves, no moves left)

**Implementation Strategy:**
- Utilize existing sound files (Sound1.wav, Sound2.wav, Sound3.mp3, Sound4.mp3)
- Add audio calls to movement_functions.gml for movement sounds
- Integrate into combat collision events in obj_player and obj_enemy
- Add to upgrade selection UI in obj_turn_manager
- Use audio_play_sound() calls at appropriate trigger points

### Phase 2: UI/UX Polish (Medium Priority)
**Visual Feedback Improvements:**
- Health bars above enemies (similar to player display)
- Turn order indicator showing initiative sequence
- Floating damage numbers when attacks hit
- Upgrade tooltips with detailed stat previews
- Visual feedback for player actions (hit effects, movement trails)
- Better upgrade selection UI with slot indicators

**Technical Implementation:**
- Extend obj_ui_manager Draw_64 event for additional UI elements
- Add visual effects to combat collision events
- Enhance upgrade selection display in turn manager

### Phase 3: Content Expansion (Lower Priority)
**Gameplay Variety:**
- Additional enemy types with different behaviors and stats
- Environmental hazards or obstacles on the grid
- Interactive objects beyond combat (pickups, switches, etc.)
- More upgrade varieties within existing slot types

**System Improvements:**
- Menu systems (main menu, pause menu, options)
- Better game flow between runs
- Additional visual polish and effects

### Phase 4: Optional Enhancements (Future Consideration)
**Meta-progression (if desired):**
- Unlockable ship variants
- Achievement system
- Statistics tracking across runs
- High score persistence

**Advanced Features:**
- Save/persistence systems (if needed)
- Additional platforms optimization
- Extended audio system with background music

## Design Philosophy
- **Pure Roguelike**: No mid-run saving, complete restart on death
- **Tactical Combat**: Every move matters, initiative-based turn system
- **Meaningful Choices**: Each upgrade significantly impacts gameplay
- **Immediate Feedback**: All player actions should have clear audio/visual response

## Next Steps
1. Begin Phase 1 with audio implementation
2. Focus on player action feedback first (movement, combat)
3. Add UI audio for better menu experience
4. Test and iterate on audio balance
5. Move to UI/UX improvements once audio feels right

## Notes
- Core gameplay systems are solid and don't need major changes
- Focus on polish and feedback rather than new mechanics
- GameMaker Studio project structure should be preserved
- Follow existing code conventions and manager patterns