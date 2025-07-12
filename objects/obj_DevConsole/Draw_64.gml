/// @description Render the developer console with text wrapping
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
var usable_width = gui_width - margin * 2;
var y_pos = margin;

// Function to wrap text
function wrap_text(text, max_width) {
    var words = string_split(text, " ");
    var lines = [];
    var current_line = "";
    
    for (var i = 0; i < array_length(words); i++) {
        var test_line = current_line;
        if (current_line != "") test_line += " ";
        test_line += words[i];
        
        if (string_width(test_line) <= max_width) {
            current_line = test_line;
        } else {
            if (current_line != "") {
                array_push(lines, current_line);
                current_line = words[i];
            } else {
                // Single word is too long, force break
                array_push(lines, words[i]);
                current_line = "";
            }
        }
    }
    
    if (current_line != "") {
        array_push(lines, current_line);
    }
    
    return lines;
}

// Draw history with wrapping
var history_size = ds_list_size(global.dev_console.history);
var start_index = global.dev_console.scroll_offset;
var end_index = min(history_size, start_index + global.dev_console.visible_lines);
var lines_drawn = 0;

for (var i = start_index; i < end_index && y_pos < console_height - line_height * 2; i++) {
    var entry = global.dev_console.history[| i];
    var wrapped_lines = wrap_text(entry.text, usable_width);
    
    draw_set_color(entry.color);
    for (var j = 0; j < array_length(wrapped_lines); j++) {
        if (y_pos >= console_height - line_height * 2) break;
        draw_text(margin, y_pos, wrapped_lines[j]);
        y_pos += line_height;
        lines_drawn++;
    }
    
    // Prevent drawing too many lines
    if (lines_drawn >= global.dev_console.visible_lines) break;
}

// Draw input line
y_pos = console_height - line_height - margin;
draw_set_color(global.dev_console.text_color);
var input_text = "> " + global.dev_console.input_string;
var input_lines = wrap_text(input_text, usable_width);

// Draw all input lines (in case input is very long)
var input_start_y = y_pos - (array_length(input_lines) - 1) * line_height;
for (var i = 0; i < array_length(input_lines); i++) {
    draw_text(margin, input_start_y + i * line_height, input_lines[i]);
}

// Draw cursor on the last line
if (global.dev_console.cursor_blink) {
    var last_line = input_lines[array_length(input_lines) - 1];
    var cursor_x = margin + string_width(last_line);
    var cursor_y = input_start_y + (array_length(input_lines) - 1) * line_height;
    draw_line(cursor_x, cursor_y, cursor_x, cursor_y + line_height);
}

// Draw scroll indicator if needed
if (history_size > global.dev_console.visible_lines) {
    var scroll_percent = global.dev_console.scroll_offset / max(1, history_size - global.dev_console.visible_lines);
    var scroll_bar_height = console_height - margin * 2;
    var scroll_thumb_height = max(20, scroll_bar_height * (global.dev_console.visible_lines / history_size));
    var scroll_thumb_y = margin + (scroll_bar_height - scroll_thumb_height) * scroll_percent;
    
    draw_set_alpha(0.5);
    draw_set_color(c_gray);
    draw_rectangle(gui_width - 10, margin, gui_width - 5, console_height - margin, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_rectangle(gui_width - 10, scroll_thumb_y, gui_width - 5, scroll_thumb_y + scroll_thumb_height, false);
}

// Reset drawing settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);