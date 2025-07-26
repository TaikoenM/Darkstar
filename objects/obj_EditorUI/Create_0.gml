/// @description Initialize editor UI

// Create top menu bar
planet_menu = editor_create_planet_menu();
view_menu = editor_create_view_menu();

// Panel dimensions
top_panel_height = 60;
left_panel_width = 200;
left_panel_top = 60;
bottom_panel_height = 100;

// Depth for background drawing
depth = 1000; // Behind UI elements