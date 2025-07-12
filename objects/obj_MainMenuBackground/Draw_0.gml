/// @description Draw the main menu background
/// @description Pure view component - only renders background

// Get background sprite safely
var bg_sprite = assets_get_sprite_safe("mainmenu_background");

// Get display dimensions
var display_width = display_get_gui_width();
var display_height = display_get_gui_height();

// Draw background if sprite is valid
if (bg_sprite != -1 && sprite_exists(bg_sprite)) {
    draw_sprite_stretched(bg_sprite, 0, 0, 0, display_width, display_height);
} else {
    // Fallback: draw a solid color background if no sprite available
    draw_set_color(c_navy);
    draw_rectangle(0, 0, display_width, display_height, false);
    draw_set_color(c_white);
}