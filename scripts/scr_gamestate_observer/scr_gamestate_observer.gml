/// @description Observer pattern implementation for GameState events with safe cleanup
/// @description Allows objects to register for and receive notifications about game events

/// @description Initialize the observer system
/// @description Called automatically by gamestate_init()
function gamestate_observer_init() {
    logger_write(LogLevel.DEBUG, "GameStateObserver", "gamestate_observer_init started", "Observer system initialization");
    
    // Map of event names to list of observer functions
    global.gamestate_observers = ds_map_create();
    global.observer_system_active = true; // Flag to track if system is active
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateObserver", "Observer system initialized", "System startup");
    }
    
    logger_write(LogLevel.DEBUG, "GameStateObserver", "gamestate_observer_init completed", 
                string("Observer map created, system active: {0}", global.observer_system_active));
}

/// @description Register an observer function for a specific event
/// @param {string} event_name Name of the event to observe
/// @param {function} callback Function to call when event occurs
function gamestate_add_observer(event_name, callback) {
    logger_write(LogLevel.DEBUG, "GameStateObserver", "gamestate_add_observer called", 
                string("Event: '{0}', Callback: {1}", event_name, callback));
    
    // Safety check - don't add observers if system is shutting down
    if (!variable_global_exists("observer_system_active") || !global.observer_system_active) {
        logger_write(LogLevel.WARNING, "GameStateObserver", "Add observer rejected - system inactive", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        logger_write(LogLevel.ERROR, "GameStateObserver", "Add observer failed - no observer map", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    if (!ds_map_exists(global.gamestate_observers, event_name)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Creating new observer list", 
                    string("Event: '{0}'", event_name));
        global.gamestate_observers[? event_name] = ds_list_create();
    }
    
    var observer_list = global.gamestate_observers[? event_name];
    ds_list_add(observer_list, callback);
    
    logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer added successfully", 
                string("Event: '{0}', List size: {1}", event_name, ds_list_size(observer_list)));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", 
                    string("Added observer for event: {0}", event_name), "Observer registered");
    }
}

/// @description Remove an observer function for a specific event
/// @param {string} event_name Name of the event
/// @param {function} callback Function to remove
function gamestate_remove_observer(event_name, callback) {
    logger_write(LogLevel.DEBUG, "GameStateObserver", "gamestate_remove_observer called", 
                string("Event: '{0}', Callback: {1}", event_name, callback));
    
    // Enhanced safety checks - exit early if system is inactive or destroyed
    if (!variable_global_exists("observer_system_active") || !global.observer_system_active) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Remove observer - system inactive", 
                    string("Event: '{0}'", event_name));
        return; // System is shutting down, safe to ignore
    }
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Remove observer - no observer map", 
                    string("Event: '{0}'", event_name));
        return; // Observer system already destroyed
    }
    
    // Check if the ds_map still exists and is valid
    if (!ds_exists(global.gamestate_observers, ds_type_map)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Remove observer - map destroyed", 
                    string("Event: '{0}'", event_name));
        return; // Map was destroyed
    }
    
    if (!ds_map_exists(global.gamestate_observers, event_name)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Remove observer - event not registered", 
                    string("Event: '{0}'", event_name));
        return; // Event not registered
    }
    
    var observer_list = global.gamestate_observers[? event_name];
    if (is_undefined(observer_list) || !ds_exists(observer_list, ds_type_list)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Remove observer - list invalid", 
                    string("Event: '{0}'", event_name));
        return; // List doesn't exist or was destroyed
    }
    
    var index = ds_list_find_index(observer_list, callback);
    
    if (index != -1) {
        ds_list_delete(observer_list, index);
        
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer removed successfully", 
                    string("Event: '{0}', Index: {1}, List size: {2}", event_name, index, ds_list_size(observer_list)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "GameStateObserver", 
                        string("Removed observer for event: {0}", event_name), "Observer unregistered");
        }
    } else {
        logger_write(LogLevel.WARNING, "GameStateObserver", "Observer not found for removal", 
                    string("Event: '{0}', Callback: {1}", event_name, callback));
    }
    
    // Clean up empty lists
    if (ds_list_empty(observer_list)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Cleaning up empty observer list", 
                    string("Event: '{0}'", event_name));
        ds_list_destroy(observer_list);
        ds_map_delete(global.gamestate_observers, event_name);
    }
}

/// @description Notify all observers of an event
/// @param {string} event_name Name of the event that occurred
/// @param {struct} event_data Data associated with the event
function gamestate_notify_observers(event_name, event_data = {}) {
    logger_write(LogLevel.DEBUG, "GameStateObserver", "gamestate_notify_observers called", 
                string("Event: '{0}', Data keys: {1}", event_name, 
                       is_struct(event_data) ? array_length(variable_struct_get_names(event_data)) : "not struct"));
    
    // Safety check - don't notify if system is shutting down
    if (!variable_global_exists("observer_system_active") || !global.observer_system_active) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Notify rejected - system inactive", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        logger_write(LogLevel.WARNING, "GameStateObserver", "Notify failed - no observer map", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    if (!ds_exists(global.gamestate_observers, ds_type_map)) {
        logger_write(LogLevel.WARNING, "GameStateObserver", "Notify failed - map destroyed", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    if (!ds_map_exists(global.gamestate_observers, event_name)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "No observers for event", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    var observer_list = global.gamestate_observers[? event_name];
    if (is_undefined(observer_list) || !ds_exists(observer_list, ds_type_list)) {
        logger_write(LogLevel.WARNING, "GameStateObserver", "Observer list invalid", 
                    string("Event: '{0}'", event_name));
        return;
    }
    
    var observer_count = ds_list_size(observer_list);
    
    logger_write(LogLevel.DEBUG, "GameStateObserver", "Notifying observers", 
                string("Event: '{0}', Observer count: {1}", event_name, observer_count));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", 
                    string("Notifying {0} observers of event: {1}", observer_count, event_name), 
                    "Event dispatched");
    }
    
    // Call each observer
    for (var i = 0; i < observer_count; i++) {
        var callback = observer_list[| i];
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Calling observer", 
                    string("Event: '{0}', Observer: {1}/{2}, Callback: {3}", event_name, i+1, observer_count, callback));
        
        try {
            callback(event_data);
            logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer called successfully", 
                        string("Event: '{0}', Observer: {1}", event_name, i+1));
        } catch (error) {
            logger_write(LogLevel.ERROR, "GameStateObserver", "Observer callback error", 
                        string("Event: '{0}', Observer: {1}, Error: {2}", event_name, i+1, error));
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.ERROR, "GameStateObserver", 
                            string("Error in observer callback: {0}", error), 
                            string("Event: {0}", event_name));
            }
        }
    }
    
    logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer notification complete", 
                string("Event: '{0}', Notified: {1} observers", event_name, observer_count));
}

/// @description Clean up the observer system
/// @description Called during gamestate cleanup
function gamestate_observer_cleanup() {
    logger_write(LogLevel.DEBUG, "GameStateObserver", "gamestate_observer_cleanup started", "Observer system cleanup");
    
    // Mark system as inactive first to prevent new registrations
    global.observer_system_active = false;
    
    if (!variable_global_exists("gamestate_observers") || global.gamestate_observers == -1) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer cleanup - already cleaned", "No observer map");
        return; // Already cleaned up
    }
    
    if (!ds_exists(global.gamestate_observers, ds_type_map)) {
        logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer cleanup - map destroyed", "Map was already destroyed");
        return; // Map was already destroyed
    }
    
    // Destroy all observer lists
    var destroyed_lists = 0;
    var key = ds_map_find_first(global.gamestate_observers);
    while (!is_undefined(key)) {
        var observer_list = global.gamestate_observers[? key];
        if (!is_undefined(observer_list) && ds_exists(observer_list, ds_type_list)) {
            logger_write(LogLevel.DEBUG, "GameStateObserver", "Destroying observer list", 
                        string("Event: '{0}', Size: {1}", key, ds_list_size(observer_list)));
            ds_list_destroy(observer_list);
            destroyed_lists++;
        }
        key = ds_map_find_next(global.gamestate_observers, key);
    }
    
    // Destroy the main map
    ds_map_destroy(global.gamestate_observers);
    global.gamestate_observers = -1; // Mark as destroyed
    
    logger_write(LogLevel.DEBUG, "GameStateObserver", "Observer cleanup completed", 
                string("Destroyed {0} observer lists", destroyed_lists));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateObserver", "Observer system cleaned up", "System shutdown");
    }
}