/// @description Handle menu clicks

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Check if clicking on button
if (point_in_rectangle(mx, my, gui_x, gui_y, gui_x + button_width, gui_y + button_height)) {
    // Toggle menu
    is_open = !is_open;
    
    // Close other menus
    if (is_open) {
        with (obj_EditorMenuButton) {
            if (id != other.id) {
                is_open = false;
            }
        }
    }
} 
// Check if clicking on menu item
else if (is_open && hovered_item_index >= 0) {
    var item = menu_items[hovered_item_index];
    
    if (item.type == "checkbox") {
        // Toggle checkbox
        item.checked = !item.checked;
        menu_items[hovered_item_index] = item;
        
        // Notify observers
        gamestate_notify_observers(EVENT_EDITOR_MENU_ITEM_CLICKED, {
            menu_id: menu_id,
            item_id: item.id,
            item_type: item.type,
            checked: item.checked
        });
    } else if (item.type == "item") {
        // Regular menu item clicked
        is_open = false;
        
        // Notify observers
        gamestate_notify_observers(EVENT_EDITOR_MENU_ITEM_CLICKED, {
            menu_id: menu_id,
            item_id: item.id,
            item_type: item.type
        });
    }
}