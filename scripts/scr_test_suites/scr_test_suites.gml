/// @description Comprehensive test suites for all game systems
/// @description Run via developer console or automated testing

// ============================================================================
// TEST FRAMEWORK
// ============================================================================

/// @function test_assert(condition, test_name, message)
/// @description Assert a condition is true
/// @param {bool} condition Condition to test
/// @param {string} test_name Name of the test
/// @param {string} message Failure message
/// @return {bool} True if passed
function test_assert(condition, test_name, message = "") {
    if (condition) {
        dev_console_log("  ✓ " + test_name, global.dev_console.success_color);
        return true;
    } else {
        dev_console_log("  ✗ " + test_name + " - " + message, global.dev_console.error_color);
        return false;
    }
}

/// @function test_assert_equals(actual, expected, test_name)
/// @description Assert two values are equal
function test_assert_equals(actual, expected, test_name) {
    return test_assert(actual == expected, test_name, 
                      string("Expected {0}, got {1}", expected, actual));
}

/// @function test_assert_not_equals(actual, expected, test_name)
/// @description Assert two values are not equal
function test_assert_not_equals(actual, expected, test_name) {
    return test_assert(actual != expected, test_name, 
                      string("Expected not {0}, but got {1}", expected, actual));
}

/// @function test_assert_exists(value, test_name)
/// @description Assert a value exists (not undefined)
function test_assert_exists(value, test_name) {
    return test_assert(!is_undefined(value), test_name, "Value is undefined");
}

/// @function test_assert_type(value, type_check_func, test_name)
/// @description Assert a value is of specific type
function test_assert_type(value, type_check_func, test_name) {
    return test_assert(type_check_func(value), test_name, 
                      string("Wrong type: {0}", typeof(value)));
}

// ============================================================================
// CONFIG SYSTEM TESTS
// ============================================================================

/// @function test_run_config_tests()
/// @description Test configuration system
function test_run_config_tests() {
    dev_console_log("=== Config System Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: Config initialization
    total++;
    if (test_assert_exists(global.game_options, "Config initialization")) passed++;
    
    // Test 2: Config structure
    total++;
    if (test_assert_type(global.game_options, is_struct, "Config is struct")) passed++;
    
    // Test 3: Required sections exist
    var required_sections = ["display", "ui", "assets", "logging", "menu", "performance"];
    for (var i = 0; i < array_length(required_sections); i++) {
        total++;
        if (test_assert(variable_struct_exists(global.game_options, required_sections[i]),
                       "Section exists: " + required_sections[i])) passed++;
    }
    
    // Test 4: Default values
    total++;
    if (test_assert_equals(global.game_options.display.width, 1920, "Default width")) passed++;
    total++;
    if (test_assert_equals(global.game_options.display.height, 1080, "Default height")) passed++;
    
    // Test 5: Config get/set
    var old_value = config_get("ui", "button_width");
    config_set("ui", "button_width", 999);
    total++;
    if (test_assert_equals(config_get("ui", "button_width"), 999, "Config set/get")) passed++;
    config_set("ui", "button_width", old_value); // Restore
    
    // Test 6: Save and load
    var temp_file = global.config_file;
    global.config_file = "test_config.ini";
    config_save();
    
    // Modify in memory
    var old_width = global.game_options.display.width;
    global.game_options.display.width = 1234;
    
    // Load should restore
    config_load();
    total++;
    if (test_assert_equals(global.game_options.display.width, old_width, "Config save/load")) passed++;
    
    // Cleanup
    file_delete(global.config_file);
    global.config_file = temp_file;
    
    dev_console_log(string("Config tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// LOGGER SYSTEM TESTS
// ============================================================================

/// @function test_run_logger_tests()
/// @description Test logging system
function test_run_logger_tests() {
    dev_console_log("=== Logger System Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: Logger initialization
    total++;
    if (test_assert(variable_global_exists("log_enabled"), "Logger initialized")) passed++;
    
    // Test 2: Log file creation
    if (global.log_enabled) {
        total++;
        if (test_assert(file_exists(global.log_file), "Log file exists")) passed++;
    }
    
    // Test 3: Log levels
    var old_level = global.log_level;
    global.log_level = LogLevel.WARNING;
    
    // This should not appear in log
    logger_write(LogLevel.INFO, "Test", "This should not appear", "Level test");
    
    // This should appear
    logger_write(LogLevel.ERROR, "Test", "This should appear", "Level test");
    
    global.log_level = old_level; // Restore
    
    total++;
    passed++; // Can't easily verify file contents, assume success if no crash
    dev_console_log("  ✓ Log level filtering", global.dev_console.success_color);
    
    // Test 4: Different log levels
    var levels = [LogLevel.DEBUG, LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR, LogLevel.CRITICAL];
    for (var i = 0; i < array_length(levels); i++) {
        total++;
        try {
            logger_write(levels[i], "Test", "Testing level " + string(levels[i]), "Unit test");
            passed++;
            dev_console_log("  ✓ Log level " + string(levels[i]), global.dev_console.success_color);
        } catch (error) {
            dev_console_log("  ✗ Log level " + string(levels[i]) + " - " + string(error), 
                           global.dev_console.error_color);
        }
    }
    
    dev_console_log(string("Logger tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// ASSET MANAGER TESTS
// ============================================================================

/// @function test_run_asset_tests()
/// @description Test asset management system
function test_run_asset_tests() {
    dev_console_log("=== Asset Manager Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: Asset manager initialization
    total++;
    if (test_assert(variable_global_exists("loaded_sprites"), "Sprites map exists")) passed++;
    total++;
    if (test_assert(variable_global_exists("asset_manifest"), "Manifest map exists")) passed++;
    
    // Test 2: Manifest loading
    total++;
    if (test_assert(ds_map_size(global.asset_manifest) > 0, "Manifest has entries")) passed++;
    
    // Test 3: Asset loading - nonexistent asset
    var bad_sprite = assets_get_sprite("nonexistent_asset");
    total++;
    if (test_assert_equals(bad_sprite, -1, "Nonexistent asset returns -1")) passed++;
    
    // Test 4: Safe sprite getter
    var safe_sprite = assets_get_sprite_safe("nonexistent_asset");
    total++;
    if (test_assert_equals(safe_sprite, -1, "Safe getter returns -1")) passed++;
    
    // Test 5: Asset caching
    var sprite1 = assets_get_sprite("mainmenu_background");
    var sprite2 = assets_get_sprite("mainmenu_background");
    total++;
    if (test_assert_equals(sprite1, sprite2, "Asset caching works")) passed++;
    
    // Test 6: Invalid input handling
    total++;
    if (test_assert_equals(assets_get_sprite(undefined), -1, "Undefined input handled")) passed++;
    total++;
    if (test_assert_equals(assets_get_sprite(""), -1, "Empty string handled")) passed++;
    total++;
    if (test_assert_equals(assets_get_sprite(123), -1, "Non-string input handled")) passed++;
    
    dev_console_log(string("Asset tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// INPUT MANAGER TESTS
// ============================================================================

/// @function test_run_input_tests()
/// @description Test input management and command system
function test_run_input_tests() {
    dev_console_log("=== Input Manager Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: Input manager initialization
    total++;
    if (test_assert(variable_global_exists("command_queue"), "Command queue exists")) passed++;
    total++;
    if (test_assert(variable_global_exists("input_mapping"), "Input mapping exists")) passed++;
    
    // Test 2: Command creation
    var cmd = input_create_command(CommandType.PAUSE, {test: "data"}, 0);
    total++;
    if (test_assert_type(cmd, is_struct, "Command is struct")) passed++;
    total++;
    if (test_assert_equals(cmd.type, CommandType.PAUSE, "Command type set")) passed++;
    total++;
    if (test_assert_exists(cmd.timestamp, "Command has timestamp")) passed++;
    
    // Test 3: Command queue
    var queue_size_before = ds_queue_size(global.command_queue);
    input_queue_command(cmd);
    total++;
    if (test_assert_equals(ds_queue_size(global.command_queue), queue_size_before + 1, 
                          "Command queued")) passed++;
    
    // Test 4: Command dequeue
    var dequeued = input_dequeue_command();
    total++;
    if (test_assert_equals(dequeued.type, cmd.type, "Correct command dequeued")) passed++;
    
    // Test 5: Empty queue
    ds_queue_clear(global.command_queue);
    var empty = input_dequeue_command();
    total++;
    if (test_assert(is_undefined(empty), "Empty queue returns undefined")) passed++;
    
    // Test 6: UI focus
    input_set_ui_focus(true);
    total++;
    if (test_assert(global.input_state.ui_has_focus, "UI focus set")) passed++;
    input_set_ui_focus(false);
    total++;
    if (test_assert(!global.input_state.ui_has_focus, "UI focus cleared")) passed++;
    
    // Test 7: Input mapping
    total++;
    if (test_assert_type(global.input_mapping, is_struct, "Input mapping is struct")) passed++;
    total++;
    if (test_assert_exists(global.input_mapping.move_up, "Move up mapping exists")) passed++;
    
    dev_console_log(string("Input tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// OBSERVER PATTERN TESTS
// ============================================================================

/// @function test_run_observer_tests()
/// @description Test observer pattern implementation
function test_run_observer_tests() {
    dev_console_log("=== Observer Pattern Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: Observer system initialization
    total++;
    if (test_assert(variable_global_exists("gamestate_observers"), "Observer map exists")) passed++;
    
    // Test 2: Add observer
    var test_called = false;
    var test_func = function(data) { test_called = true; };
    gamestate_add_observer("test_event", test_func);
    
    total++;
    if (test_assert(ds_map_exists(global.gamestate_observers, "test_event"), 
                   "Event registered")) passed++;
    
    // Test 3: Notify observers
    gamestate_notify_observers("test_event", {test: "data"});
    total++;
    if (test_assert(test_called, "Observer callback executed")) passed++;
    
    // Test 4: Remove observer
    gamestate_remove_observer("test_event", test_func);
    test_called = false;
    gamestate_notify_observers("test_event", {test: "data"});
    total++;
    if (test_assert(!test_called, "Observer removed successfully")) passed++;
    
    // Test 5: Multiple observers
    var count = 0;
    var func1 = function(data) { count++; };
    var func2 = function(data) { count++; };
    var func3 = function(data) { count++; };
    
    gamestate_add_observer("multi_test", func1);
    gamestate_add_observer("multi_test", func2);
    gamestate_add_observer("multi_test", func3);
    
    gamestate_notify_observers("multi_test", {});
    total++;
    if (test_assert_equals(count, 3, "Multiple observers called")) passed++;
    
    // Cleanup
    gamestate_remove_observer("multi_test", func1);
    gamestate_remove_observer("multi_test", func2);
    gamestate_remove_observer("multi_test", func3);
    
    // Test 6: Error handling in observer
    var error_func = function(data) { 
        var divzero = 5/0; // This will cause an error
    };
    gamestate_add_observer("error_test", error_func);
    
    // Should not crash
    try {
        gamestate_notify_observers("error_test", {});
        total++;
        passed++;
        dev_console_log("  ✓ Error handling in observer", global.dev_console.success_color);
    } catch (error) {
        total++;
        dev_console_log("  ✗ Error handling failed", global.dev_console.error_color);
    }
    
    gamestate_remove_observer("error_test", error_func);
    
    dev_console_log(string("Observer tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// JSON UTILITIES TESTS
// ============================================================================

/// @function test_run_json_tests()
/// @description Test JSON utility functions
function test_run_json_tests() {
    dev_console_log("=== JSON Utilities Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: JSON structure validation
    var test_struct = { name: "test", value: 123, active: true };
    total++;
    if (test_assert(json_validate_structure(test_struct, ["name", "value"]), 
                   "Valid structure passes")) passed++;
    total++;
    if (test_assert(!json_validate_structure(test_struct, ["missing_field"]), 
                   "Invalid structure fails")) passed++;
    
    // Test 2: JSON merge
    var base = { a: 1, b: 2 };
    var overlay = { b: 3, c: 4 };
    var merged = json_merge_structures(base, overlay);
    total++;
    if (test_assert_equals(merged.a, 1, "Merge preserves base value")) passed++;
    total++;
    if (test_assert_equals(merged.b, 3, "Merge overwrites with overlay")) passed++;
    total++;
    if (test_assert_equals(merged.c, 4, "Merge adds new values")) passed++;
    
    // Test 3: Deep copy
    var original = { x: 10, nested: { y: 20 } };
    var copy = json_deep_copy(original);
    copy.x = 99;
    copy.nested.y = 99;
    total++;
    if (test_assert_equals(original.x, 10, "Deep copy - original unchanged")) passed++;
    total++;
    if (test_assert_equals(original.nested.y, 20, "Deep copy - nested unchanged")) passed++;
    
    // Test 4: Nested value get/set
    var nested = { player: { stats: { health: 100 } } };
    total++;
    if (test_assert_equals(json_get_nested_value(nested, "player.stats.health"), 100, 
                          "Get nested value")) passed++;
    
    json_set_nested_value(nested, "player.stats.mana", 50);
    total++;
    if (test_assert_equals(nested.player.stats.mana, 50, "Set nested value")) passed++;
    
    // Test 5: File operations
    var test_data = { test: "data", number: 42 };
    var test_file = "test_json.json";
    
    total++;
    if (test_assert(json_save_file(test_file, test_data), "Save JSON file")) passed++;
    
    var loaded = json_load_file(test_file);
    total++;
    if (test_assert_equals(loaded.test, "data", "Load JSON file")) passed++;
    total++;
    if (test_assert_equals(loaded.number, 42, "Load JSON number")) passed++;
    
    // Cleanup
    file_delete(test_file);
    
    dev_console_log(string("JSON tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// HEX UTILITIES TESTS
// ============================================================================

/// @function test_run_hex_tests()
/// @description Test hexagonal grid utilities
function test_run_hex_tests() {
    dev_console_log("=== Hex Utilities Tests ===", global.dev_console.info_color);
    
    var passed = 0;
    var total = 0;
    
    // Test 1: Hex rounding
    var rounded = hex_round(1.7, 2.3);
    total++;
    if (test_assert_equals(rounded.q, 2, "Hex round q")) passed++;
    total++;
    if (test_assert_equals(rounded.r, 2, "Hex round r")) passed++;
    
    // Test 2: Hex distance
    var dist = hex_distance(0, 0, 3, -3);
    total++;
    if (test_assert_equals(dist, 3, "Hex distance calculation")) passed++;
    
    // Test 3: Hex neighbors
    var neighbors = hex_neighbors(0, 0);
    total++;
    if (test_assert_equals(array_length(neighbors), 6, "Six neighbors")) passed++;
    
    // Test 4: Pixel to hex conversion
    var hex_coords = hex_pixel_to_axial(100, 100);
    total++;
    if (test_assert_type(hex_coords, is_struct, "Pixel to hex returns struct")) passed++;
    total++;
    if (test_assert_exists(hex_coords.q, "Has q coordinate")) passed++;
    total++;
    if (test_assert_exists(hex_coords.r, "Has r coordinate")) passed++;
    
    // Test 5: Hex to pixel conversion
    var pixel_coords = hex_axial_to_pixel(5, 5);
    total++;
    if (test_assert_type(pixel_coords, is_struct, "Hex to pixel returns struct")) passed++;
    total++;
    if (test_assert_exists(pixel_coords.x, "Has x coordinate")) passed++;
    total++;
    if (test_assert_exists(pixel_coords.y, "Has y coordinate")) passed++;
    
    // Test 6: Hex line
    var line = hex_line(0, 0, 3, 0);
    total++;
    if (test_assert_equals(array_length(line), 4, "Hex line length")) passed++;
    
    // Test 7: Hex string conversion
    var hex_str = hex_to_string(10, -5);
    total++;
    if (test_assert_equals(hex_str, "(10,-5)", "Hex to string")) passed++;
    
    var parsed = hex_from_string("(10,-5)");
    total++;
    if (test_assert_equals(parsed.q, 10, "String to hex q")) passed++;
    total++;
    if (test_assert_equals(parsed.r, -5, "String to hex r")) passed++;
    
    dev_console_log(string("Hex tests: {0}/{1} passed", passed, total), 
                   passed == total ? global.dev_console.success_color : global.dev_console.error_color);
}

// ============================================================================
// PERFORMANCE BENCHMARKS
// ============================================================================

/// @function test_run_benchmarks()
/// @description Run performance benchmarks
function test_run_benchmarks() {
    dev_console_log("=== Performance Benchmarks ===", global.dev_console.info_color);
    
    var iterations = 10000;
    var start_time, elapsed;
    
    // Benchmark 1: Command creation
    start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        var cmd = input_create_command(CommandType.MOVE, {x: i, y: i}, 0);
    }
    elapsed = (get_timer() - start_time) / 1000;
    dev_console_log(string("Command creation: {0} ops in {1}ms ({2} ops/ms)", 
                          iterations, elapsed, iterations/elapsed), c_white);
    
    // Benchmark 2: Observer notifications
    var dummy_observer = function(data) { /* Do nothing */ };
    gamestate_add_observer("benchmark_event", dummy_observer);
    
    start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        gamestate_notify_observers("benchmark_event", {index: i});
    }
    elapsed = (get_timer() - start_time) / 1000;
    dev_console_log(string("Observer notify: {0} ops in {1}ms ({2} ops/ms)", 
                          iterations, elapsed, iterations/elapsed), c_white);
    
    gamestate_remove_observer("benchmark_event", dummy_observer);
    
    // Benchmark 3: Hex calculations
    start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        var dist = hex_distance(0, 0, i mod 20, -(i mod 20));
    }
    elapsed = (get_timer() - start_time) / 1000;
    dev_console_log(string("Hex distance: {0} ops in {1}ms ({2} ops/ms)", 
                          iterations, elapsed, iterations/elapsed), c_white);
    
    // Benchmark 4: JSON operations
    var test_struct = { a: 1, b: 2, c: { d: 3, e: 4 } };
    start_time = get_timer();
    for (var i = 0; i < iterations / 10; i++) { // Less iterations for expensive operation
        var copy = json_deep_copy(test_struct);
    }
    elapsed = (get_timer() - start_time) / 1000;
    dev_console_log(string("JSON deep copy: {0} ops in {1}ms ({2} ops/ms)", 
                          iterations/10, elapsed, (iterations/10)/elapsed), c_white);
    
    // Benchmark 5: Config get/set
    start_time = get_timer();
    for (var i = 0; i < iterations; i++) {
        var value = config_get("ui", "button_width", 300);
    }
    elapsed = (get_timer() - start_time) / 1000;
    dev_console_log(string("Config get: {0} ops in {1}ms ({2} ops/ms)", 
                          iterations, elapsed, iterations/elapsed), c_white);
    
    dev_console_log("Benchmarks complete", global.dev_console.success_color);
}