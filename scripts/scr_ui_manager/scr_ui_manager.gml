/// @function ui_open_panel(panel_type, data)
/// @description Create and open a UI panel
/// @param {string} panel_type Type of panel to open
/// @param {struct} data Data to pass to the panel
/// @return {id} Instance ID of created panel
function ui_open_panel(panel_type, data = {}) {
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
            panel_instance = instance_create_layer(center_x, center_y, "UI", obj_UI_MainMenuPanel);
            break;
            
        case "options":
            panel_instance = instance_create_layer(center_x, center_y, "UI", obj_UI_OptionsPanel);
            break;
            
        case "input_bindings":
            panel_instance = instance_create_layer(center_x, center_y, "UI", obj_UI_InputBindingsPanel);
            break;
            
        default:
            logger_write(LogLevel.ERROR, "UIManager", 
                        string("Unknown panel type: {0}", panel_type), "Panel creation failed");
            return noone;
    }
    
    if (panel_instance != noone) {
        // Initialize panel with data
        with (panel_instance) {
            panel_data = data;
            panel_type = panel_type;
        }
        
        // Add to stack and mapping
        ds_list_add(obj_UIManager.ui_panel_stack, panel_instance);
        obj_UIManager.panel_instances[? panel_type] = panel_instance;
        
        // Focus the new panel
        ui_focus_panel(panel_instance);
        
        logger_write(LogLevel.INFO, "UIManager", 
                    string("Opened panel: {0}", panel_type), "UI interaction");
    }
    
    return panel_instance;
}

/// @function ui_close_panel(panel_instance)
/// @description Close a UI panel
/// @param {id} panel_instance Instance ID of panel to close
function ui_close_panel(panel_instance) {
    if (!instance_exists(panel_instance)) {
        return;
    }
    
    // Remove from stack
    var stack_pos = ds_list_find_index(obj_UIManager.ui_panel_stack, panel_instance);
    if (stack_pos != -1) {
        ds_list_delete(obj_UIManager.ui_panel_stack, stack_pos);
    }
    
    // Remove from mapping
    var panel_type = panel_instance.panel_type;
    if (ds_map_exists(obj_UIManager.panel_instances, panel_type)) {
        ds_map_delete(obj_UIManager.panel_instances, panel_type);
    }
    
    // Update focus if this was the focused panel
    if (obj_UIManager.focused_panel == panel_instance) {
        obj_UIManager.focused_panel = noone;
        
        // Focus next panel in stack if any
        if (!ds_list_empty(obj_UIManager.ui_panel_stack)) {
            var top_panel = obj_UIManager.ui_panel_stack[| ds_list_size(obj_UIManager.ui_panel_stack) - 1];
            ui_focus_panel(top_panel);
        } else {
            // No panels left, release input focus
            input_set_ui_focus(false);
        }
    }
    
    logger_write(LogLevel.INFO, "UIManager", 
                string("Closed panel: {0}", panel_type), "UI interaction");
    
    // Destroy the instance
    instance_destroy(panel_instance);
}

/// @function ui_focus_panel(panel_instance)
/// @description Give input focus to a panel
/// @param {id} panel_instance Panel to focus
function ui_focus_panel(panel_instance) {
    if (!instance_exists(panel_instance)) {
        return;
    }
    
    // Unfocus previous panel
    if (instance_exists(obj_UIManager.focused_panel)) {
        with (obj_UIManager.focused_panel) {
            has_focus = false;
        }
    }
    
    // Set new focus
    obj_UIManager.focused_panel = panel_instance;
    with (panel_instance) {
        has_focus = true;
    }
    
    // Move to top of stack
    var stack_pos = ds_list_find_index(obj_UIManager.ui_panel_stack, panel_instance);
    if (stack_pos != -1) {
        ds_list_delete(obj_UIManager.ui_panel_stack, stack_pos);
        ds_list_add(obj_UIManager.ui_panel_stack, panel_instance);
    }
    
    // Tell input system that UI has focus
    input_set_ui_focus(true);
}

/// @function ui_close_all_panels()
/// @description Close all open UI panels
function ui_close_all_panels() {
    // Copy list to avoid modification during iteration
    var panels_to_close = ds_list_create();
    ds_list_copy(panels_to_close, obj_UIManager.ui_panel_stack);
    
    // Close each panel
    for (var i = 0; i < ds_list_size(panels_to_close); i++) {
        ui_close_panel(panels_to_close[| i]);
    }
    
    ds_list_destroy(panels_to_close);
    
    // Release input focus
    input_set_ui_focus(false);
}

/// @function ui_cleanup()
/// @description Cleanup UI manager resources
function ui_cleanup() {
    ui_close_all_panels();
    ds_list_destroy(obj_UIManager.ui_panel_stack);
    ds_map_destroy(obj_UIManager.panel_instances);
    
    logger_write(LogLevel.INFO, "UIManager", "UI Manager cleaned up", "System shutdown");
}