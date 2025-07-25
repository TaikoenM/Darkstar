/// @function input_init()
/// @description Initialize the input management system
/// @description Creates command queue and loads input mappings
function input_init() {
    // Command queue for processing
    global.command_queue = ds_queue_create();
    
    // Frame counter for command timestamps
    global.game_frame = 0;
    
    // Load input mappings
    global.input_mapping = input_load_mapping();
    
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
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Input system initialized", "System startup");
    }
}

/// @function input_cleanup()
/// @description Cleanup input system resources
function input_cleanup() {
    ds_queue_destroy(global.command_queue);
    ds_map_destroy(global.input_state.keys_pressed);
    ds_map_destroy(global.input_state.keys_held);
    ds_map_destroy(global.input_state.keys_released);
    ds_map_destroy(global.input_state.mouse_buttons_pressed);
    ds_map_destroy(global.input_state.mouse_buttons_held);
    ds_map_destroy(global.input_state.mouse_buttons_released);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Input system cleaned up", "System shutdown");
    }
}

/// @function input_save_mapping_data(mapping)
/// @description Save input mapping data to JSON file
/// @param {struct} mapping The mapping data to save
function input_save_mapping_data(mapping) {
    var mapping_file = working_directory + INPUT_MAPPING_FILE;
    
    try {
        json_save_file(mapping_file, mapping);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "InputManager", "Input mapping saved", mapping_file);
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "InputManager", "Failed to save input mapping", string(error));
        }
    }
}

/// @function input_save_mapping()
/// @description Save current input mapping to file
function input_save_mapping() {
    input_save_mapping_data(global.input_mapping);
}

/// @function input_load_mapping()
/// @description Load input mapping configuration from JSON file
/// @return {struct} Input mapping configuration
function input_load_mapping() {
    var mapping_file = working_directory + INPUT_MAPPING_FILE;
    
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
    
    // Ensure config directory exists
    var config_dir = working_directory + CONFIG_PATH;
    
    if (!directory_exists(config_dir)) {
        try {
            directory_create(config_dir);
        } catch (error) {
            show_debug_message("Failed to create config directory: " + string(error));
        }
    }
    
    // Load from file if exists
    if (file_exists(mapping_file)) {
        try {
            var loaded_mapping = json_load_file(mapping_file);
            
            if (!is_undefined(loaded_mapping)) {
                mapping = json_merge_structures(mapping, loaded_mapping);
            }
        } catch (error) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "InputManager", "Error loading input mapping", string(error));
            }
        }
    } else {
        // Save default mappings
        input_save_mapping_data(mapping);
    }
    
    return mapping;
}

/// @function input_create_command(type, data, player_id)
/// @description Input command structure for command pattern implementation
/// @param {Constant.CommandType} type Type of command from CommandType enum
/// @param {struct} data Command-specific data payload
/// @param {real} player_id ID of player who issued the command
/// @return {struct} Command structure ready for execution
function input_create_command(type, data, player_id = 0) {
    var command = {
        type: type,
        data: data,
        timestamp: current_time,
        frame: global.game_frame,
        player_id: player_id
    };
    
    return command;
}

/// @function input_queue_command(command)
/// @description Add a command to the processing queue
/// @param {struct} command Command struct to queue
function input_queue_command(command) {
    ds_queue_enqueue(global.command_queue, command);
    
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
    if (ds_queue_empty(global.command_queue)) {
        return undefined;
    }
    
    var command = ds_queue_dequeue(global.command_queue);
    return command;
}

/// @function input_update()
/// @description Update input state and generate commands based on input
/// @description Should be called once per frame by obj_InputManager
function input_update() {
    // Update frame counter
    global.game_frame++;
    
    // Update mouse position
    global.input_state.mouse_pos_x = mouse_x;
    global.input_state.mouse_pos_y = mouse_y;
    global.input_state.mouse_gui_pos_x = device_mouse_x_to_gui(0);
    global.input_state.mouse_gui_pos_y = device_mouse_y_to_gui(0);
    
    // Don't process game input if UI has focus
    if (global.input_state.ui_has_focus) {
        return;
    }
    
    // Check for pause
    if (keyboard_check_pressed(global.input_mapping.keyboard.pause)) {
        var pause_command = input_create_command(CommandType.PAUSE, {});
        input_queue_command(pause_command);
    }
    
    // Check for primary action (left click)
    if (mouse_check_button_pressed(global.input_mapping.mouse.action_primary)) {
        var action_command = input_create_command(CommandType.ACTION_PRIMARY, {
            x: global.input_state.mouse_pos_x,
            y: global.input_state.mouse_pos_y,
            gui_x: global.input_state.mouse_gui_pos_x,
            gui_y: global.input_state.mouse_gui_pos_y
        });
        
        input_queue_command(action_command);
    }
    
    // Check for secondary action (right click)
    if (mouse_check_button_pressed(global.input_mapping.mouse.action_secondary)) {
        var action_command = input_create_command(CommandType.ACTION_SECONDARY, {
            x: global.input_state.mouse_pos_x,
            y: global.input_state.mouse_pos_y,
            gui_x: global.input_state.mouse_gui_pos_x,
            gui_y: global.input_state.mouse_gui_pos_y
        });
        
        input_queue_command(action_command);
    }
}

/// @function input_set_ui_focus(has_focus)
/// @description Set whether UI currently has input focus
/// @param {bool} has_focus True if UI should block game input
function input_set_ui_focus(has_focus) {
    var focus_changed = (global.input_state.ui_has_focus != has_focus);
    global.input_state.ui_has_focus = has_focus;
    
    if (focus_changed && variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "InputManager", 
                    string("UI focus set to: {0}", has_focus), "Input focus change");
    }
}