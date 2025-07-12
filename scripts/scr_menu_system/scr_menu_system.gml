/// @description Create a menu button data structure with all necessary properties
/// @param {Constant.ButtonType} type ButtonType enum value for the button type
/// @param {string} text Display text for the button
/// @param {real} x X position in GUI coordinates
/// @param {real} y Y position in GUI coordinates
/// @param {function} callback Function to call when button is clicked
/// @return {struct} Button data structure with all properties set
function menu_create_button_data(type, text, x, y, callback) {
    var button_width = 300;  // Default value
    var button_height = 60;  // Default value
    
    // Get from config if available
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "ui")) {
            if (variable_struct_exists(global.game_options.ui, "button_width")) {
                button_width = global.game_options.ui.button_width;
            }
            if (variable_struct_exists(global.game_options.ui, "button_height")) {
                button_height = global.game_options.ui.button_height;
            }
        }
    }
    
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
    var center_x = 960;  // Default center
    var center_y = 540;  // Default center
    var start_y = center_y - 240;
    var spacing = 80;
    
    // Use display dimensions if available
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "display")) {
            if (variable_struct_exists(global.game_options.display, "width") && 
                variable_struct_exists(global.game_options.display, "height")) {
                center_x = global.game_options.display.width / 2;
                center_y = global.game_options.display.height / 2;
                start_y = center_y - 240;
            }
        }
        
        // Apply menu offsets if available
        if (variable_struct_exists(global.game_options, "menu")) {
            if (variable_struct_exists(global.game_options.menu, "center_x_offset")) {
                center_x += global.game_options.menu.center_x_offset;
            }
            if (variable_struct_exists(global.game_options.menu, "center_y_offset")) {
                center_y += global.game_options.menu.center_y_offset;
            }
            if (variable_struct_exists(global.game_options.menu, "start_y_offset")) {
                start_y = center_y + global.game_options.menu.start_y_offset;
            }
        }
        
        // Get button spacing if available
        if (variable_struct_exists(global.game_options, "ui") && 
            variable_struct_exists(global.game_options.ui, "button_spacing")) {
            spacing = global.game_options.ui.button_spacing;
        }
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


/// @function main_menu_handle_button_click(event_data)
/// @description Handle button click events from menu
/// @param {struct} event_data Event data containing button_id
function main_menu_handle_button_click(event_data) {
    var button_id = event_data.button_id;
    
    logger_write(LogLevel.INFO, "MainMenuManager", 
                string("Button clicked: {0}", button_id), "User interaction");
    
    switch (button_id) {
        case ButtonID.NEW_GAME:
            // Create command to start new game
            var new_game_cmd = input_create_command(CommandType.START_NEW_GAME, {});
            input_queue_command(new_game_cmd);
            break;
            
        case ButtonID.CONTINUE:
            // Create command to load save
            var load_cmd = input_create_command(CommandType.LOAD_GAME, {
                save_slot: "quicksave"
            });
            input_queue_command(load_cmd);
            break;
            
        case ButtonID.OPTIONS:
            // Open options panel
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.INFO, "MainMenuManager", "Options not implemented", "Feature pending");
            }
            break;
            
        case ButtonID.INPUT_BINDINGS:
            // Open input bindings panel
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.INFO, "MainMenuManager", "Input bindings not implemented", "Feature pending");
            }
            break;
            
        case ButtonID.MAP_EDITOR:
            // Change to map editor state
            scenestate_change(SceneState.MAP_EDITOR, "Opening map editor");
            break;
            
        case ButtonID.EXIT:
            // Enhanced exit handling
            logger_write(LogLevel.INFO, "MainMenuManager", "Exit requested", "Initiating shutdown");
            
            // Save configuration before exit
            try {
                config_save();
                logger_write(LogLevel.INFO, "MainMenuManager", "Configuration saved before exit", "Shutdown preparation");
            } catch (error) {
                logger_write(LogLevel.WARNING, "MainMenuManager", "Config save failed during exit", string(error));
            }
            
            // Call game_end which will trigger proper cleanup through CleanUp events
            game_end();
            break;
            
        default:
            logger_write(LogLevel.WARNING, "MainMenuManager", 
                        string("Unknown button ID: {0}", button_id), "Unhandled button");
            break;
    }
}