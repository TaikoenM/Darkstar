/// @description Draw the main menu background
/// @description Pure view component - only renders background

// Get background sprite safely
var bg_sprite = assets_get_sprite_safe("mainmenu_background");

// Get display dimensions
var display_width = display_get_gui_width();
var display_height = display_get_gui_height();

// Draw background if sprite is valid
if (bg_sprite != -1 && sprite_exists(bg_sprite)) {
    // Debug: Log successful sprite retrieval
    if (variable_global_exists("log_enabled") && global.log_enabled && global.log_level == LogLevel.DEBUG) {
        logger_write(LogLevel.DEBUG, "MainMenuBackground", 
                    string("Drawing background sprite: ID={0}, Size={1}x{2}", 
                           bg_sprite, sprite_get_width(bg_sprite), sprite_get_height(bg_sprite)), 
                    "Background rendering");
    }
    
    draw_sprite_stretched(bg_sprite, 0, 0, 0, display_width, display_height);
} else {
    // Fallback: draw a solid color background if no sprite available
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.WARNING, "MainMenuBackground", 
                    string("Background sprite not available (ID: {0}), using fallback", bg_sprite), 
                    "Missing background asset");
    }
    
    draw_set_color(c_navy);
    draw_rectangle(0, 0, display_width, display_height, false);
    draw_set_color(c_white);
}