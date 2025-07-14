/// @description Draw test results summary

if (!display_visible || !test_results.completed) {
    return;
}

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_font(-1); // Default font
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var panel_width = 400;
var panel_height = 400; // Increased to fit failed tests
var x_pos = (gui_width - panel_width);
var y_pos = 50;
var line_height = 20;
var margin = 15;

// Calculate fade effect based on remaining time
var fade_alpha = 1.0;
if (display_timer < 1000) { // Start fading in last second
    fade_alpha = display_timer / 1000;
}

// Draw background panel
draw_set_color(c_black);
draw_set_alpha(0.8 * fade_alpha);
draw_rectangle(x_pos, y_pos, x_pos + panel_width, y_pos + panel_height, false);

// Draw border
draw_set_color(c_white);
draw_set_alpha(0.9 * fade_alpha);
draw_rectangle(x_pos, y_pos, x_pos + panel_width, y_pos + panel_height, true);

// Prepare text content
var text_x = x_pos + margin;
var text_y = y_pos + margin;
var current_y = text_y;

// Main header
draw_set_color(c_yellow);
draw_set_alpha(fade_alpha);
draw_text(text_x, current_y, "=== AUTOMATED TEST RESULTS ===");
current_y += line_height * 1.5;

// Overall summary
var success_rate = test_results.total_tests > 0 ? (test_results.passed_tests / test_results.total_tests) * 100 : 0;
var summary_color = (test_results.passed_tests == test_results.total_tests) ? c_lime : c_orange;

draw_set_color(summary_color);
draw_text(text_x, current_y, string("Overall: {0}/{1} tests passed ({2}%)", 
                                   test_results.passed_tests, 
                                   test_results.total_tests, 
                                   string_format(success_rate, 1, 1)));
current_y += line_height;

draw_set_color(c_white);
draw_text(text_x, current_y, string("Execution time: {0}ms", string_format(test_results.execution_time, 1, 2)));
current_y += line_height * 1.5;

// Suite breakdown
draw_set_color(c_teal);
draw_text(text_x, current_y, "Test Suite Breakdown:");
current_y += line_height;

for (var i = 0; i < array_length(test_results.suite_results); i++) {
    var suite = test_results.suite_results[i];
    var suite_color = (suite.passed == suite.total) ? c_lime : ((suite.passed > 0) ? c_yellow : c_red);
    
    draw_set_color(suite_color);
    var suite_text = string("  {0}: {1}/{2}", suite.name, suite.passed, suite.total);
    draw_text(text_x, current_y, suite_text);
    current_y += line_height;
}

// Failed tests section
if (array_length(test_results.failed_test_names) > 0) {
    current_y += line_height * 0.5;
    draw_set_color(c_red);
    draw_text(text_x, current_y, "Failed Tests:");
    current_y += line_height;
    
    for (var i = 0; i < array_length(test_results.failed_test_names); i++) {
        draw_set_color(c_orange);
        draw_text(text_x + 10, current_y, "• " + test_results.failed_test_names[i]);
        current_y += line_height;
    }
    
    if (test_results.failed_tests > array_length(test_results.failed_test_names)) {
        draw_set_color(c_gray);
        var remaining = test_results.failed_tests - array_length(test_results.failed_test_names);
        draw_text(text_x + 10, current_y, string("... and {0} more", remaining));
        current_y += line_height;
    }
}

// Countdown timer
current_y += line_height;
draw_set_color(c_gray);
var remaining_seconds = max(0, display_timer / 1000);
draw_text(text_x, current_y, string("Auto-hide in: {0}s", string_format(remaining_seconds, 1, 1)));

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);