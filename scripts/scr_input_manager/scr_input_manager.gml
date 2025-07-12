/// @description Load input mapping configuration from file
/// @return {struct} Input mapping configuration
function input_load_mapping() {
    var mapping_file = "";
    
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        mapping_file = string(global.game_options.assets.data_path) + "input_mapping.ini";
    } else {
        mapping_file = "datafiles/assets/data/input_mapping.ini";
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

/// @description Initializes global.input_state structure
function input_init() {
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
        
        // Gamepad state (for player 0)
        gamepad_buttons_pressed: ds_map_create(),
        gamepad_buttons_held: ds_map_create(),
        gamepad_buttons_released: ds_map_create(),
        gamepad_axes: ds_map_create()
    };	
}

/// @description updates input values to global.input_state and calls input_queue_command(action_command)
function input_step_update() {

	
	    // Update mouse position
    global.input_state.mouse_pos_x = mouse_x;
    global.input_state.mouse_pos_y = mouse_y;
    global.input_state.mouse_gui_pos_x = device_mouse_x_to_gui(0);
    global.input_state.mouse_gui_pos_y = device_mouse_y_to_gui(0);

	    // Action commands
    if (input_check_pressed(global.input_mapping.action_primary)) {
        var action_command = input_create_command(CommandType.ACTION_PRIMARY, {
            x: global.input_state.mouse_pos_x,
            y: global.input_state.mouse_pos_y
        });
        input_queue_command(action_command);
    }	
}