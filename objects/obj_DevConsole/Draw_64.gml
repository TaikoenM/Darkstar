/// @description Render the developer console with improved text wrapping and display
if (!global.dev_console.enabled) exit;

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var console_height = gui_height * 0.5; // Console takes up half the screen

// Draw background
draw_set_alpha(global.dev_console.alpha);
draw_set_color(global.dev_console.bg_color);
draw_rectangle(0, 0, gui_width, console_height, false);

// Draw border
draw_set_alpha(1);
draw_set_color(global.dev_console.text_color);
draw_line(0, console_height, gui_width, console_height);

// Set up text drawing
draw_set_font(-1); // Use default font
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var line_height = 16;
var margin = 10;
var usable_width = gui_width - margin * 2 - 20; // Extra space for scrollbar
var max_lines = floor((console_height - margin * 3 - line_height) / line_height); // Reserve space for input

// Enhanced text wrapping with character-level splitting
function wrap_text(text, max_width) {
    if (string_width(text) <= max_width) {
        return [text]; // No wrapping needed
    }
    
    var words = string_split(text, " ");
    var lines = [];
    var current_line = "";
    
    for (var i = 0; i < array_length(words); i++) {
        var word = words[i];
        var test_line = current_line;
        
        if (current_line != "") {
            test_line += " ";
        }
        test_line += word;
        
        if (string_width(test_line) <= max_width) {
            current_line = test_line;
        } else {
            // Current line is full, start new line
            if (current_line != "") {
                array_push(lines, current_line);
            }
            
            // Check if single word is too long
            if (string_width(word) > max_width) {
                // Split the word character by character
                var char_line = "";
                for (var j = 1; j <= string_length(word); j++) {
                    var char = string_char_at(word, j);
                    var test_char_line = char_line + char;
                    
                    if (string_width(test_char_line) <= max_width) {
                        char_line = test_char_line;
                    } else {
                        if (char_line != "") {
                            array_push(lines, char_line);
                        }
                        char_line = char;
                    }
                }
                if (char_line != "") {
                    current_line = char_line;
                } else {
                    current_line = "";
                }
            } else {
                current_line = word;
            }
        }
    }
    
    if (current_line != "") {
        array_push(lines, current_line);
    }
    
    return lines;
}

// Process all history entries into display lines
var display_lines = [];
var history_size = ds_list_size(global.dev_console.history);

for (var i = 0; i < history_size; i++) {
    var entry = global.dev_console.history[| i];
    var wrapped_lines = wrap_text(entry.text, usable_width);
    
    for (var j = 0; j < array_length(wrapped_lines); j++) {
        array_push(display_lines, {
            text: wrapped_lines[j],
            color: entry.color,
            is_continuation: j > 0 // Mark continuation lines
        });
    }
}

// Calculate scroll limits
var total_display_lines = array_length(display_lines);
var max_scroll = max(0, total_display_lines - max_lines);

// Adjust scroll offset to stay within bounds
global.dev_console.scroll_offset = clamp(global.dev_console.scroll_offset, 0, max_scroll);

// Draw visible lines
var y_pos = margin;
var start_line = global.dev_console.scroll_offset;
var end_line = min(total_display_lines, start_line + max_lines);

for (var i = start_line; i < end_line; i++) {
    var display_line = display_lines[i];
    
    draw_set_color(display_line.color);
    
    // Add slight indent for continuation lines
    var x_offset = display_line.is_continuation ? margin + 10 : margin;
    
    draw_text(x_offset, y_pos, display_line.text);
    y_pos += line_height;
}

// Draw input area
var input_y = console_height - line_height * 2 - margin;

// Draw input background
draw_set_alpha(0.3);
draw_set_color(c_dkgray);
draw_rectangle(margin, input_y - 2, gui_width - margin - 20, console_height - margin, false);

// Draw input text
draw_set_alpha(1);
draw_set_color(global.dev_console.text_color);
var input_prompt = "> ";
var input_display = input_prompt + global.dev_console.input_string;

// Handle input wrapping if it's too long
var input_lines = wrap_text(input_display, usable_width);
var input_start_y = input_y;

// Always show at least the last line of input
var visible_input_lines = min(array_length(input_lines), 2); // Show max 2 lines of input
var start_input_line = max(0, array_length(input_lines) - visible_input_lines);

for (var i = start_input_line; i < array_length(input_lines); i++) {
    draw_text(margin, input_start_y, input_lines[i]);
    input_start_y += line_height;
}

// Draw cursor on the last visible line
if (global.dev_console.cursor_blink) {
    var last_visible_line = input_lines[array_length(input_lines) - 1];
    var cursor_x = margin + string_width(last_visible_line);
    var cursor_y = input_y + (visible_input_lines - 1) * line_height;
    draw_line(cursor_x, cursor_y, cursor_x, cursor_y + line_height);
}

// Draw scroll indicator if needed
if (total_display_lines > max_lines) {
    var scroll_bar_x = gui_width - 15;
    var scroll_bar_width = 10;
    var scroll_bar_height = console_height - input_y - margin;
    var scroll_bar_y = margin;
    
    // Background
    draw_set_alpha(0.3);
    draw_set_color(c_gray);
    draw_rectangle(scroll_bar_x, scroll_bar_y, scroll_bar_x + scroll_bar_width, scroll_bar_y + scroll_bar_height, false);
    
    // Thumb
    var scroll_percent = total_display_lines > max_lines ? global.dev_console.scroll_offset / max_scroll : 0;
    var thumb_height = max(10, scroll_bar_height * (max_lines / total_display_lines));
    var thumb_y = scroll_bar_y + (scroll_bar_height - thumb_height) * scroll_percent;
    
    draw_set_alpha(0.8);
    draw_set_color(c_white);
    draw_rectangle(scroll_bar_x, thumb_y, scroll_bar_x + scroll_bar_width, thumb_y + thumb_height, false);
}

// Reset drawing settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);