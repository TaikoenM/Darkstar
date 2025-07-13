/// @description Create a menu button data structure with all necessary properties
/// @param {Constant.ButtonType} type ButtonType enum value for the button type
/// @param {string} text Display text for the button
/// @param {real} x X position in GUI coordinates
/// @param {real} y Y position in GUI coordinates
/// @param {function} callback Function to call when button is clicked
/// @return {struct} Button data structure with all properties set
function menu_create_button_data(type, text, x, y, callback) {
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_create_button_data called", 
                string("Type: {0}, Text: '{1}', Position: ({2}, {3})", type, text, x, y));
    
    var button_width = 300;  // Default value
    var button_height = 60;  // Default value
    
    // Get from config if available
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        logger_write(LogLevel.DEBUG, "MenuSystem", "Checking config for button dimensions", "Config exists");
        
        if (variable_struct_exists(global.game_options, "ui")) {
            if (variable_struct_exists(global.game_options.ui, "button_width")) {
                button_width = global.game_options.ui.button_width;
                logger_write(LogLevel.DEBUG, "MenuSystem", "Using config button width", string("Width: {0}", button_width));
            }
            if (variable_struct_exists(global.game_options.ui, "button_height")) {
                button_height = global.game_options.ui.button_height;
                logger_write(LogLevel.DEBUG, "MenuSystem", "Using config button height", string("Height: {0}", button_height));
            }
        }
    } else {
        logger_write(LogLevel.DEBUG, "MenuSystem", "Using default button dimensions", "No config available");
    }
    
    var button_data = {
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
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Button data created", 
                string("Type: {0}, Text: '{1}', Size: {2}x{3}", type, text, button_width, button_height));
    
    return button_data;
}

/// @description Factory function to create menu button instances from configuration array
/// @param {Array<Struct>} button_configs Array of button configuration structs
function menu_create_buttons(button_configs) {
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_create_buttons called", 
                string("Input type: {0}, Is array: {1}", typeof(button_configs), is_array(button_configs)));
    
    if (is_undefined(button_configs) || !is_array(button_configs)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "MenuSystem", "Invalid button configurations provided", "Not an array or undefined");
        }
        return;
    }
    
    var button_count = array_length(button_configs);
    logger_write(LogLevel.DEBUG, "MenuSystem", "Processing button configurations", string("Count: {0}", button_count));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", 
                    string("Creating {0} menu buttons", button_count), "Menu initialization");
    }
    
    for (var i = 0; i < button_count; i++) {
        var config = button_configs[i];
        
        logger_write(LogLevel.DEBUG, "MenuSystem", "Processing button config", 
                    string("Index: {0}, Type: {1}", i, typeof(config)));
        
        // Validate config structure
        if (is_undefined(config) || !is_struct(config)) {
            logger_write(LogLevel.WARNING, "MenuSystem", "Invalid button config", 
                        string("Index: {0}, Type: {1}", i, typeof(config)));
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "MenuSystem", 
                            string("Skipping invalid button config at index {0}", i), "Invalid config structure");
            }
            continue;
        }
        
        logger_write(LogLevel.DEBUG, "MenuSystem", "Button config validated", 
                    string("Index: {0}, Text: '{1}', Type: {2}", i, config.text, config.type));
        
        try {
            logger_write(LogLevel.DEBUG, "MenuSystem", "Creating button instance", 
                        string("Position: ({0}, {1}), Layer: UI", config.x, config.y));
            
            var button_instance = instance_create_layer(config.x, config.y, "UI", obj_MenuButton);
            
            logger_write(LogLevel.DEBUG, "MenuSystem", "Button instance created", 
                        string("Instance ID: {0}", button_instance));
            
            // Initialize button properties
            with (button_instance) {
                logger_write(LogLevel.DEBUG, "MenuSystem", "Setting button properties", 
                            string("Instance: {0}, Setting ID: {1}", id, config.type));
                
                button_id = config.type;
                text = config.text;
                width = config.width;
                height = config.height;
                enabled = config.enabled;
                visible = config.visible;
                
                logger_write(LogLevel.DEBUG, "MenuSystem", "Button properties set", 
                            string("ID: {0}, Text: '{1}', Size: {2}x{3}", button_id, text, width, height));
            }
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.INFO, "MenuSystem", 
                            string("Created button: '{0}' with ID {1} at ({2}, {3})", config.text, config.type, config.x, config.y), 
                            "Button factory");
            }
        } catch (error) {
            logger_write(LogLevel.ERROR, "MenuSystem", "Button creation failed", 
                        string("Index: {0}, Error: {1}", i, error));
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.ERROR, "MenuSystem", 
                            string("Failed to create button: {0}", error), 
                            string("Button index: {0}", i));
            }
        }
    }
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_create_buttons completed", 
                string("Processed {0} button configurations", button_count));
}

/// @description Get configuration array for main menu buttons with proper positioning
/// @return {Array<Struct>} Array of button configuration structs for main menu
function menu_get_main_menu_buttons() {
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_get_main_menu_buttons called", "Creating button layout");
    
    var center_x = 960;  // Default center
    var center_y = 540;  // Default center
    var start_y = center_y - 240;
    var spacing = 80;
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Default layout values", 
                string("Center: ({0}, {1}), Start Y: {2}, Spacing: {3}", center_x, center_y, start_y, spacing));
    
    // Use display dimensions if available
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        logger_write(LogLevel.DEBUG, "MenuSystem", "Checking game options for layout", "Config available");
        
        if (variable_struct_exists(global.game_options, "display")) {
            logger_write(LogLevel.DEBUG, "MenuSystem", "Display config found", "Using display dimensions");
            
            if (variable_struct_exists(global.game_options.display, "width") && 
                variable_struct_exists(global.game_options.display, "height")) {
                center_x = global.game_options.display.width / 2;
                center_y = global.game_options.display.height / 2;
                start_y = center_y - 240;
                
                logger_write(LogLevel.DEBUG, "MenuSystem", "Display dimensions applied", 
                            string("New center: ({0}, {1}), Start Y: {2}", center_x, center_y, start_y));
            }
        }
        
        // Apply menu offsets if available
        if (variable_struct_exists(global.game_options, "menu")) {
            logger_write(LogLevel.DEBUG, "MenuSystem", "Menu config found", "Applying menu offsets");
            
            if (variable_struct_exists(global.game_options.menu, "center_x_offset")) {
                center_x += global.game_options.menu.center_x_offset;
                logger_write(LogLevel.DEBUG, "MenuSystem", "Applied X offset", 
                            string("Offset: {0}, New X: {1}", global.game_options.menu.center_x_offset, center_x));
            }
            if (variable_struct_exists(global.game_options.menu, "center_y_offset")) {
                center_y += global.game_options.menu.center_y_offset;
                logger_write(LogLevel.DEBUG, "MenuSystem", "Applied Y offset", 
                            string("Offset: {0}, New Y: {1}", global.game_options.menu.center_y_offset, center_y));
            }
            if (variable_struct_exists(global.game_options.menu, "start_y_offset")) {
                start_y = center_y + global.game_options.menu.start_y_offset;
                logger_write(LogLevel.DEBUG, "MenuSystem", "Applied start Y offset", 
                            string("Offset: {0}, New start Y: {1}", global.game_options.menu.start_y_offset, start_y));
            }
        }
        
        // Get button spacing if available
        if (variable_struct_exists(global.game_options, "ui") && 
            variable_struct_exists(global.game_options.ui, "button_spacing")) {
            spacing = global.game_options.ui.button_spacing;
            logger_write(LogLevel.DEBUG, "MenuSystem", "Applied button spacing", 
                        string("New spacing: {0}", spacing));
        }
    } else {
        logger_write(LogLevel.DEBUG, "MenuSystem", "No game options available", "Using defaults");
    }
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Final layout calculated", 
                string("Center: ({0}, {1}), Start Y: {2}, Spacing: {3}", center_x, center_y, start_y, spacing));
    
    var buttons = [
        menu_create_button_data(ButtonID.CONTINUE, "Continue", center_x, start_y, noone),
        menu_create_button_data(ButtonID.NEW_GAME, "Start New Game", center_x, start_y + spacing, noone),
        menu_create_button_data(ButtonID.OPTIONS, "Options", center_x, start_y + spacing * 2, noone),
        menu_create_button_data(ButtonID.MAP_EDITOR, "Map Editor", center_x, start_y + spacing * 3, noone),
        menu_create_button_data(ButtonID.RUN_TESTS, "Run Tests", center_x, start_y + spacing * 4, noone),
        menu_create_button_data(ButtonID.EXIT, "Exit", center_x, start_y + spacing * 5, noone)
    ];
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Button array created", string("Count: {0}", array_length(buttons)));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", 
                    string("Button configuration created - Center: ({0}, {1}), Start Y: {2}, Spacing: {3}", 
                           center_x, center_y, start_y, spacing), "Button layout");
    }
    
    return buttons;
}

/// @description Factory function to create the main menu UI
function menu_factory_create_main_menu() {
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_factory_create_main_menu called", "Main menu factory starting");
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Creating main menu", "Factory function");
    }
    
    // Get button configurations
    logger_write(LogLevel.DEBUG, "MenuSystem", "Getting button configurations", "Calling menu_get_main_menu_buttons");
    var button_configs = menu_get_main_menu_buttons();
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Button configs received", 
                string("Count: {0}, Type: {1}", array_length(button_configs), typeof(button_configs)));
    
    // Create the buttons
    logger_write(LogLevel.DEBUG, "MenuSystem", "Creating buttons", "Calling menu_create_buttons");
    menu_create_buttons(button_configs);
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_factory_create_main_menu completed", "Main menu factory finished");
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Main menu created successfully", "Factory complete");
    }
}

/// @description Factory function to create the main menu background
function menu_factory_create_background() {
    logger_write(LogLevel.DEBUG, "MenuSystem", "menu_factory_create_background called", "Background factory starting");
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "MenuSystem", "Creating main menu background", "Factory function");
    }
    
    // Check if Background layer exists
    if (!layer_exists("Background")) {
        logger_write(LogLevel.WARNING, "MenuSystem", "Background layer does not exist", "Creating layer");
        layer_create(1000, "Background");
    }

}

/// @function main_menu_handle_button_click(event_data)
/// @description Handle button click events from menu
/// @param {struct} event_data Event data containing button_id
function main_menu_handle_button_click(event_data) {
    logger_write(LogLevel.INFO, "MenuSystem", "main_menu_handle_button_click called", 
                string("Event data type: {0}, Is struct: {1}", typeof(event_data), is_struct(event_data)));
    
    if (!is_struct(event_data)) {
        logger_write(LogLevel.ERROR, "MenuSystem", "Invalid event data", "Not a struct");
        return;
    }
    
    if (!variable_struct_exists(event_data, "button_id")) {
        logger_write(LogLevel.ERROR, "MenuSystem", "Missing button_id in event data", "Required field missing");
        return;
    }
    
    var button_id = event_data.button_id;
    var button_text = variable_struct_exists(event_data, "button_text") ? event_data.button_text : "Unknown";
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Button click details", 
                string("Button ID: {0}, Text: '{1}'", button_id, button_text));
    
    logger_write(LogLevel.INFO, "MainMenuManager", 
                string("Button clicked: {0} ('{1}')", button_id, button_text), "User interaction");
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "Processing button action", string("Button ID: {0}", button_id));
    
    switch (button_id) {
        case ButtonID.NEW_GAME:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing NEW_GAME", "Creating start new game command");
            logger_write(LogLevel.INFO, "MainMenuManager", "Starting new game", "Button action");
            // Create command to start new game
            var new_game_cmd = input_create_command(CommandType.START_NEW_GAME, {});
            input_queue_command(new_game_cmd);
            logger_write(LogLevel.DEBUG, "MenuSystem", "NEW_GAME command queued", "Command created and queued");
            break;
            
        case ButtonID.CONTINUE:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing CONTINUE", "Creating load game command");
            logger_write(LogLevel.INFO, "MainMenuManager", "Continue game", "Button action");
            // Create command to load save
            var load_cmd = input_create_command(CommandType.LOAD_GAME, {
                save_slot: "quicksave"
            });
            input_queue_command(load_cmd);
            logger_write(LogLevel.DEBUG, "MenuSystem", "CONTINUE command queued", "Load command created and queued");
            break;
            
        case ButtonID.OPTIONS:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing OPTIONS", "Feature not implemented");
            logger_write(LogLevel.INFO, "MainMenuManager", "Options not implemented", "Feature pending");
            break;
            
        case ButtonID.INPUT_BINDINGS:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing INPUT_BINDINGS", "Feature not implemented");
            logger_write(LogLevel.INFO, "MainMenuManager", "Input bindings not implemented", "Feature pending");
            break;
            
        case ButtonID.MAP_EDITOR:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing MAP_EDITOR", "Changing scene state");
            logger_write(LogLevel.INFO, "MainMenuManager", "Opening map editor", "Button action");
            // Change to map editor state
            scenestate_change(SceneState.MAP_EDITOR, "Opening map editor");
            logger_write(LogLevel.DEBUG, "MenuSystem", "MAP_EDITOR scene change initiated", "Scene state changed");
            break;
            
        case ButtonID.RUN_TESTS:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing RUN_TESTS", "Running test suites");
            logger_write(LogLevel.INFO, "MainMenuManager", "Running tests", "Button action");
            // Run test suites
            test_run_config_tests();
            test_run_logger_tests();
            test_run_asset_tests();
            test_run_input_tests();
            test_run_observer_tests();
            test_run_json_tests();
            test_run_hex_tests();
            logger_write(LogLevel.DEBUG, "MenuSystem", "RUN_TESTS completed", "All test suites executed");
            break;
            
        case ButtonID.EXIT:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Processing EXIT", "Initiating shutdown sequence");
            logger_write(LogLevel.INFO, "MainMenuManager", "Exit requested", "Initiating shutdown");
            
            // Save configuration before exit
            try {
                logger_write(LogLevel.DEBUG, "MenuSystem", "Saving configuration before exit", "Config save attempt");
                config_save();
                logger_write(LogLevel.INFO, "MainMenuManager", "Configuration saved before exit", "Shutdown preparation");
            } catch (error) {
                logger_write(LogLevel.WARNING, "MainMenuManager", "Config save failed during exit", string(error));
            }
            
            logger_write(LogLevel.DEBUG, "MenuSystem", "Calling game_end()", "Final shutdown");
            // Call game_end which will trigger proper cleanup through CleanUp events
            game_end();
            break;
            
        default:
            logger_write(LogLevel.DEBUG, "MenuSystem", "Unknown button ID", string("ID: {0}", button_id));
            logger_write(LogLevel.WARNING, "MainMenuManager", 
                        string("Unknown button ID: {0}", button_id), "Unhandled button");
            break;
    }
    
    logger_write(LogLevel.DEBUG, "MenuSystem", "main_menu_handle_button_click completed", 
                string("Processed button ID: {0}", button_id));
}