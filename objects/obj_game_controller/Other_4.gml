/// @description Handle room transitions

logger_write(LogLevel.INFO, "GameController", "Room Start event triggered", string("Current room: {0}", room_get_name(room)));

// Handle specific room initialization
if (room == room_main_menu) {
    logger_write(LogLevel.INFO, "GameController", "Entered main menu room", "Setting up main menu");
    
    // Ensure we're in the correct game state
    if (gamestate_get() != GameState.MAIN_MENU) {
        gamestate_change(GameState.MAIN_MENU, "Room transition to main menu");
    }
    
    // Ensure required layers exist
    var required_layers = ["Managers", "UI", "Background", "Instances"];
    for (var i = 0; i < array_length(required_layers); i++) {
        var layer_name = required_layers[i];
        if (!layer_exists(layer_name)) {
            logger_write(LogLevel.INFO, "GameController", 
                        string("Creating missing layer: {0}", layer_name), 
                        "Layer setup");
            layer_create(0, layer_name);
        }
    }
    
    // Create main menu manager if it doesn't exist
    if (!instance_exists(obj_MainMenuManager)) {
        logger_write(LogLevel.INFO, "GameController", "Creating MainMenuManager", "Main menu setup");
        var manager = instance_create_layer(0, 0, "Managers", obj_MainMenuManager);
        if (instance_exists(manager)) {
            logger_write(LogLevel.INFO, "GameController", "MainMenuManager created successfully", string("Instance ID: {0}", manager));
        } else {
            logger_write(LogLevel.ERROR, "GameController", "Failed to create MainMenuManager", "Instance creation failed");
        }
    }
}