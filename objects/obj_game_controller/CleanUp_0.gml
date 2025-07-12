/// @description Clean up all systems on game exit with proper order
logger_write(LogLevel.INFO, "GameController", "Starting game shutdown sequence", "CleanUp event triggered");

// Step 1: Unregister observers first to prevent new events
try {
    gamestate_remove_observer("unit_clicked", game_controller_handle_unit_click);
    gamestate_remove_observer("unit_order_issued", game_controller_handle_unit_order);
    gamestate_remove_observer("hex_clicked", game_controller_handle_hex_click);
    logger_write(LogLevel.INFO, "GameController", "Observers unregistered", "Cleanup step 1");
} catch (error) {
    show_debug_message("[ERROR] Observer cleanup failed: " + string(error));
}

// Step 2: Save configuration before any systems are destroyed
try {
    config_save();
    logger_write(LogLevel.INFO, "GameController", "Configuration saved", "Cleanup step 2");
} catch (error) {
    show_debug_message("[ERROR] Config save failed: " + string(error));
}

// Step 3: Clean up UI first (but don't log after dev console is destroyed)
try {
    if (instance_exists(obj_UIManager)) {
        with (obj_UIManager) {
            // Call ui_cleanup directly without logging
            ui_close_all_panels();
            if (variable_instance_exists(id, "panel_instances")) {
                ds_map_destroy(panel_instances);
            }
        }
        show_debug_message("[INFO] UI cleanup completed");
    }
} catch (error) {
    show_debug_message("[ERROR] UI cleanup failed: " + string(error));
}

// Step 4: Clean up input system
try {
    input_cleanup();
    logger_write(LogLevel.INFO, "GameController", "Input system cleaned up", "Cleanup step 4");
} catch (error) {
    show_debug_message("[ERROR] Input cleanup failed: " + string(error));
}

// Step 5: Clean up asset system
try {
    assets_cleanup();
    logger_write(LogLevel.INFO, "GameController", "Asset system cleaned up", "Cleanup step 5");
} catch (error) {
    show_debug_message("[ERROR] Asset cleanup failed: " + string(error));
}

// Step 6: Clean up game state
try {
    gamestate_cleanup();
    logger_write(LogLevel.INFO, "GameController", "Game state cleaned up", "Cleanup step 6");
} catch (error) {
    show_debug_message("[ERROR] GameState cleanup failed: " + string(error));
}

// Step 7: Clean up dev console LAST (since other systems may try to log during cleanup)
try {
    if (instance_exists(obj_DevConsole)) {
        with (obj_DevConsole) {
            // Clean up manually to avoid recursive logging
            if (variable_global_exists("dev_console") && !is_undefined(global.dev_console)) {
                if (variable_struct_exists(global.dev_console, "history") && 
                    !is_undefined(global.dev_console.history) && 
                    ds_exists(global.dev_console.history, ds_type_list)) {
                    ds_list_destroy(global.dev_console.history);
                }
                
                if (variable_struct_exists(global.dev_console, "command_history") && 
                    !is_undefined(global.dev_console.command_history) && 
                    ds_exists(global.dev_console.command_history, ds_type_list)) {
                    ds_list_destroy(global.dev_console.command_history);
                }
            }
            
            if (variable_global_exists("dev_commands") && 
                !is_undefined(global.dev_commands) && 
                ds_exists(global.dev_commands, ds_type_map)) {
                ds_map_destroy(global.dev_commands);
            }
        }
        show_debug_message("[INFO] Dev console cleaned up");
    }
} catch (error) {
    show_debug_message("[ERROR] Dev console cleanup failed: " + string(error));
}

show_debug_message("[INFO] GameController: Game shutdown complete - All systems cleaned up");