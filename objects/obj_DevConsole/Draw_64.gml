/// @description Render the developer console
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
var y_pos = margin;

// Draw history
var history_size = ds_list_size(global.dev_console.history);
var start_index = global.dev_console.scroll_offset;
var end_index = min(history_size, start_index + global.dev_console.visible_lines);

for (var i = start_index; i < end_index; i++) {
    var entry = global.dev_console.history[| i];
    draw_set_color(entry.color);
    draw_text(margin, y_pos, entry.text);
    y_pos += line_height;
}

// Draw input line
y_pos = console_height - line_height - margin;
draw_set_color(global.dev_console.text_color);
draw_text(margin, y_pos, "> " + global.dev_console.input_string);

// Draw cursor
if (global.dev_console.cursor_blink) {
    var cursor_x = margin + string_width("> " + global.dev_console.input_string);
    draw_line(cursor_x, y_pos, cursor_x, y_pos + line_height);
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