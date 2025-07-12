/// @description Clean up all systems on game exit with proper order

// Important: Mark observer system as shutting down FIRST
if (variable_global_exists("observer_system_active")) {
    global.observer_system_active = false;
}

logger_write(LogLevel.INFO, "GameController", "Starting game shutdown sequence", "CleanUp event triggered");

// Step 1: Unregister observers first to prevent new events during cleanup
try {
    gamestate_remove_observer(EVENT_UNIT_CLICKED, game_controller_handle_unit_click);
    gamestate_remove_observer(EVENT_UNIT_ORDER_ISSUED, game_controller_handle_unit_order);
    gamestate_remove_observer(EVENT_HEX_CLICKED, game_controller_handle_hex_click);
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

// Step 3: Clean up UI system
try {
    if (instance_exists(obj_UIManager)) {
        ui_cleanup();
        show_debug_message("[INFO] UI cleanup completed safely");
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

// Step 6: Clean up scene state
try {
    scenestate_cleanup();
    logger_write(LogLevel.INFO, "GameController", "Scene state cleaned up", "Cleanup step 6");
} catch (error) {
    show_debug_message("[ERROR] Scene state cleanup failed: " + string(error));
}

// Step 7: Clean up game state (includes observer system)
try {
    gamestate_cleanup();
    logger_write(LogLevel.INFO, "GameController", "Game state cleaned up", "Cleanup step 7");
} catch (error) {
    show_debug_message("[ERROR] GameState cleanup failed: " + string(error));
}

// Note: DevConsole will clean itself up through its own CleanUp event
// We don't need to manually clean it up here

show_debug_message("[INFO] GameController: Game shutdown complete - All systems cleaned up");