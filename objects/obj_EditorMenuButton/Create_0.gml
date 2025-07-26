/// @description Initialize menu button

// Menu button properties
menu_id = "";                    // "planet_menu" or "view_menu"
menu_text = "";                  // Display text
menu_items = [];                 // Array of menu item structs
is_open = false;                 // Is dropdown open
hover = false;                   // Mouse hover state
button_width = 120;              // Width of button
button_height = 40;              // Height of button
dropdown_width = 250;            // Width of dropdown
item_height = 30;                // Height of each menu item
separator_height = 10;           // Height of separator

// Position (set by creator)
gui_x = 0;
gui_y = 0;

// Visual properties
color_normal = make_color_rgb(60, 60, 60);
color_hover = make_color_rgb(80, 80, 80);
color_pressed = make_color_rgb(100, 100, 100);
color_text = c_white;
color_dropdown_bg = make_color_rgb(40, 40, 40);
color_dropdown_item_hover = make_color_rgb(70, 70, 70);

// Menu item structure:
// {
//     type: "item" | "separator" | "checkbox",
//     id: "new_blank_planet",
//     text: "New Blank Planet...",
//     enabled: true,
//     checked: false,  // For checkbox items
//     shortcut: "Ctrl+S"  // Optional
// }

// Track hovered item
hovered_item_index = -1;

// Depth for proper layering
depth = -1000;