/// @description Input command structure for command pattern implementation
/// @param {Constant.CommandType} type Type of command from CommandType enum
/// @param {struct} data Command-specific data payload
/// @param {real} timestamp Frame timestamp when command was created
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

/// @description Initialize the input management system
/// @description Sets up input mapping, command queue, and replay system
function input_init() {
    // Initialize frame counter for deterministic replay
    global.game_frame = 0;
    
    // Command queue for buffering inputs
    global.command_queue = ds_queue_create();
    
    // Input state tracking
    global.input_state = {
        // Keyboard state
        keys_pressed: ds_map_create(),
        keys_held: ds_map_create(),
        keys_released: ds_map_create(),
        
        // Mouse state
        mouse_x: 0,
        mouse_y: 0,
        mouse_gui_x: 0,
        mouse_gui_y: 0,
        mouse_buttons_pressed: ds_map_create(),
        mouse_buttons_held: ds_map_create(),
        mouse_buttons_released: ds_map_create(),
        
        // Gamepad state (for player 0)
        gamepad_buttons_pressed: ds_map_create(),
        gamepad_buttons_held: ds_map_create(),
        gamepad_buttons_released: ds_map_create(),
        gamepad_axes: ds_map_create()
    };
    
    // Input mapping configuration
    global.input_mapping = input_load_mapping();
    
    // Replay system
    global.replay_recording = false;
    global.replay_playing = false;
    global.replay_commands = ds_list_create();
    global.replay_index = 0;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Input manager initialized", "System startup");
    }
}

/// @description Load input mapping configuration from file
/// @return {struct} Input mapping configuration
function input_load_mapping() {
    var mapping_file = "";
    
    if (variable_global_exists("config") && !is_undefined(global.config)) {
        mapping_file = string(global.config.asset_path_data) + "input_mapping.ini";
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

/// @description Update input state and process inputs into commands
/// @description Should be called once per frame before game logic update
function input_update() {
    global.game_frame++;
    
    // Clear previous frame states
    ds_map_clear(global.input_state.keys_pressed);
    ds_map_clear(global.input_state.keys_released);
    ds_map_clear(global.input_state.mouse_buttons_pressed);
    ds_map_clear(global.input_state.mouse_buttons_released);
    
    // Update mouse position
    global.input_state.mouse_x = mouse_x;
    global.input_state.mouse_y = mouse_y;
    global.input_state.mouse_gui_x = device_mouse_x_to_gui(0);
    global.input_state.mouse_gui_y = device_mouse_y_to_gui(0);
    
    // Process keyboard input
    input_process_keyboard();
    
    // Process mouse input
    input_process_mouse();
    
    // Process gamepad input if connected
    if (gamepad_is_connected(0)) {
        input_process_gamepad(0);
    }
    
    // Convert raw inputs to commands based on game state
    input_generate_commands();
    
    // Handle replay recording/playback
    if (global.replay_recording) {
        input_record_frame();
    } else if (global.replay_playing) {
        input_replay_frame();
    }
}

/// @description Process keyboard input and update state maps
function input_process_keyboard() {
    // Check common keys
    var keys_to_check = [
        vk_left, vk_right, vk_up, vk_down,
        vk_space, vk_enter, vk_escape, vk_shift, vk_control, vk_alt,
        vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12
    ];
    
    // Add letter keys
    for (var i = ord("A"); i <= ord("Z"); i++) {
        array_push(keys_to_check, i);
    }
    
    // Add number keys
    for (var i = ord("0"); i <= ord("9"); i++) {
        array_push(keys_to_check, i);
    }
    
    // Check each key
    for (var i = 0; i < array_length(keys_to_check); i++) {
        var key = keys_to_check[i];
        
        if (keyboard_check_pressed(key)) {
            global.input_state.keys_pressed[? key] = true;
            global.input_state.keys_held[? key] = true;
        } else if (keyboard_check_released(key)) {
            global.input_state.keys_released[? key] = true;
            ds_map_delete(global.input_state.keys_held, key);
        } else if (keyboard_check(key)) {
            global.input_state.keys_held[? key] = true;
        }
    }
}

/// @description Process mouse input and update state maps
function input_process_mouse() {
    var mouse_buttons = [mb_left, mb_right, mb_middle];
    
    for (var i = 0; i < array_length(mouse_buttons); i++) {
        var button = mouse_buttons[i];
        
        if (mouse_check_button_pressed(button)) {
            global.input_state.mouse_buttons_pressed[? button] = true;
            global.input_state.mouse_buttons_held[? button] = true;
        } else if (mouse_check_button_released(button)) {
            global.input_state.mouse_buttons_released[? button] = true;
            ds_map_delete(global.input_state.mouse_buttons_held, button);
        } else if (mouse_check_button(button)) {
            global.input_state.mouse_buttons_held[? button] = true;
        }
    }
}

/// @description Process gamepad input for specified player
/// @param {real} gamepad_index Gamepad device index
function input_process_gamepad(gamepad_index) {
    // Check gamepad buttons
    var buttons_to_check = [
        gp_face1, gp_face2, gp_face3, gp_face4,
        gp_shoulderl, gp_shoulderr, gp_shoulderlb, gp_shoulderrb,
        gp_select, gp_start, gp_stickl, gp_stickr,
        gp_padu, gp_padd, gp_padl, gp_padr
    ];
    
    for (var i = 0; i < array_length(buttons_to_check); i++) {
        var button = buttons_to_check[i];
        
        if (gamepad_button_check_pressed(gamepad_index, button)) {
            global.input_state.gamepad_buttons_pressed[? button] = true;
            global.input_state.gamepad_buttons_held[? button] = true;
        } else if (gamepad_button_check_released(gamepad_index, button)) {
            global.input_state.gamepad_buttons_released[? button] = true;
            ds_map_delete(global.input_state.gamepad_buttons_held, button);
        } else if (gamepad_button_check(gamepad_index, button)) {
            global.input_state.gamepad_buttons_held[? button] = true;
        }
    }
    
    // Store analog stick values
    global.input_state.gamepad_axes[? "left_h"] = gamepad_axis_value(gamepad_index, gp_axislh);
    global.input_state.gamepad_axes[? "left_v"] = gamepad_axis_value(gamepad_index, gp_axislv);
    global.input_state.gamepad_axes[? "right_h"] = gamepad_axis_value(gamepad_index, gp_axisrh);
    global.input_state.gamepad_axes[? "right_v"] = gamepad_axis_value(gamepad_index, gp_axisrv);
}

/// @description Generate game commands from current input state
function input_generate_commands() {
    var current_state = gamestate_get();
    
    switch (current_state) {
        case GameState.IN_GAME:
            input_generate_game_commands();
            break;
            
        case GameState.MAIN_MENU:
        case GameState.OPTIONS:
            input_generate_menu_commands();
            break;
            
        case GameState.MAP_EDITOR:
            input_generate_editor_commands();
            break;
    }
}

/// @description Generate commands for gameplay state
function input_generate_game_commands() {
    // Movement commands
    var move_h = 0;
    var move_v = 0;
    
    if (input_check_held(global.input_mapping.move_left)) move_h -= 1;
    if (input_check_held(global.input_mapping.move_right)) move_h += 1;
    if (input_check_held(global.input_mapping.move_up)) move_v -= 1;
    if (input_check_held(global.input_mapping.move_down)) move_v += 1;
    
    // Add gamepad input
    if (gamepad_is_connected(0)) {
        move_h += global.input_state.gamepad_axes[? "left_h"];
        move_v += global.input_state.gamepad_axes[? "left_v"];
    }
    
    if (move_h != 0 || move_v != 0) {
        var move_command = input_create_command(CommandType.MOVE, {
            x: move_h,
            y: move_v
        });
        input_queue_command(move_command);
    }
    
    // Action commands
    if (input_check_pressed(global.input_mapping.action_primary)) {
        var action_command = input_create_command(CommandType.ACTION_PRIMARY, {
            x: global.input_state.mouse_x,
            y: global.input_state.mouse_y
        });
        input_queue_command(action_command);
    }
    
    // Pause command
    if (input_check_pressed(global.input_mapping.pause)) {
        var pause_command = input_create_command(CommandType.PAUSE, {});
        input_queue_command(pause_command);
    }
}

/// @description Generate commands for menu navigation
function input_generate_menu_commands() {
    // UI navigation is handled by menu objects directly for now
    // This would be expanded to support keyboard/gamepad menu navigation
}

/// @description Generate commands for map editor
function input_generate_editor_commands() {
    // TODO: Implement editor-specific commands
}

/// @description Check if a key is pressed this frame
/// @param {real} key Key constant to check
/// @return {bool} True if key was pressed this frame
function input_check_pressed(key) {
    return !is_undefined(global.input_state.keys_pressed[? key]) || 
           !is_undefined(global.input_state.mouse_buttons_pressed[? key]);
}

/// @description Check if a key is held down
/// @param {real} key Key constant to check
/// @return {bool} True if key is currently held
function input_check_held(key) {
    return !is_undefined(global.input_state.keys_held[? key]) || 
           !is_undefined(global.input_state.mouse_buttons_held[? key]);
}

/// @description Check if a key was released this frame
/// @param {real} key Key constant to check
/// @return {bool} True if key was released this frame
function input_check_released(key) {
    return !is_undefined(global.input_state.keys_released[? key]) || 
           !is_undefined(global.input_state.mouse_buttons_released[? key]);
}

/// @description Queue a command for execution
/// @param {struct} command Command structure to queue
function input_queue_command(command) {
    ds_queue_enqueue(global.command_queue, command);
    
    // Record command if recording replay
    if (global.replay_recording) {
        ds_list_add(global.replay_commands, command);
    }
}

/// @description Get next command from queue
/// @return {struct} Next command or undefined if queue is empty
function input_dequeue_command() {
    if (ds_queue_empty(global.command_queue)) {
        return undefined;
    }
    return ds_queue_dequeue(global.command_queue);
}

/// @description Start recording replay
function input_start_replay_recording() {
    global.replay_recording = true;
    global.replay_playing = false;
    ds_list_clear(global.replay_commands);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Started replay recording", "Replay system");
    }
}

/// @description Stop recording replay
function input_stop_replay_recording() {
    global.replay_recording = false;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Stopped replay recording", 
                    "Recorded " + string(ds_list_size(global.replay_commands)) + " commands");
    }
}

/// @description Start playing replay
function input_start_replay_playback() {
    global.replay_playing = true;
    global.replay_recording = false;
    global.replay_index = 0;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Started replay playback", 
                    "Playing " + string(ds_list_size(global.replay_commands)) + " commands");
    }
}

/// @description Stop playing replay
function input_stop_replay_playback() {
    global.replay_playing = false;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Stopped replay playback", "Replay system");
    }
}

/// @description Record current frame for replay
function input_record_frame() {
    // Commands are automatically recorded when queued
    // This function could be expanded to record additional frame data
}

/// @description Replay commands for current frame
function input_replay_frame() {
    // Queue all commands for this frame
    while (global.replay_index < ds_list_size(global.replay_commands)) {
        var command = global.replay_commands[| global.replay_index];
        if (command.frame == global.game_frame) {
            ds_queue_enqueue(global.command_queue, command);
            global.replay_index++;
        } else {
            break;
        }
    }
    
    // Check if replay is complete
    if (global.replay_index >= ds_list_size(global.replay_commands)) {
        input_stop_replay_playback();
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "InputManager", "Replay playback complete", "Replay system");
        }
    }
}

/// @description Cleanup input manager and free resources
function input_cleanup() {
    // Destroy data structures
    ds_queue_destroy(global.command_queue);
    ds_list_destroy(global.replay_commands);
    
    // Clean up input state maps
    ds_map_destroy(global.input_state.keys_pressed);
    ds_map_destroy(global.input_state.keys_held);
    ds_map_destroy(global.input_state.keys_released);
    ds_map_destroy(global.input_state.mouse_buttons_pressed);
    ds_map_destroy(global.input_state.mouse_buttons_held);
    ds_map_destroy(global.input_state.mouse_buttons_released);
    ds_map_destroy(global.input_state.gamepad_buttons_pressed);
    ds_map_destroy(global.input_state.gamepad_buttons_held);
    ds_map_destroy(global.input_state.gamepad_buttons_released);
    ds_map_destroy(global.input_state.gamepad_axes);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "InputManager", "Input manager cleaned up", "System shutdown");
    }
}