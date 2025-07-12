/// @description Draw button with current visual state
if (!visible) exit;

// Determine current color
var current_color = button_color;
if (!enabled) {
    current_color = c_dkgray;
} else if (is_hovered) {
    current_color = button_color_hover;
}

// Draw button background
draw_set_color(current_color);
draw_rectangle(x - width/2, y - height/2, x + width/2, y + height/2, false);

// Draw button border
draw_set_color(c_white);
draw_rectangle(x - width/2, y - height/2, x + width/2, y + height/2, true);

// Draw button text
draw_set_color(enabled ? text_color : c_gray);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y, text);

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);