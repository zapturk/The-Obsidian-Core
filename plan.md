# Implementation Plan

## Goal
Implement discrete, atomic, grid-based movement for the Player that respects `Solid` collisions and updates the `Interact` component direction.

## Tasks

1. **Define Player Constants and State**
   - File: `the-obsidian-core/Entities/Player/player.gd`
   - Changes: 
     - Add `const TILE_SIZE = 16`.
     - Add `var is_moving: bool = false`.
     - Add `var current_direction: Vector2 = Vector2.DOWN`.
   - Acceptance: Variables are defined and accessible.

2. **Implement Directional Sync**
   - File: `the-obsidian-core/Entities/Player/player.gd`
   - Changes: 
     - Create `func update_interact_direction()`.
     - Inside, set `$Interact.target_position = current_direction * TILE_SIZE`.
     - Ensure `$SolidDetector.target_position` is also updated (if it's a RayCast2D) to match `current_direction * TILE_SIZE`.
   - Acceptance: Calling the function updates the sub-components' orientation.

3. **Implement Input Handling and Direction Selection**
   - File: `the-obsidian-core/Entities/Player/player.gd`
   - Changes: 
     - Implement `_physics_process(_delta: float)`.
     - Check `if is_moving: return`.
     - Capture input (Up, Down, Left, Right).
     - Prioritize cardinal directions (prevent diagonal movement).
     - Update `current_direction` and call `update_interact_direction()`.
     - If a direction is valid, call `try_move(direction)`.
   - Acceptance: Player only accepts one cardinal direction at a time.

4. **Implement Collision-Aware Movement (`try_move`)**
   - File: `the-obsidian-core/Entities/Player/player.gd`
   - Changes:
     - `func try_move(direction: Vector2)`:
       - Calculate `var next_pos = position + (direction * TILE_SIZE)`.
       - Use `$SolidDetector.force_raycast_update()` to ensure the raycast is current.
       - Check `$SolidDetector.is_colliding()`.
       - If colliding and the collider is a `Solid`, abort movement.
       - If clear, call `move_to(next_pos)`.
   - Acceptance: Player cannot move into a `Solid` area.

5. **Implement Smooth Transition (`move_to`)**
   - File: `the-obsidian-core/Entities/Player/player.gd`
   - Changes:
     - `func move_to(new_pos: Vector2)`:
       - Set `is_moving = true`.
       - Create a `Tween`.
       - Tween `position` to `new_pos` over a short duration (e.g., 0.2s).
       - Connect `tween.finished` to a callback `_on_move_completed`.
     - `func _on_move_completed()`:
       - Set `is_moving = false`.
   - Acceptance: Player moves smoothly and cannot start a new move until the tween finishes.

## Files to Modify
- `the-obsidian-core/Entities/Player/player.gd` - Full rewrite of the movement logic.

## Dependencies
- Requires `the-obsidian-core/Componets/solid.gd` to be present (already verified).
- Requires `$Interact` and `$SolidDetector` nodes to exist in `player.tscn`.

## Risks
- **Node Missing**: If `$SolidDetector` or `$Interact` is not a child of Player in the scene, the script will crash. (Checked `player.tscn`, it currently only has `Interact`). *Self-correction: I must ensure the plan accounts for adding the SolidDetector to the scene if it's missing, or assume it's added via the implementation phase.*
- **Raycast Update**: Raycasts in Godot don't always update position immediately when moved in the same frame; `force_raycast_update()` is critical.