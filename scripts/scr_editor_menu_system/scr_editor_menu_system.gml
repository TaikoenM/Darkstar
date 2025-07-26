/// @description Editor menu system functions

/// @function editor_menu_get_dropdown_height()
/// @description Calculate total height of dropdown menu
function editor_menu_get_dropdown_height() {
    var height = 0;
    
    for (var i = 0; i < array_length(menu_items); i++) {
        var item = menu_items[i];
        if (item.type == "separator") {
            height += separator_height;
        } else {
            height += item_height;
        }
    }
    
    return height;
}

/// @function editor_create_planet_menu()
/// @description Create the Planet menu
function editor_create_planet_menu() {
    var menu = instance_create_layer(0, 0, "UI", obj_EditorMenuButton);
    menu.menu_id = "planet_menu";
    menu.menu_text = "Planet";
    menu.gui_x = 10;
    menu.gui_y = 10;
    
    menu.menu_items = [
        {type: "item", id: "new_blank_planet", text: "New Blank Planet...", enabled: true},
        {type: "item", id: "new_random_planet", text: "New Random Planet...", enabled: true},
        {type: "separator"},
        {type: "item", id: "change_size", text: "Change Size...", enabled: true},
        {type: "item", id: "edit_properties", text: "Edit Properties...", enabled: true},
        {type: "separator"},
        {type: "item", id: "save_planet", text: "Save Planet", enabled: true, shortcut: "Ctrl+S"},
        {type: "item", id: "save_planet_as", text: "Save Planet As...", enabled: true},
        {type: "separator"},
        {type: "item", id: "clear_buildings", text: "Clear All Buildings", enabled: true},
        {type: "item", id: "clear_resources", text: "Clear All Resources", enabled: true},
        {type: "item", id: "clear_units", text: "Clear All Units", enabled: true},
        {type: "separator"},
        {type: "item", id: "export_json", text: "Export to JSON", enabled: true},
        {type: "item", id: "import_json", text: "Import from JSON", enabled: true}
    ];
    
    return menu;
}

/// @function editor_create_view_menu()
/// @description Create the View menu
function editor_create_view_menu() {
    var menu = instance_create_layer(0, 0, "UI", obj_EditorMenuButton);
    menu.menu_id = "view_menu";
    menu.menu_text = "View";
    menu.gui_x = 140;
    menu.gui_y = 10;
    
    menu.menu_items = [
        {type: "checkbox", id: "show_grid", text: "Show Grid", enabled: true, checked: true},
        {type: "checkbox", id: "show_coordinates", text: "Show Hex Coordinates", enabled: true, checked: false},
        {type: "checkbox", id: "show_resources", text: "Show Resources", enabled: true, checked: true},
        {type: "checkbox", id: "show_features", text: "Show Terrain Features", enabled: true, checked: true},
        {type: "checkbox", id: "show_buildings", text: "Show Buildings", enabled: true, checked: true},
        {type: "checkbox", id: "show_units", text: "Show Units", enabled: true, checked: true},
        {type: "checkbox", id: "show_faction_borders", text: "Show Faction Borders", enabled: true, checked: false}
    ];
    
    // Sync checkbox states with editor view flags
    for (var i = 0; i < array_length(menu.menu_items); i++) {
        var item = menu.menu_items[i];
        if (item.type == "checkbox") {
            switch (item.id) {
                case "show_grid":
                    item.checked = global.editor_state.view_flags.show_grid;
                    break;
                case "show_coordinates":
                    item.checked = global.editor_state.view_flags.show_coordinates;
                    break;
                case "show_resources":
                    item.checked = global.editor_state.view_flags.show_resources;
                    break;
                case "show_features":
                    item.checked = global.editor_state.view_flags.show_features;
                    break;
                case "show_buildings":
                    item.checked = global.editor_state.view_flags.show_buildings;
                    break;
                case "show_units":
                    item.checked = global.editor_state.view_flags.show_units;
                    break;
                case "show_faction_borders":
                    item.checked = global.editor_state.view_flags.show_faction_borders;
                    break;
            }
            menu.menu_items[i] = item;
        }
    }
    
    return menu;
}

/// @function editor_handle_menu_click(event_data)
/// @description Handle menu item clicks
function editor_handle_menu_click(event_data) {
    var menu_id = event_data.menu_id;
    var item_id = event_data.item_id;
    
    switch (menu_id) {
        case "planet_menu":
            editor_handle_planet_menu_item(item_id);
            break;
            
        case "view_menu":
            editor_handle_view_menu_item(item_id, event_data);
            break;
    }
}

/// @function editor_handle_planet_menu_item(item_id)
/// @description Handle Planet menu selections
function editor_handle_planet_menu_item(item_id) {
    switch (item_id) {
        case "new_blank_planet":
            editor_show_new_planet_dialog();
            break;
            
        case "new_random_planet":
            editor_show_random_planet_dialog();
            break;
            
        case "change_size":
            editor_show_resize_dialog();
            break;
            
        case "edit_properties":
            editor_show_properties_dialog();
            break;
            
        case "save_planet":
            editor_save_current();
            break;
            
        case "save_planet_as":
            editor_show_save_as_dialog();
            break;
            
        case "clear_buildings":
            editor_confirm_clear_buildings();
            break;
            
        case "clear_resources":
            editor_confirm_clear_resources();
            break;
            
        case "clear_units":
            editor_confirm_clear_units();
            break;
            
        case "export_json":
            editor_export_to_json();
            break;
            
        case "import_json":
            editor_import_from_json();
            break;
    }
}

/// @function editor_handle_view_menu_item(item_id, event_data)
/// @description Handle View menu selections
function editor_handle_view_menu_item(item_id, event_data) {
    if (event_data.item_type == "checkbox") {
        var checked = event_data.checked;
        
        switch (item_id) {
            case "show_grid":
                global.editor_state.view_flags.show_grid = checked;
                break;
                
            case "show_coordinates":
                global.editor_state.view_flags.show_coordinates = checked;
                break;
                
            case "show_resources":
                global.editor_state.view_flags.show_resources = checked;
                break;
                
            case "show_features":
                global.editor_state.view_flags.show_features = checked;
                break;
                
            case "show_buildings":
                global.editor_state.view_flags.show_buildings = checked;
                break;
                
            case "show_units":
                global.editor_state.view_flags.show_units = checked;
                break;
                
            case "show_faction_borders":
                global.editor_state.view_flags.show_faction_borders = checked;
                break;
        }
        
        // Notify that view has changed
        gamestate_notify_observers(EVENT_EDITOR_VIEW_FLAGS_CHANGED, {
            flag: item_id,
            value: checked
        });
    }
}