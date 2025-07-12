/// @description Initialize menu button instance variables
/// @description Sets up button state and visual properties with defaults
/// @description Called when button instance is created

// Button data will be set by menu factory
button_data = undefined;

// Button state tracking
is_hovered = false;
is_pressed = false;

// Visual properties with defaults
button_color = c_gray;
button_color_hover = c_ltgray;
button_color_pressed = c_dkgray;
text_color = c_white;