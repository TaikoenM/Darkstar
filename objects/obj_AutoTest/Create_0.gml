/// @description Initialize test runner and execute all test suites

// Test result tracking
test_results = {
    total_tests: 0,
    passed_tests: 0,
    failed_tests: 0,
    execution_time: 0,
    suite_results: [],
    failed_test_names: [],
    completed: false
};

// Display control
display_visible = true;
display_timer = 12000; // 5 seconds in milliseconds
start_time = current_time;

// Override the test framework temporarily to capture results
global.test_capture_mode = true;
global.test_capture_results = test_results;

logger_write(LogLevel.INFO, "TestRunner", "Starting automated test execution", "Test runner initialized");

// Execute all test suites
var execution_start = get_timer();

try {
    // Run each test suite and capture results
    var config_results = test_run_config_tests_captured();
    array_push(test_results.suite_results, config_results);
    
    var logger_results = test_run_logger_tests_captured();
    array_push(test_results.suite_results, logger_results);
    
    var asset_results = test_run_asset_tests_captured();
    array_push(test_results.suite_results, asset_results);
    
    var input_results = test_run_input_tests_captured();
    array_push(test_results.suite_results, input_results);
    
    var observer_results = test_run_observer_tests_captured();
    array_push(test_results.suite_results, observer_results);
    
    var json_results = test_run_json_tests_captured();
    array_push(test_results.suite_results, json_results);
    
    var hex_results = test_run_hex_tests_captured();
    array_push(test_results.suite_results, hex_results);
    
    // Calculate totals
    test_results.total_tests = 0;
    test_results.passed_tests = 0;
    test_results.failed_tests = 0;
    test_results.failed_test_names = [];
    
    for (var i = 0; i < array_length(test_results.suite_results); i++) {
        var suite = test_results.suite_results[i];
        test_results.total_tests += suite.total;
        test_results.passed_tests += suite.passed;
        test_results.failed_tests += suite.failed;
        
        // Collect failed test names (up to 5 total)
        if (variable_struct_exists(suite, "failed_names")) {
            for (var j = 0; j < array_length(suite.failed_names) && array_length(test_results.failed_test_names) < 5; j++) {
                array_push(test_results.failed_test_names, suite.name + ": " + suite.failed_names[j]);
            }
        }
    }
    
    test_results.execution_time = (get_timer() - execution_start) / 1000;
    test_results.completed = true;
    
    logger_write(LogLevel.INFO, "TestRunner", 
                string("Test execution completed - {0}/{1} passed", test_results.passed_tests, test_results.total_tests), 
                string("Execution time: {0}ms", test_results.execution_time));
    
} catch (error) {
    logger_write(LogLevel.ERROR, "TestRunner", "Test execution failed", string(error));
    test_results.completed = true;
}

// Restore normal test framework
global.test_capture_mode = false;