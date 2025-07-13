/// @function input_init()
/// @description Initialize the input management system
/// @description Creates command queue and loads input mappings
function input_init() {
    logger_write(LogLevel.DEBUG, "InputManager", "input_init called", "Input system initialization started");
    
    // Command queue for processing
    global.command_queue = ds_queue_create();
    
    // Frame counter for command timestamps
    global.game_frame = 0;
    
    logger_write(LogLevel.DEBUG, "InputManager", "Command queue created", 
                string("Queue ID: {0}, Frame counter initialized: {1}", global.command_queue, global.game_frame));
    
    // Load input mappings
    logger_write(LogLevel.DEBUG, "InputManager", "Loading input mappings", "Calling input_load_mapping");
    global.input_mapping = input_load_mapping();
    
    logger_write(LogLevel.DEBUG, "InputManager", "Input mapping loaded", 
                string("Type: {0}, Is struct: {1}", typeof(global.input_mapping), is_struct(global.input_mapping)));
    
    // Input state tracking
    global.input_state = {
        // Keyboard state
        keys_pressed: ds_map_create(),
        keys_held: ds_map_create(),
        keys_released: ds_map_create(),
        
        // Mouse state
        mouse_pos_x: 0,
        mouse_pos_y: 0,
        mouse_gui_pos_x: 0,
        mouse_gui_pos_y: 0,
        mouse_buttons_pressed: ds_map_create(),
        mouse_buttons_held: ds_map_create(),
        mouse_buttons_released: ds_map_create(),
        
        // UI blocking flag
        ui_has_focus: false
    };
    
    logger_write(LogLevel.DEBUG, "InputManager", "Input state initialized", 
                string("Key maps created, Mouse position tracking ready, UI focus: {0}", global.input_state.ui_has_focus));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Input system initialized", "System startup");
    }
    
    logger_write(LogLevel.DEBUG, "InputManager", "input_init completed", "Input system ready");
}

/// @function input_cleanup()
/// @description Cleanup input system resources
function input_cleanup() {
    logger_write(LogLevel.DEBUG, "InputManager", "input_cleanup called", "Input system cleanup started");
    
    // Count items before cleanup
    var queue_size = ds_queue_size(global.command_queue);
    logger_write(LogLevel.DEBUG, "InputManager", "Cleanup statistics", 
                string("Command queue size: {0}", queue_size));
    
    ds_queue_destroy(global.command_queue);
    ds_map_destroy(global.input_state.keys_pressed);
    ds_map_destroy(global.input_state.keys_held);
    ds_map_destroy(global.input_state.keys_released);
    ds_map_destroy(global.input_state.mouse_buttons_pressed);
    ds_map_destroy(global.input_state.mouse_buttons_held);
    ds_map_destroy(global.input_state.mouse_buttons_released);
    
    logger_write(LogLevel.DEBUG, "InputManager", "Data structures destroyed", "All input maps and queue cleaned up");
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Input system cleaned up", "System shutdown");
    }
    
    logger_write(LogLevel.DEBUG, "InputManager", "input_cleanup completed", "Input system cleanup finished");
}

/// @function input_save_mapping_data(mapping)
/// @description Save input mapping data to JSON file
/// @param {struct} mapping The mapping data to save
function input_save_mapping_data(mapping) {
    logger_write(LogLevel.DEBUG, "InputManager", "input_save_mapping_data called", 
                string("Mapping type: {0}", typeof(mapping)));
    
    var mapping_file = working_directory + INPUT_MAPPING_FILE;
    
    logger_write(LogLevel.DEBUG, "InputManager", "Saving input mapping", 
                string("File: '{0}'", mapping_file));
    
    try {
        json_save_file(mapping_file, mapping);
        
        logger_write(LogLevel.DEBUG, "InputManager", "Input mapping saved successfully", 
                    string("File: '{0}'", mapping_file));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "InputManager", "Input mapping saved", mapping_file);
        }
    } catch (error) {
        logger_write(LogLevel.ERROR, "InputManager", "Failed to save input mapping", 
                    string("File: '{0}', Error: {1}", mapping_file, error));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "InputManager", "Failed to save input mapping", string(error));
        }
    }
}

/// @function input_save_mapping()
/// @description Save current input mapping to file
function input_save_mapping() {
    logger_write(LogLevel.DEBUG, "InputManager", "input_save_mapping called", "Saving current mapping");
    input_save_mapping_data(global.input_mapping);
}

/// @function input_load_mapping()
/// @description Load input mapping configuration from JSON file
/// @return {struct} Input mapping configuration
function input_load_mapping() {
    logger_write(LogLevel.DEBUG, "InputManager", "input_load_mapping called", "Loading input mapping configuration");
    
    var mapping_file = working_directory + INPUT_MAPPING_FILE;
    
    logger_write(LogLevel.DEBUG, "InputManager", "Input mapping file path", 
                string("Path: '{0}'", mapping_file));
    
    // Default mappings
    var mapping = {
        keyboard: {
            move_up: ord("W"),
            move_down: ord("S"),
            move_left: ord("A"),
            move_right: ord("D"),
            pause: vk_escape,
            quick_save: KEY_QUICK_SAVE,
            quick_load: KEY_QUICK_LOAD,
            toggle_debug: KEY_TOGGLE_DEBUG,
            dev_console: KEY_DEV_CONSOLE
        },
        mouse: {
            action_primary: mb_left,
            action_secondary: mb_right,
            action_middle: mb_middle
        },
        ui: {
            up: vk_up,
            down: vk_down,
            left: vk_left,
            right: vk_right,
            confirm: vk_enter,
            cancel: vk_escape
        }
    };
    
    logger_write(LogLevel.DEBUG, "InputManager", "Default mapping created", 
                string("Keyboard keys: {0}, Mouse buttons: {1}, UI keys: {2}", 
                       array_length(variable_struct_get_names(mapping.keyboard)),
                       array_length(variable_struct_get_names(mapping.mouse)),
                       array_length(variable_struct_get_names(mapping.ui))));
    
    // Ensure config directory exists
    var config_dir = working_directory + CONFIG_PATH;
    
    logger_write(LogLevel.DEBUG, "InputManager", "Checking config directory", 
                string("Path: '{0}', Exists: {1}", config_dir, directory_exists(config_dir)));
    
    if (!directory_exists(config_dir)) {
        try {
            logger_write(LogLevel.DEBUG, "InputManager", "Creating config directory", string("Path: '{0}'", config_dir));
            directory_create(config_dir);
            logger_write(LogLevel.DEBUG, "InputManager", "Config directory created", "Success");
        } catch (error) {
            logger_write(LogLevel.ERROR, "InputManager", "Failed to create config directory", 
                        string("Path: '{0}', Error: {1}", config_dir, error));
            show_debug_message("Failed to create config directory: " + string(error));
        }
    }
    
    // Load from file if exists
    var file_exists_result = file_exists(mapping_file);
    logger_write(LogLevel.DEBUG, "InputManager", "Mapping file existence check", 
                string("File: '{0}', Exists: {1}", mapping_file, file_exists_result));
    
    if (file_exists_result) {
        try {
            logger_write(LogLevel.DEBUG, "InputManager", "Loading mapping from file", 
                        string("File: '{0}'", mapping_file));
            
            var loaded_mapping = json_load_file(mapping_file);
            
            logger_write(LogLevel.DEBUG, "InputManager", "Mapping file loaded", 
                        string("Type: {0}, Is undefined: {1}", typeof(loaded_mapping), is_undefined(loaded_mapping)));
            
            if (!is_undefined(loaded_mapping)) {
                logger_write(LogLevel.DEBUG, "InputManager", "Merging loaded mapping with defaults", "json_merge_structures");
                mapping = json_merge_structures(mapping, loaded_mapping);
                logger_write(LogLevel.DEBUG, "InputManager", "Mapping merge completed", "Using loaded configuration");
            }
        } catch (error) {
            logger_write(LogLevel.ERROR, "InputManager", "Error loading mapping file", 
                        string("File: '{0}', Error: {1}", mapping_file, error));
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "InputManager", "Error loading input mapping", string(error));
            }
        }
    } else {
        logger_write(LogLevel.DEBUG, "InputManager", "Mapping file not found, saving defaults", 
                    string("File: '{0}'", mapping_file));
        // Save default mappings
        input_save_mapping_data(mapping);
    }
    
    logger_write(LogLevel.DEBUG, "InputManager", "input_load_mapping completed", 
                string("Final mapping type: {0}", typeof(mapping)));
    
    return mapping;
}

/// @function input_create_command(type, data, player_id)
/// @description Input command structure for command pattern implementation
/// @param {Constant.CommandType} type Type of command from CommandType enum
/// @param {struct} data Command-specific data payload
/// @param {real} player_id ID of player who issued the command
/// @return {struct} Command structure ready for execution
function input_create_command(type, data, player_id = 0) {
    logger_write(LogLevel.DEBUG, "InputManager", "input_create_command called", 
                string("Type: {0}, Data type: {1}, Player: {2}", type, typeof(data), player_id));
    
    var command = {
        type: type,
        data: data,
        timestamp: current_time,
        frame: global.game_frame,
        player_id: player_id
    };
    
    logger_write(LogLevel.DEBUG, "InputManager", "Command created", 
                string("Type: {0}, Frame: {1}, Timestamp: {2}, Player: {3}", 
                       command.type, command.frame, command.timestamp, command.player_id));
    
    return command;
}

/// @function input_queue_command(command)
/// @description Add a command to the processing queue
/// @param {struct} command Command struct to queue
function input_queue_command(command) {
    logger_write(LogLevel.DEBUG, "InputManager", "input_queue_command called", 
                string("Command type: {0}, Queue size before: {1}", command.type, ds_queue_size(global.command_queue)));
    
    ds_queue_enqueue(global.command_queue, command);
    
    var new_queue_size = ds_queue_size(global.command_queue);
    
    logger_write(LogLevel.DEBUG, "InputManager", "Command queued", 
                string("Type: {0}, Queue size after: {1}", command.type, new_queue_size));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "InputManager", 
                    string("Queued command: {0}", command.type), 
                    string("Frame: {0}", command.frame));
    }
}

/// @function input_dequeue_command()
/// @description Get next command from queue for processing
/// @return {struct|undefined} Next command or undefined if queue empty
function input_dequeue_command() {
    var queue_size = ds_queue_size(global.command_queue);
    
    logger_write(LogLevel.DEBUG, "InputManager", "input_dequeue_command called", 
                string("Queue size: {0}", queue_size));
    
    if (ds_queue_empty(global.command_queue)) {
        logger_write(LogLevel.DEBUG, "InputManager", "Command queue is empty", "Returning undefined");
        return undefined;
    }
    
    var command = ds_queue_dequeue(global.command_queue);
    var new_queue_size = ds_queue_size(global.command_queue);
    
    logger_write(LogLevel.DEBUG, "InputManager", "Command dequeued", 
                string("Type: {0}, Queue size after: {1}", command.type, new_queue_size));
    
    return command;
}

/// @function input_update()
/// @description Update input state and generate commands based on input
/// @description Should be called once per frame by obj_InputManager
function input_update() {
    logger_write(LogLevel.DEBUG, "InputManager", "input_update called", 
                string("Frame: {0}, UI focus: {1}", global.game_frame, global.input_state.ui_has_focus));
    
    // Update frame counter
    global.game_frame++;
    
    // Update mouse position
    var old_mouse_x = global.input_state.mouse_pos_x;
    var old_mouse_y = global.input_state.mouse_pos_y;
    
    global.input_state.mouse_pos_x = mouse_x;
    global.input_state.mouse_pos_y = mouse_y;
    global.input_state.mouse_gui_pos_x = device_mouse_x_to_gui(0);
    global.input_state.mouse_gui_pos_y = device_mouse_y_to_gui(0);
    
    // Debug logging for mouse movement (only if position changed)
    if (old_mouse_x != global.input_state.mouse_pos_x || old_mouse_y != global.input_state.mouse_pos_y) {
        logger_write(LogLevel.DEBUG, "InputManager", "Mouse position updated", 
                    string("World: ({0}, {1}), GUI: ({2}, {3})", 
                           global.input_state.mouse_pos_x, global.input_state.mouse_pos_y,
                           global.input_state.mouse_gui_pos_x, global.input_state.mouse_gui_pos_y));
    }
    
    // Debug logging for mouse movement
    if (global.log_level == LogLevel.DEBUG) {
        static last_mouse_x = 0;
        static last_mouse_y = 0;
        if (mouse_x != last_mouse_x || mouse_y != last_mouse_y) {
            logger_write(LogLevel.DEBUG, "InputManager", 
                        string("Mouse moved to ({0}, {1})", mouse_x, mouse_y), "Input tracking");
            last_mouse_x = mouse_x;
            last_mouse_y = mouse_y;
        }
    }
    
    // Don't process game input if UI has focus
    if (global.input_state.ui_has_focus) {
        logger_write(LogLevel.DEBUG, "InputManager", "UI has focus, skipping game input", "UI blocking active");
        return;
    }
    
    logger_write(LogLevel.DEBUG, "InputManager", "Processing game input", "UI focus: false");
    
    // Check for pause
    if (keyboard_check_pressed(global.input_mapping.keyboard.pause)) {
        logger_write(LogLevel.DEBUG, "InputManager", "Pause key pressed", 
                    string("Key: {0}", global.input_mapping.keyboard.pause));
        
        logger_write(LogLevel.DEBUG, "InputManager", "Creating pause command", "CommandType.PAUSE");
        var pause_command = input_create_command(CommandType.PAUSE, {});
        input_queue_command(pause_command);
        
        logger_write(LogLevel.DEBUG, "InputManager", "Pause command processed", "Command queued");
    }
    
    // Check for primary action (left click)
    if (mouse_check_button_pressed(global.input_mapping.mouse.action_primary)) {
        logger_write(LogLevel.DEBUG, "InputManager", "Primary action detected", 
                    string("Mouse button: {0}, Position: ({1}, {2})", 
                           global.input_mapping.mouse.action_primary,
                           global.input_state.mouse_pos_x, global.input_state.mouse_pos_y));
        
        logger_write(LogLevel.DEBUG, "InputManager", "Primary action at coordinates", 
                    string("World: ({0}, {1}), GUI: ({2}, {3})", 
                           global.input_state.mouse_pos_x, global.input_state.mouse_pos_y,
                           global.input_state.mouse_gui_pos_x, global.input_state.mouse_gui_pos_y));
        
        var action_command = input_create_command(CommandType.ACTION_PRIMARY, {
            x: global.input_state.mouse_pos_x,
            y: global.input_state.mouse_pos_y,
            gui_x: global.input_state.mouse_gui_pos_x,
            gui_y: global.input_state.mouse_gui_pos_y
        });
        
        logger_write(LogLevel.DEBUG, "InputManager", "Creating primary action command", "CommandType.ACTION_PRIMARY");
        input_queue_command(action_command);
        
        logger_write(LogLevel.DEBUG, "InputManager", "Primary action command processed", "Command queued");
    }
    
    // Check for secondary action (right click)
    if (mouse_check_button_pressed(global.input_mapping.mouse.action_secondary)) {
        logger_write(LogLevel.DEBUG, "InputManager", "Secondary action detected", 
                    string("Mouse button: {0}, Position: ({1}, {2})", 
                           global.input_mapping.mouse.action_secondary,
                           global.input_state.mouse_pos_x, global.input_state.mouse_pos_y));
        
        var action_command = input_create_command(CommandType.ACTION_SECONDARY, {
            x: global.input_state.mouse_pos_x,
            y: global.input_state.mouse_pos_y,
            gui_x: global.input_state.mouse_gui_pos_x,
            gui_y: global.input_state.mouse_gui_pos_y
        });
        
        logger_write(LogLevel.DEBUG, "InputManager", "Creating secondary action command", "CommandType.ACTION_SECONDARY");
        input_queue_command(action_command);
        
        logger_write(LogLevel.DEBUG, "InputManager", "Secondary action command processed", "Command queued");
    }
    
    // Debug logging for any key press
    if (global.log_level == LogLevel.DEBUG && keyboard_check_pressed(vk_anykey)) {
        for (var key = 0; key < 255; key++) {
            if (keyboard_check_pressed(key)) {
                logger_write(LogLevel.DEBUG, "InputManager", 
                            string("Key pressed: {0}", key), "Raw input");
            }
        }
    }
    
    logger_write(LogLevel.DEBUG, "InputManager", "input_update completed", 
                string("Frame: {0}, Commands in queue: {1}", global.game_frame, ds_queue_size(global.command_queue)));
}

/// @function input_set_ui_focus(has_focus)
/// @description Set whether UI currently has input focus
/// @param {bool} has_focus True if UI should block game input
function input_set_ui_focus(has_focus) {
    logger_write(LogLevel.DEBUG, "InputManager", "input_set_ui_focus called", 
                string("Previous focus: {0}, New focus: {1}", global.input_state.ui_has_focus, has_focus));
    
    var focus_changed = (global.input_state.ui_has_focus != has_focus);
    global.input_state.ui_has_focus = has_focus;
    
    if (focus_changed) {
        logger_write(LogLevel.DEBUG, "InputManager", "UI focus changed", 
                    string("UI has focus: {0}", has_focus));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "InputManager", 
                        string("UI focus set to: {0}", has_focus), "Input focus change");
        }
    }
}