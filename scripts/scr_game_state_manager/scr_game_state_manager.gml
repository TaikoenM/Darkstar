/// @description Initialize the game state management system
/// @description Sets up global state variables and callback system
/// @description Must be called during game initialization before any state changes
function gamestate_init() {
    global.game_state = GameState.INITIALIZING;
    global.previous_game_state = GameState.INITIALIZING;
    global.state_change_callbacks = ds_map_create();
    
    // Safe logging - check if logger is initialized
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateManager", "Game state manager initialized", "System startup");
    }
}

/// @description Change the current game state with logging and callback execution
/// @param {Constant.GameState} new_state The new GameState enum value to transition to
/// @param {string} reason Optional reason for the state change for logging
/// @return {bool} True if state change was successful, false if already in that state
function gamestate_change(new_state, reason = "") {
    if (global.game_state == new_state) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.WARNING, "GameStateManager", 
                        string("Attempted to change to same state: {0}", new_state), reason);
        }
        return false;
    }
    
    global.previous_game_state = global.game_state;
    global.game_state = new_state;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateManager", 
                    string("State changed from {0} to {1}", global.previous_game_state, new_state), reason);
    }
    
    // Execute callbacks for this state change
    gamestate_execute_callbacks(new_state);
    return true;
}

/// @description Get the current game state
/// @return {Constant.GameState} Current GameState enum value
function gamestate_get() {
    return global.game_state;
}

/// @description Get the previous game state
/// @return {Constant.GameState} Previous GameState enum value  
function gamestate_get_previous() {
    return global.previous_game_state;
}

/// @description Register a callback function to be called when entering a specific state
/// @param {Constant.GameState} state GameState enum value to watch for
/// @param {function} callback Function to call when the state is entered
function gamestate_register_callback(state, callback) {
    var callback_list = global.state_change_callbacks[? state];
    if (is_undefined(callback_list)) {
        callback_list = ds_list_create();
        global.state_change_callbacks[? state] = callback_list;
    }
    ds_list_add(callback_list, callback);
}

/// @description Execute all registered callbacks for a given state
/// @param {Constant.GameState} state GameState enum value that was entered
function gamestate_execute_callbacks(state) {
    var callback_list = global.state_change_callbacks[? state];
    if (!is_undefined(callback_list)) {
        for (var i = 0; i < ds_list_size(callback_list); i++) {
            var callback = callback_list[| i];
            try {
                callback();
            } catch (error) {
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.ERROR, "GameStateManager", 
                                string("Error executing state callback: {0}", error), string("State: {0}", state));
                }
            }
        }
    }
}

/// @description Cleanup the game state manager and free memory
/// @description Should be called during game shutdown
function gamestate_cleanup() {
    // Clean up callback lists
    var key = ds_map_find_first(global.state_change_callbacks);
    while (!is_undefined(key)) {
        var callback_list = global.state_change_callbacks[? key];
        if (!is_undefined(callback_list)) {
            ds_list_destroy(callback_list);
        }
        key = ds_map_find_next(global.state_change_callbacks, key);
    }
    
    ds_map_destroy(global.state_change_callbacks);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateManager", "Game state manager cleaned up", "System shutdown");
    }
}