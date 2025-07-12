/// @description Scene state management system for UI states
/// @description Manages transitions between main menu, gameplay, options, etc.
/// @description This is NOT the game state data - that's handled by obj_GameState

/// @description Initialize the scene state management system
function scenestate_init() {
    global.scene_state = SceneState.INITIALIZING;
    global.previous_scene_state = SceneState.INITIALIZING;
    global.scene_change_callbacks = ds_map_create();
    
    // Initialize observer system for scene changes
    scenestate_observer_init();
    
    // Safe logging
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "SceneStateManager", "Scene state manager initialized", "System startup");
    }
}

/// @description Change the current scene state with logging and callback execution
/// @param {Constant.SceneState} new_state The new SceneState enum value to transition to
/// @param {string} reason Optional reason for the state change for logging
/// @return {bool} True if state change was successful, false if already in that state
function scenestate_change(new_state, reason = "") {
    if (global.scene_state == new_state) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.WARNING, "SceneStateManager", 
                        string("Attempted to change to same state: {0}", new_state), reason);
        }
        return false;
    }
    
    global.previous_scene_state = global.scene_state;
    global.scene_state = new_state;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "SceneStateManager", 
                    string("Scene changed from {0} to {1}", global.previous_scene_state, new_state), reason);
    }
    
    // Execute callbacks for this state change
    scenestate_execute_callbacks(new_state);
    
    // Notify observers
    gamestate_notify_observers(EVENT_SCENE_CHANGED, {
        previous: global.previous_scene_state,
        current: new_state,
        reason: reason
    });
    
    return true;
}

/// @description Get the current scene state
/// @return {Constant.SceneState} Current SceneState enum value
function scenestate_get() {
    return global.scene_state;
}

/// @description Get the previous scene state
/// @return {Constant.SceneState} Previous SceneState enum value  
function scenestate_get_previous() {
    return global.previous_scene_state;
}

/// @description Register a callback function to be called when entering a specific state
/// @param {Constant.SceneState} state SceneState enum value to watch for
/// @param {function} callback Function to call when the state is entered
function scenestate_register_callback(state, callback) {
    var callback_list = global.scene_change_callbacks[? state];
    if (is_undefined(callback_list)) {
        callback_list = ds_list_create();
        global.scene_change_callbacks[? state] = callback_list;
    }
    ds_list_add(callback_list, callback);
}

/// @description Execute all registered callbacks for a given state
/// @param {Constant.SceneState} state SceneState enum value that was entered
function scenestate_execute_callbacks(state) {
    var callback_list = global.scene_change_callbacks[? state];
    if (!is_undefined(callback_list)) {
        for (var i = 0; i < ds_list_size(callback_list); i++) {
            var callback = callback_list[| i];
            try {
                callback();
            } catch (error) {
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.ERROR, "SceneStateManager", 
                                string("Error executing state callback: {0}", error), string("State: {0}", state));
                }
            }
        }
    }
}

/// @description Initialize observer system for scene state changes
function scenestate_observer_init() {
    // Observer system is already initialized by gamestate_init
    // This is just a placeholder for scene-specific observer setup if needed
}

/// @description Cleanup the scene state manager and free memory
function scenestate_cleanup() {
    // Clean up callback lists
    var key = ds_map_find_first(global.scene_change_callbacks);
    while (!is_undefined(key)) {
        var callback_list = global.scene_change_callbacks[? key];
        if (!is_undefined(callback_list)) {
            ds_list_destroy(callback_list);
        }
        key = ds_map_find_next(global.scene_change_callbacks, key);
    }
    
    ds_map_destroy(global.scene_change_callbacks);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "SceneStateManager", "Scene state manager cleaned up", "System shutdown");
    }
}