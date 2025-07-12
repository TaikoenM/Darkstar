/// @description Update core game systems each frame
/// @description Processes input, executes commands, and updates game state

// Update input system - must be first to capture input for this frame
input_update();

// Process queued commands
var command = input_dequeue_command();
while (!is_undefined(command)) {
    // Execute command based on current game state
    var current_state = gamestate_get();
    
    switch (current_state) {
        case GameState.IN_GAME:
            // TODO: Process game commands
            break;
            
        case GameState.PAUSED:
            // Only process unpause commands
            if (command.type == CommandType.PAUSE) {
                gamestate_change(GameState.IN_GAME, "Unpaused");
            }
            break;
            
        case GameState.MAP_EDITOR:
            // TODO: Process editor commands
            break;
    }
    
    // Get next command
    command = input_dequeue_command();
}

// Update fixed timestep if enabled
if (variable_global_exists("game_options") && global.game_options.performance.fixed_timestep) {
    // TODO: Implement fixed timestep logic
}