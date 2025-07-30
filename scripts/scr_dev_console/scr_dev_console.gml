/// @description Developer console functions and commands
/// @description Provides in-game debugging and testing capabilities

/// @function string_split(str, delimiter)
/// @description Split a string by delimiter (compatibility function)
/// @param {string} str String to split
/// @param {string} delimiter Delimiter to split by
/// @return {Array<string>} Array of split strings
function string_split(str, delimiter) {
    logger_write(LogLevel.DEBUG, "DevConsole", "string_split called", string("str: '{0}', delimiter: '{1}'", str, delimiter));
    
    var result = [];
    var current = "";
    
    for (var i = 1; i <= string_length(str); i++) {
        var char = string_char_at(str, i);
        if (char == delimiter) {
            if (string_length(current) > 0) {
                result[array_length(result)] = current;
                current = "";
            }
        } else {
            current += char;
        }
    }
    
    if (string_length(current) > 0) {
        result[array_length(result)] = current;
    }
    
    logger_write(LogLevel.DEBUG, "DevConsole", "string_split result", string("Parts: {0}", array_length(result)));
    return result;
}

/// @function dev_console_init()
/// @description Initialize the developer console system
function dev_console_init() {
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_init started", "Console initialization");
    
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
    
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_init completed", "Console ready");
}

/// @function dev_console_cleanup()
/// @description Clean up console resources
function dev_console_cleanup() {
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_cleanup started", "Console cleanup");
    
    if (variable_global_exists("dev_console")) {
        ds_list_destroy(global.dev_console.history);
        ds_list_destroy(global.dev_console.command_history);
    }
    
    if (variable_global_exists("dev_commands")) {
        ds_map_destroy(global.dev_commands);
    }
    
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_cleanup completed", "Console cleaned up");
}

/// @function dev_console_toggle()
/// @description Toggle console visibility
function dev_console_toggle() {
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_toggle called", string("Current state: {0}", global.dev_console.enabled));
    
    global.dev_console.enabled = !global.dev_console.enabled;
    
    if (global.dev_console.enabled) {
        logger_write(LogLevel.INFO, "DevConsole", "Console opened", "User action");
        // Pause game input
        input_set_ui_focus(true);
        keyboard_string = "";
        global.dev_console.input_string = "";
    } else {
        logger_write(LogLevel.INFO, "DevConsole", "Console closed", "User action");
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
        return;
    }
    
    if (is_undefined(global.dev_console)) {
        return;
    }
    
    if (!variable_struct_exists(global.dev_console, "history")) {
        return;
    }
    
    if (is_undefined(global.dev_console.history)) {
        return;
    }
    
    if (!ds_exists(global.dev_console.history, ds_type_list)) {
        return;
    }
    
    // Create the log entry
    var entry = {
        text: string(message),
        color: color,
        timestamp: current_time
    };
    
    try {
        ds_list_add(global.dev_console.history, entry);
        
        // Limit history size
        if (variable_struct_exists(global.dev_console, "max_history") && 
            !is_undefined(global.dev_console.max_history)) {
            while (ds_list_size(global.dev_console.history) > global.dev_console.max_history) {
                ds_list_delete(global.dev_console.history, 0);
            }
            
            // Auto-scroll to bottom
            if (variable_struct_exists(global.dev_console, "scroll_offset") && 
                variable_struct_exists(global.dev_console, "visible_lines")) {
                global.dev_console.scroll_offset = max(0, ds_list_size(global.dev_console.history) - global.dev_console.visible_lines);
            }
        }
    } catch (error) {
        show_debug_message("DEV_CONSOLE_ERROR: " + string(error) + " | Original message: " + string(message));
    }
}

/// @function dev_console_execute(command_string)
/// @description Parse and execute a console command
/// @param {string} command_string Raw command input
function dev_console_execute(command_string) {
    logger_write(LogLevel.INFO, "DevConsole", "Console command executed", string("Command: '{0}'", command_string));
    
    // Log the command
    dev_console_log("> " + command_string, global.dev_console.text_color);
    
    // Add to command history
    ds_list_add(global.dev_console.command_history, command_string);
    global.dev_console.history_index = -1;
    
    // Parse command and arguments
    var parts = string_split(command_string, " ");
    if (array_length(parts) == 0) {
        logger_write(LogLevel.WARNING, "DevConsole", "Empty command executed", "No parts found");
        return;
    }
    
    var command = string_lower(parts[0]);
    var args = [];
    
    for (var i = 1; i < array_length(parts); i++) {
        args[array_length(args)] = parts[i];
    }
    
    logger_write(LogLevel.DEBUG, "DevConsole", "Command parsed", string("Command: '{0}', Args: {1}", command, array_length(args)));
    
    // Execute command
    if (ds_map_exists(global.dev_commands, command)) {
        logger_write(LogLevel.INFO, "DevConsole", "Executing registered command", string("Command: '{0}'", command));
        var cmd_func = global.dev_commands[? command];
        cmd_func(args);
    } else {
        logger_write(LogLevel.WARNING, "DevConsole", "Unknown command attempted", string("Command: '{0}'", command));
        dev_console_log("Unknown command: " + command, global.dev_console.error_color);
        dev_console_log("Type 'help' for available commands", global.dev_console.info_color);
    }
}

/// @function dev_console_register_commands()
/// @description Register all available console commands
function dev_console_register_commands() {
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_register_commands started", "Registering commands");
    
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
    ds_map_add(global.dev_commands, "scenestate", dev_cmd_scenestate);
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
    ds_map_add(global.dev_commands, "benchmark", dev_cmd_test_benchmark);
    
    logger_write(LogLevel.DEBUG, "DevConsole", "dev_console_register_commands completed", string("Registered {0} commands", ds_map_size(global.dev_commands)));
}

// ============================================================================
// COMMAND IMPLEMENTATIONS
// ============================================================================

/// @function dev_cmd_help(args)
/// @description Display available commands
function dev_cmd_help(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Help command executed", "User requested help");
    
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
    dev_console_log("  scenestate [state]- Change scene state", c_white);
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
    logger_write(LogLevel.INFO, "DevConsole", "Quit command executed", "User requested game exit");
    dev_console_log("Shutting down...", global.dev_console.info_color);
    game_end();
}

/// @function dev_cmd_clear(args)
/// @description Clear console history
function dev_cmd_clear(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Clear command executed", "User cleared console");
    ds_list_clear(global.dev_console.history);
    dev_console_log("Console cleared", global.dev_console.success_color);
}

/// @function dev_cmd_echo(args)
/// @description Echo text to console
function dev_cmd_echo(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Echo command executed", string("Args count: {0}", array_length(args)));
    
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
    logger_write(LogLevel.INFO, "DevConsole", "Debug level command executed", string("Args: {0}", array_length(args)));
    
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
    logger_write(LogLevel.INFO, "DevConsole", "Log level changed", string("New level: {0}", level_names[level]));
}

/// @function dev_cmd_show_fps(args)
/// @description Toggle FPS display
function dev_cmd_show_fps(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Show FPS command executed", string("Args: {0}", array_length(args)));
    
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
    logger_write(LogLevel.INFO, "DevConsole", "Show debug command executed", string("Args: {0}", array_length(args)));
    
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
    logger_write(LogLevel.INFO, "DevConsole", "Info command executed", "Displaying system info");
    
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
    logger_write(LogLevel.INFO, "DevConsole", "Room info command executed", "Displaying room info");
    
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
    logger_write(LogLevel.INFO, "DevConsole", "Memory command executed", "Displaying memory info");
    
    dev_console_log("=== Memory Usage ===", global.dev_console.info_color);
    
    // Get texture memory info
    var tex_info = texture_get_info();
    for (var i = 0; i < array_length(tex_info); i++) {
        dev_console_log("Texture page " + string(i) + ": " + string(tex_info[i]) + " bytes", c_white);
    }
    
    dev_console_log("Debug mode: " + (debug_mode ? "ON" : "OFF"), c_white);
}

/// @function dev_cmd_scenestate(args)
/// @description Change scene state
function dev_cmd_scenestate(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Scene state command executed", string("Args: {0}", array_length(args)));
    
    if (array_length(args) == 0) {
        dev_console_log("Current state: " + string(scenestate_get()), global.dev_console.info_color);
        dev_console_log("Available states: INITIALIZING, MAIN_MENU, IN_GAME, PAUSED, MAP_EDITOR, OPTIONS, TESTING", c_white);
        return;
    }
    
    var state_name = string_upper(args[0]);
    var new_state = -1;
    
    switch (state_name) {
        case "INITIALIZING": new_state = SceneState.INITIALIZING; break;
        case "MAIN_MENU": new_state = SceneState.MAIN_MENU; break;
        case "IN_GAME": new_state = SceneState.IN_GAME; break;
        case "PAUSED": new_state = SceneState.PAUSED; break;
        case "MAP_EDITOR": new_state = SceneState.MAP_EDITOR; break;
        case "OPTIONS": new_state = SceneState.OPTIONS; break;
        case "TESTING": new_state = SceneState.TESTING; break;
    }
    
    if (new_state != -1) {
        scenestate_change(new_state, "Console command");
        dev_console_log("Scene state changed to: " + state_name, global.dev_console.success_color);
    } else {
        dev_console_log("Invalid state: " + state_name, global.dev_console.error_color);
    }
}

/// @function dev_cmd_room_goto(args)
/// @description Go to specified room
function dev_cmd_room_goto(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Room goto command executed", string("Args: {0}", array_length(args)));
    
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

// Shortcut command implementations for testing
function dev_cmd_test_config(args) { 
    logger_write(LogLevel.INFO, "DevConsole", "Test config command executed", "Running config tests");
    test_run_config_tests(); 
}

function dev_cmd_test_logger(args) { 
    logger_write(LogLevel.INFO, "DevConsole", "Test logger command executed", "Running logger tests");
    test_run_logger_tests(); 
}

function dev_cmd_test_assets(args) { 
    logger_write(LogLevel.INFO, "DevConsole", "Test assets command executed", "Running asset tests");
    test_run_asset_tests(); 
}

function dev_cmd_test_input(args) { 
    logger_write(LogLevel.INFO, "DevConsole", "Test input command executed", "Running input tests");
    test_run_input_tests(); 
}

function dev_cmd_test_observer(args) { 
    logger_write(LogLevel.INFO, "DevConsole", "Test observer command executed", "Running observer tests");
    test_run_observer_tests(); 
}

function dev_cmd_test_json(args) { 
    logger_write(LogLevel.INFO, "DevConsole", "Test JSON command executed", "Running JSON tests");
    test_run_json_tests(); 
}

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


/// @/// @function dev_cmd_test(args)
/// @description Run specific test suite - Updated with new test suites
function dev_cmd_test(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Test command executed", string("Args: {0}", array_length(args)));
    
    if (array_length(args) == 0) {
        dev_console_log("Available test suites:", global.dev_console.info_color);
        dev_console_log("  Core Systems:", c_white);
        dev_console_log("    config    - Configuration management", c_gray);
        dev_console_log("    logger    - Logging system", c_gray);
        dev_console_log("    assets    - Asset loading and caching", c_gray);
        dev_console_log("    input     - Input and command processing", c_gray);
        dev_console_log("    observer  - Observer pattern implementation", c_gray);
        dev_console_log("", c_white);
        dev_console_log("  Data Systems:", c_white);
        dev_console_log("    json      - JSON parsing and serialization", c_gray);
        dev_console_log("    csv       - CSV file handling", c_gray);
        dev_console_log("    save      - Save/Load functionality", c_gray);
        dev_console_log("", c_white);
        dev_console_log("  Game Systems:", c_white);
        dev_console_log("    gamestate - Game state management", c_gray);
        dev_console_log("    command   - Command validation and processing", c_gray);
        dev_console_log("    scene     - Scene state transitions", c_gray);
        dev_console_log("    hex       - Hexagonal grid utilities", c_gray);
        dev_console_log("    combat    - Combat calculations", c_gray);
        dev_console_log("    resource  - Resource management", c_gray);
        dev_console_log("    faction   - Faction relationships", c_gray);
        dev_console_log("    unit      - Unit factory and creation", c_gray);
        dev_console_log("    multi     - Multiplayer determinism", c_gray);
        dev_console_log("", c_white);
        dev_console_log("Usage: test [suite_name] or test all", c_yellow);
        return;
    }
    
    var suite = string_lower(args[0]);
    
    // Handle 'all' command
    if (suite == "all") {
        dev_cmd_test_all(args);
        return;
    }
    
    dev_console_log("Running test suite: " + suite, global.dev_console.info_color);
    
    switch (suite) {
        // Core Systems
        case "config": test_run_config_tests(); break;
        case "logger": test_run_logger_tests(); break;
        case "assets": test_run_asset_tests(); break;
        case "input": test_run_input_tests(); break;
        case "observer": test_run_observer_tests(); break;
        
        // Data Systems
        case "json": test_run_json_tests(); break;
        case "csv": test_run_csv_tests(); break;
        case "save": test_run_save_load_tests(); break;
        
        // Game Systems
        case "gamestate": test_run_gamestate_tests(); break;
        case "command": test_run_command_tests(); break;
        case "scene": test_run_scenestate_tests(); break;
        case "hex": test_run_hex_tests(); break;
        case "combat": test_run_combat_tests(); break;
        case "resource": test_run_resource_tests(); break;
        case "faction": test_run_faction_tests(); break;
        case "unit": test_run_unit_factory_tests(); break;
        case "multi": test_run_multiplayer_tests(); break;
        
        default:
            dev_console_log("Unknown test suite: " + suite, global.dev_console.error_color);
            dev_console_log("Type 'test' to see available suites", c_gray);
    }
}

/// @function dev_cmd_test_all(args)
/// @description Run all test suites with enhanced GUI display
function dev_cmd_test_all(args) {
    logger_write(LogLevel.INFO, "DevConsole", "Test all command executed", "Running all test suites");
    
    dev_console_log("=== Running All Tests ===", global.dev_console.info_color);
    
    // Check if AutoTest object exists
    if (!instance_exists(obj_AutoTest)) {
        // Create AutoTest object if it doesn't exist
        instance_create_layer(0, 0, "Instances", obj_AutoTest);
    }
    
    // Run tests through the AutoTest object for GUI display
    with (obj_AutoTest) {
        test_results = test_run_all_captured();
        display_visible = true;
        display_timer = display_duration;
    }
    
    // Also output summary to console
    var results = obj_AutoTest.test_results;
    
    dev_console_log(string("Completed {0} test suites in {1}ms", 
                          array_length(results.suite_results),
                          string_format(results.execution_time, 1, 2)), 
                   global.dev_console.info_color);
    
    dev_console_log(string("Overall: {0}/{1} tests passed ({2}%)", 
                          results.passed_tests,
                          results.total_tests,
                          string_format((results.passed_tests / max(1, results.total_tests)) * 100, 1, 1)), 
                   results.passed_tests == results.total_tests ? 
                   global.dev_console.success_color : global.dev_console.error_color);
    
    // Show failed tests in console
    if (array_length(results.failed_test_names) > 0) {
        dev_console_log("Failed tests:", global.dev_console.error_color);
        for (var i = 0; i < min(5, array_length(results.failed_test_names)); i++) {
            dev_console_log("  • " + results.failed_test_names[i], c_orange);
        }
        if (array_length(results.failed_test_names) > 5) {
            dev_console_log(string("  ... and {0} more", 
                                 array_length(results.failed_test_names) - 5), c_gray);
        }
    }
}

/// @function dev_cmd_test_benchmark(args)
/// @description Run performance benchmarks for critical systems
function dev_cmd_test_benchmark(args) {
    dev_console_log("=== Running Performance Benchmarks ===", global.dev_console.info_color);
    
    var iterations = 1000;
    if (array_length(args) > 0) {
        iterations = real(args[0]);
    }
    
    // Hex distance calculations
    var start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        hex_distance(0, 0, irandom(20), irandom(20));
    }
    var hex_time = (get_timer() - start_time) / 1000;
    
    // Command creation
    start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        input_create_command(CommandType.PAUSE, {}, 0);
    }
    var cmd_time = (get_timer() - start_time) / 1000;
    
    // Observer notifications
    start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        gamestate_notify_observers("benchmark_event", {test: i});
    }
    var observer_time = (get_timer() - start_time) / 1000;
    
    dev_console_log(string("Benchmark Results ({0} iterations):", iterations), c_white);
    dev_console_log(string("  Hex Distance:      {0}ms ({1}μs/op)", 
                          string_format(hex_time, 1, 2),
                          string_format(hex_time * 1000 / iterations, 1, 2)), c_aqua);
    dev_console_log(string("  Command Creation:  {0}ms ({1}μs/op)", 
                          string_format(cmd_time, 1, 2),
                          string_format(cmd_time * 1000 / iterations, 1, 2)), c_aqua);
    dev_console_log(string("  Observer Notify:   {0}ms ({1}μs/op)", 
                          string_format(observer_time, 1, 2),
                          string_format(observer_time * 1000 / iterations, 1, 2)), c_aqua);
}

/// @function dev_cmd_test_report(args)
/// @description Generate a detailed test report
function dev_cmd_test_report(args) {
    dev_console_log("Generating test report...", global.dev_console.info_color);
    
    // Run all tests silently
    var results = test_run_all_captured();
    
    // Generate report
    var report = "4X GRAND STRATEGY GAME - TEST REPORT\n";
    report += "=====================================\n\n";
    report += "Generated: " + string(date_datetime_string(date_current_datetime())) + "\n";
    report += "Game Version: " + (variable_global_exists("GAME_VERSION") ? GAME_VERSION : "Unknown") + "\n\n";
    
    report += "SUMMARY\n";
    report += "-------\n";
    report += string("Total Tests: {0}\n", results.total_tests);
    report += string("Passed: {0}\n", results.passed_tests);
    report += string("Failed: {0}\n", results.failed_tests);
    report += string("Success Rate: {0}%\n", 
                    string_format((results.passed_tests / max(1, results.total_tests)) * 100, 1, 1));
    report += string("Execution Time: {0}ms\n\n", string_format(results.execution_time, 1, 2));
    
    report += "SUITE BREAKDOWN\n";
    report += "---------------\n";
    for (var i = 0; i < array_length(results.suite_results); i++) {
        var suite = results.suite_results[i];
        report += string("{0}: {1}/{2} passed\n", suite.name, suite.passed, suite.total);
    }
    
    if (array_length(results.failed_test_names) > 0) {
        report += "\nFAILED TESTS\n";
        report += "-------------\n";
        for (var i = 0; i < array_length(results.failed_test_names); i++) {
            report += "- " + results.failed_test_names[i] + "\n";
        }
    }
    
    // Save report
    var filename = "test_report_" + string(current_time) + ".txt";
    var file = file_text_open_write(filename);
    file_text_write_string(file, report);
    file_text_close(file);
    
    dev_console_log("Test report saved to: " + filename, global.dev_console.success_color);
}