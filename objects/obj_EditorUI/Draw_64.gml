/// @description Draw UI panel backgrounds

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

// Draw panel backgrounds
draw_set_color(c_dkgray);
draw_set_alpha(0.9);

// Top panel
draw_rectangle(0, 0, gui_width, top_panel_height, false);

// Left panel
draw_rectangle(0, left_panel_top, left_panel_width, gui_height - bottom_panel_height, false);

// Bottom panel
draw_rectangle(0, gui_height - bottom_panel_height, gui_width, gui_height, false);

// Draw panel borders
draw_set_color(c_black);
draw_set_alpha(1);

// Top panel border
draw_line(0, top_panel_height - 1, gui_width, top_panel_height - 1);

// Left panel border
draw_line(left_panel_width - 1, left_panel_top, left_panel_width - 1, gui_height - bottom_panel_height);

// Bottom panel border
draw_line(0, gui_height - bottom_panel_height, gui_width, gui_height - bottom_panel_height);

draw_set_alpha(1);