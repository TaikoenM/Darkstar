/// @description Handle console input and updates
if (keyboard_check_pressed(KEY_DEV_CONSOLE)) {
    dev_console_toggle();
}

if (!global.dev_console.enabled) exit;

// Handle text input
if (keyboard_check(vk_anykey) && keyboard_string != "") {
    global.dev_console.input_string += keyboard_string;
    keyboard_string = "";
}

// Handle special keys
if (keyboard_check_pressed(vk_backspace)) {
    if (string_length(global.dev_console.input_string) > 0) {
        global.dev_console.input_string = string_delete(global.dev_console.input_string, 
                                                       string_length(global.dev_console.input_string), 1);
    }
}

// Handle enter key
if (keyboard_check_pressed(vk_enter)) {
    if (string_length(global.dev_console.input_string) > 0) {
        dev_console_execute(global.dev_console.input_string);
        global.dev_console.input_string = "";
    }
}

// Handle command history navigation
if (keyboard_check_pressed(vk_up)) {
    var history_size = ds_list_size(global.dev_console.command_history);
    if (history_size > 0) {
        global.dev_console.history_index++;
        if (global.dev_console.history_index >= history_size) {
            global.dev_console.history_index = history_size - 1;
        }
        global.dev_console.input_string = global.dev_console.command_history[| history_size - 1 - global.dev_console.history_index];
    }
}

if (keyboard_check_pressed(vk_down)) {
    if (global.dev_console.history_index > 0) {
        global.dev_console.history_index--;
        var history_size = ds_list_size(global.dev_console.command_history);
        global.dev_console.input_string = global.dev_console.command_history[| history_size - 1 - global.dev_console.history_index];
    } else if (global.dev_console.history_index == 0) {
        global.dev_console.history_index = -1;
        global.dev_console.input_string = "";
    }
}

// Handle scrolling
if (mouse_wheel_up()) {
    global.dev_console.scroll_offset = max(0, global.dev_console.scroll_offset - 1);
}
if (mouse_wheel_down()) {
    var max_scroll = max(0, ds_list_size(global.dev_console.history) - global.dev_console.visible_lines);
    global.dev_console.scroll_offset = min(max_scroll, global.dev_console.scroll_offset + 1);
}

// Handle page up/down
if (keyboard_check_pressed(vk_pageup)) {
    global.dev_console.scroll_offset = max(0, global.dev_console.scroll_offset - 10);
}
if (keyboard_check_pressed(vk_pagedown)) {
    var max_scroll = max(0, ds_list_size(global.dev_console.history) - global.dev_console.visible_lines);
    global.dev_console.scroll_offset = min(max_scroll, global.dev_console.scroll_offset + 10);
}

// Update cursor blink
global.dev_console.cursor_blink = (current_time / 500) mod 2;