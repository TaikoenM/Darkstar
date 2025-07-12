/// @description Developer console functions and commands
/// @description Provides in-game debugging and testing capabilities

/// @function string_split(str, delimiter)
/// @description Split a string by delimiter (compatibility function)
/// @param {string} str String to split
/// @param {string} delimiter Delimiter to split by
/// @return {Array<string>} Array of split strings
function string_split(str, delimiter) {
    var result = [];
    var current = "";
    
    for (var i = 1; i <= string_length(str); i++) {
        var char = string_char_at(str, i);
        if (char == delimiter) {
            if (string_length(current) > 0) {
                array_push(result, current);
                current = "";
            }
        } else {
            current += char;
        }
    }
    
    if (string_length(current) > 0) {
        array_push(result, current);
    }
    
    return result;
}

/// @function dev_console_init()
/// @description Initialize the developer console system
function dev_console_init() {
    global.dev_console = {
        enabled: false,
        history: ds_list_create(),
        command_history: ds_list_create(),
        history_index: -1,
        max_history: 100,
        input_string: "",
        cursor_blink: 0,
        scroll_offset: 0,
        visible_lines: 20,
        
        // Console appearance
        alpha: 0.85,
        bg_color: c_black,
        text_color: c_lime,
        error_color: c_red,
        info_color: c_yellow,
        success_color: c_green
    };
    
    // Register available commands
    global.dev_commands = ds_map_create();
    dev_console_register_commands();
    
    dev_console_log("Developer Console initialized", c_lime);
    dev_console_log("Type 'help' for available commands", c_yellow);
}

/// @function dev_console_cleanup()
/// @description Clean up console resources
function dev_console_cleanup() {
    if (variable_global_exists("dev_console")) {
        ds_list_destroy(global.dev_console.history);
        ds_list_destroy(global.dev_console.command_history);
    }
    
    if (variable_global_exists("dev_commands")) {
        ds_map_destroy(global.dev_commands);
    }
}

/// @function dev_console_toggle()
/// @description Toggle console visibility
function dev_console_toggle() {
    global.dev_console.enabled = !global.dev_console.enabled;
    
    if (global.dev_console.enabled) {
        // Pause game input
        input_set_ui_focus(true);
        keyboard_string = "";
        global.dev_console.input_string = "";
    } else {
        // Resume game input
        input_set_ui_focus(false);
    }
}

/// @function dev_console_log(message, color)
/// @description Add a message to the console history
/// @param {string} message Message to log
/// @param {Constant.Color} color Text color
function dev_console_log(message, color = c_white) {
    // Safety checks before attempting to add to console
    if (!variable_global_exists("dev_console")) {
        return; // Console system not initialized
    }
    
    if (is_undefined(global.dev_console)) {
        return; // Console data is undefined
    }
    
    if (!variable_struct_exists(global.dev_console, "history")) {
        return; // History structure doesn't exist
    }
    
    if (is_undefined(global.dev_console.history)) {
        return; // History is undefined
    }
    
    if (!ds_exists(global.dev_console.history, ds_type_list)) {
        return; // History data structure has been destroyed
    }
    
    // Create the log entry
    var entry = {
        text: string(message), // Ensure message is a string
        color: color,
        timestamp: current_time
    };
    
    try {
        ds_list_add(global.dev_console.history, entry);
        
        // Limit history size - but only if we can safely check the size
        if (variable_struct_exists(global.dev_console, "max_history") && 
            !is_undefined(global.dev_console.max_history)) {
            while (ds_list_size(global.dev_console.history) > global.dev_console.max_history) {
                ds_list_delete(global.dev_console.history, 0);
            }
            
            // Auto-scroll to bottom - but only if scroll_offset exists
            if (variable_struct_exists(global.dev_console, "scroll_offset") && 
                variable_struct_exists(global.dev_console, "visible_lines")) {
                global.dev_console.scroll_offset = max(0, ds_list_size(global.dev_console.history) - global.dev_console.visible_lines);
            }
        }
    } catch (error) {
        // If dev console logging fails, at least try to output to debug console
        show_debug_message("DEV_CONSOLE_ERROR: " + string(error) + " | Original message: " + string(message));
    }
}

/// @function dev_console_execute(command_string)
/// @description Parse and execute a console command
/// @param {string} command_string Raw command input
function dev_console_execute(command_string) {
    // Log the command
    dev_console_log("> " + command_string, global.dev_console.text_color);
    
    // Add to command history
    ds_list_add(global.dev_console.command_history, command_string);
    global.dev_console.history_index = -1;
    
    // Parse command and arguments
    var parts = string_split(command_string, " ");
    if (array_length(parts) == 0) return;
    
    var command = string_lower(parts[0]);
    var args = [];
    
    for (var i = 1; i < array_length(parts); i++) {
        array_push(args, parts[i]);
    }
    
    // Execute command
    if (ds_map_exists(global.dev_commands, command)) {
        var cmd_func = global.dev_commands[? command];
        cmd_func(args);
    } else {
        dev_console_log("Unknown command: " + command, global.dev_console.error_color);
        dev_console_log("Type 'help' for available commands", global.dev_console.info_color);
    }
}

/// @function dev_console_register_commands()
/// @description Register all available console commands
function dev_console_register_commands() {
    // Core commands
    ds_map_add(global.dev_commands, "help", dev_cmd_help);
    ds_map_add(global.dev_commands, "quit", dev_cmd_quit);
    ds_map_add(global.dev_commands, "clear", dev_cmd_clear);
    ds_map_add(global.dev_commands, "echo", dev_cmd_echo);
    
    // Debug commands
    ds_map_add(global.dev_commands, "debug_level", dev_cmd_debug_level);
    ds_map_add(global.dev_commands, "show_fps", dev_cmd_show_fps);
    ds_map_add(global.dev_commands, "show_debug", dev_cmd_show_debug);
    
    // System info commands
    ds_map_add(global.dev_commands, "info", dev_cmd_info);
    ds_map_add(global.dev_commands, "room_info", dev_cmd_room_info);
    ds_map_add(global.dev_commands, "memory", dev_cmd_memory);
    
    // Game state commands
    ds_map_add(global.dev_commands, "gamestate", dev_cmd_gamestate);
    ds_map_add(global.dev_commands, "room_goto", dev_cmd_room_goto);
    
    // Testing commands
    ds_map_add(global.dev_commands, "test", dev_cmd_test);
    ds_map_add(global.dev_commands, "test_all", dev_cmd_test_all);
    ds_map_add(global.dev_commands, "test_config", dev_cmd_test_config);
    ds_map_add(global.dev_commands, "test_logger", dev_cmd_test_logger);
    ds_map_add(global.dev_commands, "test_assets", dev_cmd_test_assets);
    ds_map_add(global.dev_commands, "test_input", dev_cmd_test_input);
    ds_map_add(global.dev_commands, "test_observer", dev_cmd_test_observer);
    ds_map_add(global.dev_commands, "test_json", dev_cmd_test_json);
    ds_map_add(global.dev_commands, "benchmark", dev_cmd_benchmark);
}

// ============================================================================
// COMMAND IMPLEMENTATIONS
// ============================================================================

/// @function dev_cmd_help(args)
/// @description Display available commands
function dev_cmd_help(args) {
    dev_console_log("Available commands:", global.dev_console.info_color);
    dev_console_log("  help              - Show this help message", c_white);
    dev_console_log("  quit              - Exit the game", c_white);
    dev_console_log("  clear             - Clear console history", c_white);
    dev_console_log("  echo [text]       - Echo text to console", c_white);
    dev_console_log("", c_white);
    dev_console_log("Debug commands:", global.dev_console.info_color);
    dev_console_log("  debug_level [0-4] - Set logging level (0=DEBUG, 4=CRITICAL)", c_white);
    dev_console_log("  show_fps [0/1]    - Toggle FPS display", c_white);
    dev_console_log("  show_debug [0/1]  - Toggle debug info overlay", c_white);
    dev_console_log("", c_white);
    dev_console_log("System commands:", global.dev_console.info_color);
    dev_console_log("  info              - Show system information", c_white);
    dev_console_log("  room_info         - Show current room information", c_white);
    dev_console_log("  memory            - Show memory usage", c_white);
    dev_console_log("  gamestate [state] - Change game state", c_white);
    dev_console_log("  room_goto [name]  - Go to specified room", c_white);
    dev_console_log("", c_white);
    dev_console_log("Testing commands:", global.dev_console.info_color);
    dev_console_log("  test [suite]      - Run specific test suite", c_white);
    dev_console_log("  test_all          - Run all test suites", c_white);
    dev_console_log("  benchmark         - Run performance benchmarks", c_white);
}

/// @function dev_cmd_quit(args)
/// @description Exit the game
function dev_cmd_quit(args) {
    dev_console_log("Shutting down...", global.dev_console.info_color);
    game_end();
}

/// @function dev_cmd_clear(args)
/// @description Clear console history
function dev_cmd_clear(args) {
    ds_list_clear(global.dev_console.history);
    dev_console_log("Console cleared", global.dev_console.success_color);
}

/// @function dev_cmd_echo(args)
/// @description Echo text to console
function dev_cmd_echo(args) {
    var message = "";
    for (var i = 0; i < array_length(args); i++) {
        if (i > 0) message += " ";
        message += args[i];
    }
    dev_console_log(message, c_white);
}

/// @function dev_cmd_debug_level(args)
/// @description Set debug logging level
function dev_cmd_debug_level(args) {
    if (array_length(args) == 0) {
        dev_console_log("Current debug level: " + string(global.log_level), global.dev_console.info_color);
        dev_console_log("Usage: debug_level [0-4]", c_white);
        return;
    }
    
    var level = real(args[0]);
    if (level < 0 || level > 4) {
        dev_console_log("Invalid level. Must be 0-4", global.dev_console.error_color);
        return;
    }
    
    global.log_level = level;
    var level_names = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"];
    dev_console_log("Debug level set to: " + level_names[level], global.dev_console.success_color);
}

/// @function dev_cmd_show_fps(args)
/// @description Toggle FPS display
function dev_cmd_show_fps(args) {
    if (array_length(args) == 0) {
        show_debug_overlay(!show_debug_overlay());
    } else {
        show_debug_overlay(real(args[0]) > 0);
    }
    dev_console_log("FPS display: " + (show_debug_overlay() ? "ON" : "OFF"), global.dev_console.success_color);
}

/// @function dev_cmd_show_debug(args)
/// @description Toggle debug info overlay
function dev_cmd_show_debug(args) {
    if (!variable_global_exists("debug_show_info")) {
        global.debug_show_info = false;
    }
    
    if (array_length(args) == 0) {
        global.debug_show_info = !global.debug_show_info;
    } else {
        global.debug_show_info = real(args[0]) > 0;
    }
    
    dev_console_log("Debug overlay: " + (global.debug_show_info ? "ON" : "OFF"), global.dev_console.success_color);
}

/// @function dev_cmd_info(args)
/// @description Show system information
function dev_cmd_info(args) {
    dev_console_log("=== System Information ===", global.dev_console.info_color);
    dev_console_log("Game: " + game_display_name, c_white);
    dev_console_log("Version: " + GM_version, c_white);
    dev_console_log("Runtime: " + GM_runtime_version, c_white);
    dev_console_log("OS: " + os_type_string(), c_white);
    dev_console_log("Display: " + string(display_get_width()) + "x" + string(display_get_height()), c_white);
    dev_console_log("Window: " + string(window_get_width()) + "x" + string(window_get_height()), c_white);
}

/// @function dev_cmd_room_info(args)
/// @description Show current room information
function dev_cmd_room_info(args) {
    dev_console_log("=== Room Information ===", global.dev_console.info_color);
    dev_console_log("Current room: " + room_get_name(room), c_white);
    dev_console_log("Room size: " + string(room_width) + "x" + string(room_height), c_white);
    dev_console_log("Instance count: " + string(instance_count), c_white);
    
    // Count instances by object type
    var obj_counts = ds_map_create();
    with (all) {
        var obj_name = object_get_name(object_index);
        if (ds_map_exists(obj_counts, obj_name)) {
            obj_counts[? obj_name]++;
        } else {
            obj_counts[? obj_name] = 1;
        }
    }
    
    // Display counts
    dev_console_log("Objects in room:", c_white);
    var key = ds_map_find_first(obj_counts);
    while (!is_undefined(key)) {
        dev_console_log("  " + key + ": " + string(obj_counts[? key]), c_white);
        key = ds_map_find_next(obj_counts, key);
    }
    
    ds_map_destroy(obj_counts);
}

/// @function dev_cmd_memory(args)
/// @description Show memory usage
function dev_cmd_memory(args) {
    dev_console_log("=== Memory Usage ===", global.dev_console.info_color);
    
    // Get texture memory info
    var tex_info = texture_get_info();
    for (var i = 0; i < array_length(tex_info); i++) {
        dev_console_log("Texture page " + string(i) + ": " + string(tex_info[i]) + " bytes", c_white);
    }
    
    dev_console_log("Debug mode: " + (debug_mode ? "ON" : "OFF"), c_white);
}

/// @function dev_cmd_gamestate(args)
/// @description Change game state
function dev_cmd_gamestate(args) {
    if (array_length(args) == 0) {
        dev_console_log("Current state: " + string(gamestate_get()), global.dev_console.info_color);
        dev_console_log("Available states: INITIALIZING, MAIN_MENU, IN_GAME, PAUSED, MAP_EDITOR, OPTIONS, TESTING", c_white);
        return;
    }
    
    var state_name = string_upper(args[0]);
    var new_state = -1;
    
    switch (state_name) {
        case "INITIALIZING": new_state = GameState.INITIALIZING; break;
        case "MAIN_MENU": new_state = GameState.MAIN_MENU; break;
        case "IN_GAME": new_state = GameState.IN_GAME; break;
        case "PAUSED": new_state = GameState.PAUSED; break;
        case "MAP_EDITOR": new_state = GameState.MAP_EDITOR; break;
        case "OPTIONS": new_state = GameState.OPTIONS; break;
        case "TESTING": new_state = GameState.TESTING; break;
    }
    
    if (new_state != -1) {
        gamestate_change(new_state, "Console command");
        dev_console_log("Game state changed to: " + state_name, global.dev_console.success_color);
    } else {
        dev_console_log("Invalid state: " + state_name, global.dev_console.error_color);
    }
}

/// @function dev_cmd_room_goto(args)
/// @description Go to specified room
function dev_cmd_room_goto(args) {
    if (array_length(args) == 0) {
        dev_console_log("Usage: room_goto [room_name]", global.dev_console.info_color);
        dev_console_log("Available rooms: room_game_init, room_main_menu", c_white);
        return;
    }
    
    var room_name = args[0];
    var target_room = asset_get_index(room_name);
    
    if (target_room != -1 && asset_get_type(room_name) == asset_room) {
        room_goto(target_room);
        dev_console_log("Going to room: " + room_name, global.dev_console.success_color);
    } else {
        dev_console_log("Invalid room: " + room_name, global.dev_console.error_color);
    }
}

/// @function dev_cmd_test(args)
/// @description Run specific test suite
function dev_cmd_test(args) {
    if (array_length(args) == 0) {
        dev_console_log("Available test suites:", global.dev_console.info_color);
        dev_console_log("  config, logger, assets, input, observer, json, hex", c_white);
        dev_console_log("Usage: test [suite_name]", c_white);
        return;
    }
    
    var suite = string_lower(args[0]);
    dev_console_log("Running test suite: " + suite, global.dev_console.info_color);
    
    switch (suite) {
        case "config": test_run_config_tests(); break;
        case "logger": test_run_logger_tests(); break;
        case "assets": test_run_asset_tests(); break;
        case "input": test_run_input_tests(); break;
        case "observer": test_run_observer_tests(); break;
        case "json": test_run_json_tests(); break;
        case "hex": test_run_hex_tests(); break;
        default:
            dev_console_log("Unknown test suite: " + suite, global.dev_console.error_color);
    }
}

/// @function dev_cmd_test_all(args)
/// @description Run all test suites
function dev_cmd_test_all(args) {
    dev_console_log("=== Running All Tests ===", global.dev_console.info_color);
    
    var start_time = get_timer();
    
    test_run_config_tests();
    test_run_logger_tests();
    test_run_asset_tests();
    test_run_input_tests();
    test_run_observer_tests();
    test_run_json_tests();
    test_run_hex_tests();
    
    var elapsed = (get_timer() - start_time) / 1000;
    dev_console_log("All tests completed in " + string_format(elapsed, 1, 2) + "ms", global.dev_console.success_color);
}

/// @function dev_cmd_benchmark(args)
/// @description Run performance benchmarks
function dev_cmd_benchmark(args) {
    dev_console_log("=== Running Benchmarks ===", global.dev_console.info_color);
    test_run_benchmarks();
}

// Shortcut command implementations for testing
function dev_cmd_test_config(args) { test_run_config_tests(); }
function dev_cmd_test_logger(args) { test_run_logger_tests(); }
function dev_cmd_test_assets(args) { test_run_asset_tests(); }
function dev_cmd_test_input(args) { test_run_input_tests(); }
function dev_cmd_test_observer(args) { test_run_observer_tests(); }
function dev_cmd_test_json(args) { test_run_json_tests(); }

/// @function os_type_string()
/// @description Get OS type as string
function os_type_string() {
    switch (os_type) {
        case os_windows: return "Windows";
        case os_macosx: return "macOS";
        case os_linux: return "Linux";
        case os_android: return "Android";
        case os_ios: return "iOS";
        default: return "Unknown";
    }
}