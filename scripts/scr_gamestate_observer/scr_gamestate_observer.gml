/// @description Observer pattern implementation for GameState events with safe cleanup
/// @description Allows objects to register for and receive notifications about game events

/// @description Initialize the observer system
/// @description Called automatically by gamestate_init()
function gamestate_observer_init() {
    // Map of event names to list of observer functions
    global.gamestate_observers = ds_map_create();
    global.observer_system_active = true; // Flag to track if system is active
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateObserver", "Observer system initialized", "System startup");
    }
}

/// @description Register an observer function for a specific event
/// @param {string} event_name Name of the event to observe
/// @param {function} callback Function to call when event occurs
function gamestate_add_observer(event_name, callback) {
    // Safety check - don't add observers if system is shutting down
    if (!variable_global_exists("observer_system_active") || !global.observer_system_active) {
        return;
    }
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        return;
    }
    
    if (!ds_map_exists(global.gamestate_observers, event_name)) {
        global.gamestate_observers[? event_name] = ds_list_create();
    }
    
    var observer_list = global.gamestate_observers[? event_name];
    ds_list_add(observer_list, callback);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", 
                    string("Added observer for event: {0}", event_name), "Observer registered");
    }
}

/// @description Remove an observer function for a specific event
/// @param {string} event_name Name of the event
/// @param {function} callback Function to remove
function gamestate_remove_observer(event_name, callback) {
    // Enhanced safety checks - exit early if system is inactive or destroyed
    if (!variable_global_exists("observer_system_active") || !global.observer_system_active) {
        return; // System is shutting down, safe to ignore
    }
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        return; // Observer system already destroyed
    }
    
    // Check if the ds_map still exists and is valid
    if (!ds_exists(global.gamestate_observers, ds_type_map)) {
        return; // Map was destroyed
    }
    
    if (!ds_map_exists(global.gamestate_observers, event_name)) {
        return; // Event not registered
    }
    
    var observer_list = global.gamestate_observers[? event_name];
    if (is_undefined(observer_list) || !ds_exists(observer_list, ds_type_list)) {
        return; // List doesn't exist or was destroyed
    }
    
    var index = ds_list_find_index(observer_list, callback);
    
    if (index != -1) {
        ds_list_delete(observer_list, index);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "GameStateObserver", 
                        string("Removed observer for event: {0}", event_name), "Observer unregistered");
        }
    }
    
    // Clean up empty lists
    if (ds_list_empty(observer_list)) {
        ds_list_destroy(observer_list);
        ds_map_delete(global.gamestate_observers, event_name);
    }
}

/// @description Notify all observers of an event
/// @param {string} event_name Name of the event that occurred
/// @param {struct} event_data Data associated with the event
function gamestate_notify_observers(event_name, event_data = {}) {
    // Safety check - don't notify if system is shutting down
    if (!variable_global_exists("observer_system_active") || !global.observer_system_active) {
        return;
    }
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        return;
    }
    
    if (!ds_exists(global.gamestate_observers, ds_type_map)) {
        return;
    }
    
    if (!ds_map_exists(global.gamestate_observers, event_name)) {
        return;
    }
    
    var observer_list = global.gamestate_observers[? event_name];
    if (is_undefined(observer_list) || !ds_exists(observer_list, ds_type_list)) {
        return;
    }
    
    var observer_count = ds_list_size(observer_list);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", 
                    string("Notifying {0} observers of event: {1}", observer_count, event_name), 
                    "Event dispatched");
    }
    
    // Call each observer
    for (var i = 0; i < observer_count; i++) {
        var callback = observer_list[| i];
        try {
            callback(event_data);
        } catch (error) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.ERROR, "GameStateObserver", 
                            string("Error in observer callback: {0}", error), 
                            string("Event: {0}", event_name));
            }
        }
    }
}

/// @description Clean up the observer system
/// @description Called during gamestate cleanup
function gamestate_observer_cleanup() {
    // Mark system as inactive first to prevent new registrations
    global.observer_system_active = false;
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        return; // Already cleaned up
    }
    
    if (!ds_exists(global.gamestate_observers, ds_type_map)) {
        return; // Map was already destroyed
    }
    
    // Destroy all observer lists
    var key = ds_map_find_first(global.gamestate_observers);
    while (!is_undefined(key)) {
        var observer_list = global.gamestate_observers[? key];
        if (!is_undefined(observer_list) && ds_exists(observer_list, ds_type_list)) {
            ds_list_destroy(observer_list);
        }
        key = ds_map_find_next(global.gamestate_observers, key);
    }
    
    // Destroy the main map
    ds_map_destroy(global.gamestate_observers);
    global.gamestate_observers = -1; // Mark as destroyed
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateObserver", "Observer system cleaned up", "System shutdown");
    }
}