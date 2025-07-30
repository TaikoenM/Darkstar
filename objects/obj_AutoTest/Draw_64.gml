/// @description Draw enhanced test results summary with scrolling support

if (!display_visible || !test_results.completed) {
    return;
}

// Calculate dimensions
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var panel_width = 500; // Increased width
var panel_height = min(600, gui_height - 100); // Dynamic height with max
var x_pos = gui_width - panel_width - 20;
var y_pos = 50;
var line_height = 20;
var margin = 15;
var scroll_bar_width = 10;

// Calculate fade effect
var fade_alpha = 1.0;
if (display_timer < 1000) {
    fade_alpha = display_timer / 1000;
}

// Draw shadow for depth
draw_set_color(c_black);
draw_set_alpha(0.3 * fade_alpha);
draw_rectangle(x_pos + 5, y_pos + 5, x_pos + panel_width + 5, y_pos + panel_height + 5, false);

// Draw background panel with gradient
draw_set_alpha(0.9 * fade_alpha);
draw_rectangle_color(x_pos, y_pos, x_pos + panel_width, y_pos + panel_height,
                    c_black, c_black, make_color_rgb(10, 10, 20), make_color_rgb(10, 10, 20), false);

// Draw border with glow effect
draw_set_color(c_white);
draw_set_alpha(0.9 * fade_alpha);
draw_rectangle(x_pos, y_pos, x_pos + panel_width, y_pos + panel_height, true);
draw_set_alpha(0.4 * fade_alpha);
draw_rectangle(x_pos - 1, y_pos - 1, x_pos + panel_width + 1, y_pos + panel_height + 1, true);

// Set up text drawing
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Calculate content area
var content_x = x_pos + margin;
var content_y = y_pos + margin;
var content_width = panel_width - (margin * 2) - scroll_bar_width;
var content_height = panel_height - (margin * 2);
var viewable_lines = floor(content_height / line_height);

// Calculate total content height
var total_content_lines = 10 + array_length(test_results.suite_results) + 
                         min(array_length(test_results.failed_test_names), 10) + 5;
var total_content_height = total_content_lines * line_height;
var needs_scroll = total_content_height > content_height;

// Initialize scroll if needed
if (!variable_instance_exists(id, "scroll_offset")) {
    scroll_offset = 0;
}

// Handle mouse wheel scrolling
if (needs_scroll && mouse_check_button(mb_any)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    if (mx >= x_pos && mx <= x_pos + panel_width && 
        my >= y_pos && my <= y_pos + panel_height) {
        scroll_offset += mouse_wheel_up() - mouse_wheel_down();
        scroll_offset = clamp(scroll_offset, 0, 
                            max(0, total_content_lines - viewable_lines));
    }
}

// Create surface for content (allows clipping)
var content_surface = surface_create(content_width, content_height);
surface_set_target(content_surface);
draw_clear_alpha(c_black, 0);

// Draw content to surface
var current_line = -scroll_offset;
var draw_y = current_line * line_height;

// Main header
draw_set_color(c_yellow);
draw_set_alpha(fade_alpha);
draw_set_font(fnt_title); // Assuming you have a title font
draw_text(5, draw_y, "AUTOMATED TEST RESULTS");
draw_set_font(-1);
current_line += 2;
draw_y = current_line * line_height;

// Test execution info
draw_set_color(c_aqua);
draw_text(5, draw_y, string("Executed: {0} test suites in {1}ms", 
                           array_length(test_results.suite_results),
                           string_format(test_results.execution_time, 1, 2)));
current_line += 1.5;
draw_y = current_line * line_height;

// Overall summary with visual indicator
var success_rate = test_results.total_tests > 0 ? 
                  (test_results.passed_tests / test_results.total_tests) * 100 : 0;
var summary_color = (success_rate == 100) ? c_lime : ((success_rate >= 80) ? c_yellow : ((success_rate >= 50) ? c_orange : c_red));

// Draw progress bar
var bar_width = content_width - 10;
var bar_height = 20;
var bar_x = 5;
var bar_y = draw_y;

// Background
draw_set_color(c_dkgray);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

// Fill
draw_set_color(summary_color);
draw_rectangle(bar_x, bar_y, bar_x + (bar_width * success_rate / 100), 
              bar_y + bar_height, false);

// Border
draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);

// Text overlay
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(bar_x + bar_width/2, bar_y + 2, 
         string("{0}/{1} tests passed ({2}%)", 
                test_results.passed_tests, 
                test_results.total_tests, 
                string_format(success_rate, 1, 1)));
draw_set_halign(fa_left);

current_line += 2;
draw_y = current_line * line_height;

// Suite breakdown header
draw_set_color(c_teal);
draw_text(5, draw_y, "Test Suite Results:");
current_line += 1;
draw_y = current_line * line_height;

// Draw each suite with mini progress bar
for (var i = 0; i < array_length(test_results.suite_results); i++) {
    var suite = test_results.suite_results[i];
    var suite_rate = suite.total > 0 ? (suite.passed / suite.total) * 100 : 0;
    var suite_color = (suite_rate == 100) ? c_lime : 
                     ((suite_rate > 0) ? c_yellow : c_red);
    
    // Suite name and numbers
    draw_set_color(c_white);
    draw_text(15, draw_y, string("{0}:", suite.name));
    
    // Mini progress bar
    var mini_bar_x = 150;
    var mini_bar_width = 100;
    var mini_bar_height = 12;
    
    draw_set_color(c_dkgray);
    draw_rectangle(mini_bar_x, draw_y + 2, mini_bar_x + mini_bar_width, 
                  draw_y + 2 + mini_bar_height, false);
    
    draw_set_color(suite_color);
    draw_rectangle(mini_bar_x, draw_y + 2, 
                  mini_bar_x + (mini_bar_width * suite_rate / 100), 
                  draw_y + 2 + mini_bar_height, false);
    
    // Numbers
    draw_set_color(suite_color);
    draw_text(mini_bar_x + mini_bar_width + 10, draw_y, 
             string("{0}/{1}", suite.passed, suite.total));
    
    current_line += 1;
    draw_y = current_line * line_height;
}

// Failed tests section
if (array_length(test_results.failed_test_names) > 0) {
    current_line += 0.5;
    draw_y = current_line * line_height;
    
    draw_set_color(c_red);
    draw_text(5, draw_y, string("Failed Tests ({0}):", 
                               array_length(test_results.failed_test_names)));
    current_line += 1;
    draw_y = current_line * line_height;
    
    // Show up to 10 failed tests
    var max_failed_shown = min(10, array_length(test_results.failed_test_names));
    for (var i = 0; i < max_failed_shown; i++) {
        draw_set_color(c_orange);
        var failed_text = test_results.failed_test_names[i];
        
        // Truncate if too long
        if (string_width(failed_text) > content_width - 30) {
            failed_text = string_copy(failed_text, 1, 40) + "...";
        }
        
        draw_text(20, draw_y, "• " + failed_text);
        current_line += 1;
        draw_y = current_line * line_height;
    }
    
    if (array_length(test_results.failed_test_names) > max_failed_shown) {
        draw_set_color(c_gray);
        var remaining = array_length(test_results.failed_test_names) - max_failed_shown;
        draw_text(20, draw_y, string("... and {0} more", remaining));
        current_line += 1;
        draw_y = current_line * line_height;
    }
}

// Draw surface back to screen
surface_reset_target();
draw_surface_part(content_surface, 0, 0, content_width, content_height, 
                 content_x, content_y);
surface_free(content_surface);

// Draw scroll bar if needed
if (needs_scroll) {
    var scroll_bar_x = x_pos + panel_width - scroll_bar_width - 5;
    var scroll_bar_y = y_pos + margin;
    var scroll_bar_height = content_height;
    var thumb_height = max(20, (viewable_lines / total_content_lines) * scroll_bar_height);
    var thumb_y = scroll_bar_y + (scroll_offset / max(1, total_content_lines - viewable_lines)) * 
                 (scroll_bar_height - thumb_height);
    
    // Scroll track
    draw_set_color(c_dkgray);
    draw_set_alpha(0.5 * fade_alpha);
    draw_rectangle(scroll_bar_x, scroll_bar_y, scroll_bar_x + scroll_bar_width, 
                  scroll_bar_y + scroll_bar_height, false);
    
    // Scroll thumb
    draw_set_color(c_gray);
    draw_set_alpha(0.8 * fade_alpha);
    draw_rectangle(scroll_bar_x, thumb_y, scroll_bar_x + scroll_bar_width, 
                  thumb_y + thumb_height, false);
}

// Footer with controls
draw_set_color(c_gray);
draw_set_alpha(fade_alpha);
draw_set_halign(fa_center);
var footer_y = y_pos + panel_height - 25;
draw_text(x_pos + panel_width/2, footer_y, 
         string("[ESC] Hide • [T] Run Again • Auto-hide in {0}s", 
                string_format(max(0, display_timer/1000), 1, 0)));

// Legend
draw_set_halign(fa_right);
draw_set_font(fnt_small); // Assuming you have a small font
draw_set_color(c_lime);
draw_text(x_pos + panel_width - margin, y_pos + margin, "✓ Passed");
draw_set_color(c_red);
draw_text(x_pos + panel_width - margin, y_pos + margin + 15, "✗ Failed");

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_font(-1);

// Handle keyboard shortcuts
if (keyboard_check_pressed(vk_escape)) {
    display_visible = false;
}
if (keyboard_check_pressed(ord("T"))) {
    // Re-run tests
    test_results = test_run_all_captured();
    display_timer = display_duration;
}