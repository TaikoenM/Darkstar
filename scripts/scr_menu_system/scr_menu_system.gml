/// @description Create a menu button data structure with all necessary properties
/// @param {Constant.ButtonType} type ButtonType enum value for the button type
/// @param {string} text Display text for the button
/// @param {real} x X position in GUI coordinates
/// @param {real} y Y position in GUI coordinates
/// @param {function} callback Function to call when button is clicked
/// @return {struct} Button data structure with all properties set
function menu_create_button_data(type, text, x, y, callback) {
    var button_width = global.game_options.ui.button_width;
    var button_height = global.game_options.ui.button_height;
    
    return {
        type: type,
        text: text,
        x: x,
        y: y,
        width: button_width,
        height: button_height,
        callback: callback,
        enabled: true,
        visible: true
    };
}

/// @description Factory function to create menu button instances from configuration array
/// @param {Array<Struct>} button_configs Array of button configuration structs
function menu_create_buttons(button_configs) {
    if (is_undefined(button_configs) || !is_array(button_configs)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "MenuSystem", "Invalid button configurations provided", "Not an array or undefined");
        }
        return;
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", 
                    string("Creating {0} menu buttons", array_length(button_configs)), "Menu initialization");
    }
    
    for (var i = 0; i < array_length(button_configs); i++) {
        var config = button_configs[i];
        
        // Validate config structure
        if (is_undefined(config) || !is_struct(config)) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "MenuSystem", 
                            string("Skipping invalid button config at index {0}", i), "Invalid config structure");
            }
            continue;
        }
        
        try {
            var button_instance = instance_create_layer(config.x, config.y, "UI", obj_MenuButton);
            
            // Initialize button properties
            button_instance.button_data = config;
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.DEBUG, "MenuSystem", 
                            string("Created button: {0} at ({1}, {2})", config.text, config.x, config.y), 
                            "Button factory");
            }
        } catch (error) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.ERROR, "MenuSystem", 
                            string("Failed to create button: {0}", error), 
                            string("Button index: {0}", i));
            }
        }
    }
}

/// @description Get configuration array for main menu buttons with proper positioning
/// @return {Array<Struct>} Array of button configuration structs for main menu
function menu_get_main_menu_buttons() {
    var center_x = GAME_WIDTH / 2;
    var center_y = GAME_HEIGHT / 2;
    var start_y = center_y - 240;
    var spacing = 80;
    
    // Use config values if available
    if (variable_global_exists("config") && !is_undefined(global.config)) {
        center_x += global.config.menu_center_x_offset;
        center_y += global.config.menu_center_y_offset;
        start_y = center_y + global.config.menu_start_y_offset;
        spacing = global.config.menu_button_spacing;
    }
    
    var buttons = [
        menu_create_button_data(ButtonType.CONTINUE, "Continue", center_x, start_y, menu_callback_continue),
        menu_create_button_data(ButtonType.START_NEW_GAME, "Start New Game", center_x, start_y + spacing, menu_callback_new_game),
        menu_create_button_data(ButtonType.OPTIONS, "Options", center_x, start_y + spacing * 2, menu_callback_options),
        menu_create_button_data(ButtonType.MAP_EDITOR, "Map Editor", center_x, start_y + spacing * 3, menu_callback_map_editor),
        menu_create_button_data(ButtonType.RUN_TESTS, "Run Tests", center_x, start_y + spacing * 4, menu_callback_run_tests),
        menu_create_button_data(ButtonType.EXIT, "Exit", center_x, start_y + spacing * 5, menu_callback_exit)
    ];
    
    return buttons;
}

// Menu button callback functions

/// @description Handle Continue button press - load saved game
function menu_callback_continue() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Continue button pressed", "Not implemented yet");
    }
    // TODO: Implement continue functionality
}

/// @description Handle New Game button press - start fresh game
function menu_callback_new_game() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "New Game button pressed", "Not implemented yet");
    }
    // TODO: Implement new game functionality
}

/// @description Handle Options button press - open settings menu
function menu_callback_options() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Options button pressed", "Not implemented yet");
    }
    // TODO: Implement options functionality
}

/// @description Handle Map Editor button press - open level editor
function menu_callback_map_editor() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Map Editor button pressed", "Not implemented yet");
    }
    // TODO: Implement map editor functionality
}

/// @description Handle Run Tests button press - start automated testing
function menu_callback_run_tests() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Run Tests button pressed", "Not implemented yet");
    }
    // TODO: Implement test runner functionality
}

/// @description Handle Exit button press - save and quit game
function menu_callback_exit() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Exit button pressed", "Shutting down game");
    }
    
    // Save configuration
    config_save();
    
    // Clean up systems
    input_cleanup();
    assets_cleanup();
    gamestate_cleanup();
    
    game_end();
}