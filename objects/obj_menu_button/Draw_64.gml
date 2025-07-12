/// @description Draw the menu button with current state styling
/// @description Renders button background, border, and text in GUI layer
/// @description Uses different colors based on hover/press state

// Early exit if no button data or button is hidden
if (button_data == undefined || !button_data.visible) {
    return;
}

// Determine button color based on current state
var current_color = button_color;
if (is_pressed) {
    current_color = button_color_pressed;
} else if (is_hovered) {
    current_color = button_color_hover;
}

// Calculate button bounds
var button_left = button_data.x - button_data.width / 2;
var button_top = button_data.y - button_data.height / 2;
var button_right = button_left + button_data.width;
var button_bottom = button_top + button_data.height;

// Draw button background
draw_set_color(current_color);
draw_rectangle(button_left, button_top, button_right, button_bottom, false);

// Draw button border
draw_set_color(c_white);
draw_rectangle(button_left, button_top, button_right, button_bottom, true);

// Draw button text centered
draw_set_color(text_color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_data.x, button_data.y, button_data.text);

// Reset draw settings to defaults
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
