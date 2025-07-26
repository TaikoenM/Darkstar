/// @description Update hover states

// Get mouse position in GUI coordinates
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Check button hover
var prev_hover = hover;
hover = point_in_rectangle(mx, my, gui_x, gui_y, gui_x + button_width, gui_y + button_height);

// Check dropdown item hover if open
if (is_open) {
    hovered_item_index = -1;
    
    var dropdown_y = gui_y + button_height;
    
    // Check if mouse is within dropdown bounds
    if (mx >= gui_x && mx <= gui_x + dropdown_width) {
        var item_y = dropdown_y;
        
        for (var i = 0; i < array_length(menu_items); i++) {
            var item = menu_items[i];
            
            if (item.type == "separator") {
                item_y += separator_height;
            } else {
                if (my >= item_y && my <= item_y + item_height) {
                    if (item.enabled) {
                        hovered_item_index = i;
                    }
                    break;
                }
                item_y += item_height;
            }
        }
    }
    
    // Close menu if clicked outside
    if (mouse_check_button_pressed(mb_left)) {
        var dropdown_height = editor_menu_get_dropdown_height();
        if (!point_in_rectangle(mx, my, gui_x, gui_y, gui_x + dropdown_width, gui_y + button_height + dropdown_height)) {
            is_open = false;
        }
    }
}