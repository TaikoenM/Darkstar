/// @description Update button hover state

// Update hover state using native collision
is_hovered = position_meeting(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), id);

// === MOUSE LEFT PRESSED EVENT ===
/// @description Handle mouse press

if (is_hovered && enabled) {
    is_pressed = true;
}