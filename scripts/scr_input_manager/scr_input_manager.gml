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

/// @function input_load_mapping()
/// @description Load input mapping configuration from file
/// @return {struct} Input mapping configuration
function input_load_mapping() {
    var mapping_file = "";
    
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        mapping_file = working_directory + global.game_options.assets.data_path + "input_mapping.ini";
    } else {
        mapping_file = working_directory + "datafiles/assets/data/input_mapping.ini";
    }
    
    var mapping = {
        // Default keyboard mappings
        move_up: ord("W"),
        move_down: ord("S"),
        move_left: ord("A"),
        move_right: ord("D"),
        action_primary: mb_left,
        action_secondary: mb_right,
        pause: vk_escape,
        
        // UI navigation
        ui_up: vk_up,
        ui_down: vk_down,
        ui_left: vk_left,
        ui_right: vk_right,
        ui_confirm: vk_enter,
        ui_cancel: vk_escape
    };
    
    // Load from file if exists
    if (file_exists(mapping_file)) {
        try {
            ini_open(mapping_file);
            
            // Load keyboard mappings
            mapping.move_up = ini_read_real("Keyboard", "move_up", mapping.move_up);
            mapping.move_down = ini_read_real("Keyboard", "move_down", mapping.move_down);
            mapping.move_left = ini_read_real("Keyboard", "move_left", mapping.move_left);
            mapping.move_right = ini_read_real("Keyboard", "move_right", mapping.move_right);
            mapping.pause = ini_read_real("Keyboard", "pause", mapping.pause);
            
            // Load UI mappings
            mapping.ui_up = ini_read_real("UI", "up", mapping.ui_up);
            mapping.ui_down = ini_read_real("UI", "down", mapping.ui_down);
            mapping.ui_left = ini_read_real("UI", "left", mapping.ui_left);
            mapping.ui_right = ini_read_real("UI", "right", mapping.ui_right);
            mapping.ui_confirm = ini_read_real("UI", "confirm", mapping.ui_confirm);
            mapping.ui_cancel = ini_read_real("UI", "cancel", mapping.ui_cancel);
            
            ini_close();
        } catch (error) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "InputManager", "Error loading input mapping", string(error));
            }
        }
    }
    
    return mapping;
}

/// @function input_save_mapping()
/// @description Save current input mapping to file
function input_save_mapping() {
    var mapping_file = "";
    
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        mapping_file = working_directory + global.game_options.assets.data_path + "input_mapping.ini";
    } else {
        mapping_file = working_directory + "datafiles/assets/data/input_mapping.ini";
    }
    
    try {
        ini_open(mapping_file);
        
        // Save keyboard mappings
        ini_write_real("Keyboard", "move_up", global.input_mapping.move_up);
        ini_write_real("Keyboard", "move_down", global.input_mapping.move_down);
        ini_write_real("Keyboard", "move_left", global.input_mapping.move_left);
        ini_write_real("Keyboard", "move_right", global.input_mapping.move_right);
        ini_write_real("Keyboard", "pause", global.input_mapping.pause);
        
        // Save UI mappings
        ini_write_real("UI", "up", global.input_mapping.ui_up);
        ini_write_real("UI", "down", global.input_mapping.ui_down);
        ini_write_real("UI", "left", global.input_mapping.ui_left);
        ini_write_real("UI", "right", global.input_mapping.ui_right);
        ini_write_real("UI", "confirm", global.input_mapping.ui_confirm);
        ini_write_real("UI", "cancel", global.input_mapping.ui_cancel);
        
        ini_close();
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "InputManager", "Input mapping saved", mapping_file);
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "InputManager", "Failed to save input mapping", string(error));
        }
    }
}

/// @function input_create_command(type, data, player_id)
/// @description Input command structure for command pattern implementation
/// @param {Constant.CommandType} type Type of command from CommandType enum
/// @param {struct} data Command-specific data payload
/// @param {real} player_id ID of player who issued the command
/// @return {struct} Command structure ready for execution
function input_create_command(type, data, player_id = 0) {
    return {
        type: type,
        data: data,
        timestamp: current_time,
        frame: global.game_frame,
        player_id: player_id
    };
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
    return ds_queue_dequeue(global.command_queue);
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
    if (keyboard_check_pressed(global.input_mapping.pause)) {
        var pause_command = input_create_command(CommandType.PAUSE, {});
        input_queue_command(pause_command);
    }
    
    // Check for primary action (left click)
    if (mouse_check_button_pressed(global.input_mapping.action_primary)) {
        var action_command = input_create_command(CommandType.ACTION_PRIMARY, {
            x: global.input_state.mouse_pos_x,
            y: global.input_state.mouse_pos_y,
            gui_x: global.input_state.mouse_gui_pos_x,
            gui_y: global.input_state.mouse_gui_pos_y
        });
        input_queue_command(action_command);
    }
    
    // Check for secondary action (right click)
    if (mouse_check_button_pressed(global.input_mapping.action_secondary)) {
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
    global.input_state.ui_has_focus = has_focus;
}