/// @description Handle button input detection and state updates
/// @description Processes mouse hover and click interactions each frame
/// @description Executes button callback when clicked while enabled

// Early exit if no button data
if (button_data == undefined) {
    return;
}

// Get mouse position in GUI coordinates
var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);

// Calculate button bounds for hit testing
var button_left = button_data.x - button_data.width / 2;
var button_right = button_data.x + button_data.width / 2;
var button_top = button_data.y - button_data.height / 2;
var button_bottom = button_data.y + button_data.height / 2;

// Check if mouse cursor is over the button
is_hovered = (mouse_x_gui >= button_left && mouse_x_gui <= button_right && 
              mouse_y_gui >= button_top && mouse_y_gui <= button_bottom);

// Handle mouse press
if (is_hovered && mouse_check_button_pressed(mb_left)) {
    is_pressed = true;
    logger_write(LogLevel.DEBUG, "MenuButton", 
                string("Button pressed: {0}", button_data.text), "User input");
}

// Handle mouse release and button activation
if (is_pressed && mouse_check_button_released(mb_left)) {
    is_pressed = false;
    
    // Execute callback if still hovering and button is enabled
    if (is_hovered && button_data.enabled) {
        logger_write(LogLevel.INFO, "MenuButton", 
                    string("Button clicked: {0}", button_data.text), "User interaction");
        
        // Safely execute callback
        try {
            if (!is_undefined(button_data.callback)) {
                button_data.callback();
            }
        } catch (error) {
            logger_write(LogLevel.ERROR, "MenuButton", 
                        string("Error executing button callback: {0}", error), 
                        string("Button: {0}", button_data.text));
        }
    }
}