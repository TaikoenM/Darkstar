/// @description Create and open a UI panel
function ui_open_panel(panel_type, data = {}) {
    // Validate panel_type parameter
    if (is_undefined(panel_type) || !is_string(panel_type) || panel_type == "") {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "UIManager", "Invalid panel type provided", "Panel type must be a non-empty string");
        }
        return noone;
    }
    
    // Check if UIManager exists
    if (!instance_exists(obj_UIManager)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "UIManager", "UIManager object not found", "Panel creation failed");
        }
        return noone;
    }
    
    // Check if panel of this type already exists
    if (ds_map_exists(obj_UIManager.panel_instances, panel_type)) {
        var existing = obj_UIManager.panel_instances[? panel_type];
        if (instance_exists(existing)) {
            // Bring existing panel to front
            ui_focus_panel(existing);
            return existing;
        }
    }
    
    // Create appropriate panel based on type
    var panel_instance = noone;
    var center_x = display_get_gui_width() / 2;
    var center_y = display_get_gui_height() / 2;
    
    switch (panel_type) {
        case "main_menu":
            // For native observer pattern, we don't use UI panels for main menu
            // Instead, create the main menu manager
            if (!instance_exists(obj_MainMenuManager)) {
                panel_instance = instance_create_layer(0, 0, "Managers", obj_MainMenuManager);
            }
            break;
            
        case "options":
            // TODO: Create options panel when implemented
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "UIManager", "Options panel not implemented", "Panel creation skipped");
            }
            break;
            
        case "input_bindings":
            // TODO: Create input bindings panel when implemented
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "UIManager", "Input bindings panel not implemented", "Panel creation skipped");
            }
            break;
            
        default:
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.ERROR, "UIManager", 
                            string("Unknown panel type: {0}", panel_type), "Panel creation failed");
            }
            return noone;
    }
    
    if (panel_instance != noone) {
        // Initialize panel with data
        with (panel_instance) {
            if (variable_instance_exists(id, "panel_data")) {
                panel_data = other.data;
            }
            if (variable_instance_exists(id, "panel_type")) {
                panel_type = other.panel_type;
            }
        }
        
        // Add to mapping
        obj_UIManager.panel_instances[? panel_type] = panel_instance;
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "UIManager", 
                        string("Opened panel: {0}", panel_type), "UI interaction");
        }
    }
    
    return panel_instance;
}

function ui_close_panel(panel_instance) {
    if (!instance_exists(panel_instance) || !instance_exists(obj_UIManager)) {
        return;
    }
    
    // Safety check for panel_instances map
    if (!variable_instance_exists(obj_UIManager, "panel_instances") ||
        is_undefined(obj_UIManager.panel_instances) ||
        !ds_exists(obj_UIManager.panel_instances, ds_type_map)) {
        return; // Map doesn't exist or was destroyed
    }
    
    // Remove from mapping
    var key = ds_map_find_first(obj_UIManager.panel_instances);
    while (!is_undefined(key)) {
        if (obj_UIManager.panel_instances[? key] == panel_instance) {
            ds_map_delete(obj_UIManager.panel_instances, key);
            break;
        }
        key = ds_map_find_next(obj_UIManager.panel_instances, key);
    }
    
    // Update focus if this was the focused panel
    if (variable_instance_exists(obj_UIManager, "focused_panel") &&
        obj_UIManager.focused_panel == panel_instance) {
        obj_UIManager.focused_panel = noone;
        input_set_ui_focus(false);
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "UIManager", "Closed panel", "UI interaction");
    }
    
    // Destroy the instance
    instance_destroy(panel_instance);
}

function ui_focus_panel(panel_instance) {
    if (!instance_exists(panel_instance) || !instance_exists(obj_UIManager)) {
        return;
    }
    
    // Unfocus previous panel
    if (variable_instance_exists(obj_UIManager, "focused_panel") &&
        instance_exists(obj_UIManager.focused_panel)) {
        with (obj_UIManager.focused_panel) {
            if (variable_instance_exists(id, "has_focus")) {
                has_focus = false;
            }
        }
    }
    
    // Set new focus
    if (variable_instance_exists(obj_UIManager, "focused_panel")) {
        obj_UIManager.focused_panel = panel_instance;
    }
    
    with (panel_instance) {
        if (variable_instance_exists(id, "has_focus")) {
            has_focus = true;
        }
    }
    
    // Tell input system that UI has focus
    input_set_ui_focus(true);
}

function ui_close_all_panels() {
    if (!instance_exists(obj_UIManager)) {
        return;
    }
    
    // Safety check for panel_instances map
    if (!variable_instance_exists(obj_UIManager, "panel_instances") ||
        is_undefined(obj_UIManager.panel_instances) ||
        !ds_exists(obj_UIManager.panel_instances, ds_type_map)) {
        return; // Map doesn't exist or was destroyed
    }
    
    // Get all panel instances
    var panels_to_close = ds_list_create();
    var key = ds_map_find_first(obj_UIManager.panel_instances);
    while (!is_undefined(key)) {
        var panel = obj_UIManager.panel_instances[? key];
        if (instance_exists(panel)) {
            ds_list_add(panels_to_close, panel);
        }
        key = ds_map_find_next(obj_UIManager.panel_instances, key);
    }
    
    // Close each panel
    for (var i = 0; i < ds_list_size(panels_to_close); i++) {
        ui_close_panel(panels_to_close[| i]);
    }
    
    ds_list_destroy(panels_to_close);
    
    // Release input focus
    input_set_ui_focus(false);
}

/// @description Safe cleanup function that doesn't log to avoid dev console conflicts
function ui_cleanup() {
    // Don't log here to avoid dev console conflicts during shutdown
    
    // Close all panels first if UIManager still exists and has valid data
    if (instance_exists(obj_UIManager)) {
        ui_close_all_panels();
        
        // Clean up the panel instances map if it exists and is valid
        with (obj_UIManager) {
            if (variable_instance_exists(id, "panel_instances") && 
                !is_undefined(panel_instances) && 
                ds_exists(panel_instances, ds_type_map)) {
                ds_map_destroy(panel_instances);
                panel_instances = undefined; // Mark as destroyed
            }
        }
    }
}