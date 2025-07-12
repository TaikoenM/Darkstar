/// @description Draw the main menu background image
/// @description Renders background sprite stretched to fill entire screen
/// @description Called every frame while in main menu room

// Get background sprite safely
var bg_sprite = assets_get_sprite_safe("mainmenu_background");

// Get display dimensions
var display_width = global.game_options.display.width;
var display_height = global.game_options.display.height;

// Draw background if sprite is valid
if (bg_sprite != -1 && sprite_exists(bg_sprite)) {
    draw_sprite_stretched(bg_sprite, 0, 0, 0, display_width, display_height);
} else {
    // Fallback: draw a solid color background if no sprite available
    draw_set_color(c_navy);
    draw_rectangle(0, 0, display_width, display_height, false);
    draw_set_color(c_white);
}