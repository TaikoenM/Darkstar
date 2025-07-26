/// @function editor_create_command_place_building(q, r, building_type, faction)
/// @description Create a command to place a building
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
/// @param {String} building_type The building type to place
/// @param {Real} faction The faction owner
/// @return {Struct} Command object
function editor_create_command_place_building(q, r, building_type, faction) {
    var hex_data = editor_get_hex_data(q, r);
    var old_building_id = is_undefined(hex_data) ? -1 : hex_data.building_id;
    
    return {
        type: "place_building",
        data: {
            q: q,
            r: r,
            building_type: building_type,
            faction: faction,
            old_building_id: old_building_id,
            new_building_id: -1 // Will be set during execute
        },
        
        execute: function(state) {
            // TODO: Create building instance and get its ID
            var building_id = current_time; // Placeholder ID
            data.new_building_id = building_id;
            
            // Add to buildings map
            state.planet_data.buildings[? building_id] = {
                id: building_id,
                type: data.building_type,
                faction: data.faction,
                q: data.q,
                r: data.r
            };
            
            // Update hex data
            var hex_key = string(data.q) + "," + string(data.r);
            var hex_data = state.planet_data.hexes[? hex_key];
            if (!is_undefined(hex_data)) {
                hex_data.building_id = building_id;
            }
            
            editor_mark_hex_dirty(data.q, data.r);
        },
        
        undo: function(state) {
            // Remove building
            ds_map_delete(state.planet_data.buildings, data.new_building_id);
            
            // Restore hex data
            var hex_key = string(data.q) + "," + string(data.r);
            var hex_data = state.planet_data.hexes[? hex_key];
            if (!is_undefined(hex_data)) {
                hex_data.building_id = data.old_building_id;
            }
            
            editor_mark_hex_dirty(data.q, data.r);
        }
    };
}

/// @function editor_can_place_building(q, r, building_type)
/// @description Check if a building can be placed at given hex
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
/// @param {String} building_type The building type to check
/// @return {Bool} True if placement is valid
function editor_can_place_building(q, r, building_type) {
    var hex_data = editor_get_hex_data(q, r);
    
    if (is_undefined(hex_data)) {
        return true; // Can place on empty hex
    }
    
    // Check if hex already has a building
    if (hex_data.building_id != -1) {
        return false;
    }
    
    // TODO: Add more placement rules based on building type
    // e.g., cities can't be placed on water, etc.
    
    return true;
}

/// @function editor_create_command_erase_hex(q, r)
/// @description Create a command to erase hex contents
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
/// @return {Struct} Command object
function editor_create_command_erase_hex(q, r) {
    var hex_data = editor_get_hex_data(q, r);
    var old_data = is_undefined(hex_data) ? undefined : {
        terrain_type: hex_data.terrain_type,
        feature: hex_data.feature,
        resource: hex_data.resource,
        faction_owner: hex_data.faction_owner,
        building_id: hex_data.building_id,
        unit_ids: array_create(array_length(hex_data.unit_ids))
    };
    
    // Deep copy unit IDs
    if (!is_undefined(old_data)) {
        array_copy(old_data.unit_ids, 0, hex_data.unit_ids, 0, array_length(hex_data.unit_ids));
    }
    
    return {
        type: "erase_hex",
        data: {
            q: q,
            r: r,
            old_data: old_data
        },
        
        execute: function(state) {
            var hex_key = string(data.q) + "," + string(data.r);
            
            // Remove any buildings
            var hex_data = state.planet_data.hexes[? hex_key];
            if (!is_undefined(hex_data) && hex_data.building_id != -1) {
                ds_map_delete(state.planet_data.buildings, hex_data.building_id);
            }
            
            // Remove hex data entirely
            ds_map_delete(state.planet_data.hexes, hex_key);
            
            editor_mark_hex_dirty(data.q, data.r);
        },
        
        undo: function(state) {
            if (!is_undefined(data.old_data)) {
                var hex_key = string(data.q) + "," + string(data.r);
                state.planet_data.hexes[? hex_key] = data.old_data;
                
                // Restore building if it existed
                if (data.old_data.building_id != -1) {
                    // TODO: Restore building data
                }
                
                editor_mark_hex_dirty(data.q, data.r);
            }
        }
    };
}/// @function editor_create_command_paint_terrain(hexes, terrain_type)
/// @description Create a command to paint terrain
/// @param {Array<Struct>} hexes Array of hex coordinates {q, r}
/// @param {String} terrain_type The terrain type to paint
/// @return {Struct} Command object
function editor_create_command_paint_terrain(hexes, terrain_type) {
    var old_values = [];
    for (var i = 0; i < array_length(hexes); i++) {
        var hex = hexes[i];
        var hex_data = editor_get_hex_data(hex.q, hex.r);
        array_push(old_values, is_undefined(hex_data) ? "plains" : hex_data.terrain_type);
    }
    
    return {
        type: "paint_terrain",
        timestamp: current_time,
        data: {
            hexes: hexes,
            old_values: old_values,
            new_value: terrain_type
        },
        
        execute: function(state) {
            for (var i = 0; i < array_length(data.hexes); i++) {
                var hex = data.hexes[i];
                editor_set_hex_terrain(hex.q, hex.r, data.new_value);
            }
        },
        
        undo: function(state) {
            for (var i = 0; i < array_length(data.hexes); i++) {
                var hex = data.hexes[i];
                editor_set_hex_terrain(hex.q, hex.r, data.old_values[i]);
            }
        },
        
        can_merge: function(other) {
            // Can merge with another paint command if recent
            return other.type == "paint_terrain" && 
                   other.data.new_value == data.new_value &&
                   (other.timestamp - timestamp) < 500;
        }
    };
}/// @description Editor menu action handlers

/// @function editor_show_new_planet_dialog()
/// @description Show dialog for creating a new blank planet
function editor_show_new_planet_dialog() {
    // TODO: Implement dialog system
    // For now, create a default new planet
    if (editor_has_unsaved_changes()) {
        // TODO: Show save confirmation
        show_debug_message("Unsaved changes would be lost!");
    }
    
    editor_new_planet(50, 30);
    show_debug_message("Created new 50x30 planet");
}

/// @function editor_show_random_planet_dialog()
/// @description Show dialog for generating a random planet
function editor_show_random_planet_dialog() {
    // TODO: Implement random generation dialog
    show_debug_message("Random planet generation not yet implemented");
}

/// @function editor_show_resize_dialog()
/// @description Show dialog for changing planet size
function editor_show_resize_dialog() {
    // TODO: Implement resize dialog
    show_debug_message("Resize dialog not yet implemented");
}

/// @function editor_show_properties_dialog()
/// @description Show planet properties editor
function editor_show_properties_dialog() {
    // TODO: Implement properties dialog
    show_debug_message("Properties dialog not yet implemented");
}

/// @function editor_save_current()
/// @description Save the current planet
function editor_save_current() {
    var filename = global.editor_state.planet_data.metadata.filename;
    if (filename == "untitled.planet" || filename == "") {
        editor_show_save_as_dialog();
    } else {
        if (editor_save_planet(filename)) {
            show_debug_message("Planet saved to: " + filename);
            editor_mark_saved();
        } else {
            show_debug_message("Failed to save planet!");
        }
    }
}

/// @function editor_show_save_as_dialog()
/// @description Show save as dialog
function editor_show_save_as_dialog() {
    // TODO: Implement proper file dialog
    var filename = get_save_filename("Planet files|*.planet", global.editor_state.planet_data.metadata.filename);
    if (filename != "") {
        if (editor_save_planet(filename)) {
            show_debug_message("Planet saved to: " + filename);
            editor_mark_saved();
        }
    }
}

/// @function editor_confirm_clear_buildings()
/// @description Confirm and clear all buildings
function editor_confirm_clear_buildings() {
    // TODO: Implement confirmation dialog
    if (show_question("Clear all buildings from the planet?")) {
        var cmd = editor_create_command_clear_all_buildings();
        editor_execute_command(cmd);
        show_debug_message("All buildings cleared");
    }
}

/// @function editor_confirm_clear_resources()
/// @description Confirm and clear all resources
function editor_confirm_clear_resources() {
    // TODO: Implement confirmation dialog
    if (show_question("Clear all resources from the planet?")) {
        var cmd = editor_create_command_clear_all_resources();
        editor_execute_command(cmd);
        show_debug_message("All resources cleared");
    }
}

/// @function editor_confirm_clear_units()
/// @description Confirm and clear all units
function editor_confirm_clear_units() {
    // TODO: Implement confirmation dialog
    if (show_question("Clear all units from the planet?")) {
        var cmd = editor_create_command_clear_all_units();
        editor_execute_command(cmd);
        show_debug_message("All units cleared");
    }
}

/// @function editor_export_to_json()
/// @description Export planet to JSON file
function editor_export_to_json() {
    var filename = get_save_filename("JSON files|*.json", string_replace(global.editor_state.planet_data.metadata.filename, ".planet", ".json"));
    if (filename != "") {
        // TODO: Implement JSON export
        show_debug_message("JSON export not yet implemented");
    }
}

/// @function editor_import_from_json()
/// @description Import planet from JSON file
function editor_import_from_json() {
    var filename = get_open_filename("JSON files|*.json", "");
    if (filename != "") {
        // TODO: Implement JSON import
        show_debug_message("JSON import not yet implemented");
    }
}

/// @function editor_has_unsaved_changes()
/// @description Check if there are unsaved changes
function editor_has_unsaved_changes() {
    // Check if history has any commands since last save
    return ds_list_size(global.editor_state.command_history) > 0;
}

/// @function editor_mark_saved()
/// @description Mark the current state as saved
function editor_mark_saved() {
    // TODO: Track saved state properly
    // For now, we'll clear this flag by resetting command history marker
}

/// @function editor_new_planet(width, height)
/// @description Create a new blank planet
/// @param {Real} width Width in hexes
/// @param {Real} height Height in hexes
function editor_new_planet(width, height) {
    // Clear existing data
    ds_map_clear(global.editor_state.planet_data.hexes);
    ds_map_clear(global.editor_state.planet_data.buildings);
    ds_map_clear(global.editor_state.planet_data.units);
    ds_map_clear(global.editor_state.planet_data.unit_stacks);
    
    // Reset metadata
    global.editor_state.planet_data.metadata = {
        filename: "untitled.planet",
        name: "New Planet",
        description: "",
        icon_sprite: "spr_planet_icon_temperate",
        size_x: width,
        size_y: height,
        wraps_horizontal: true,
        global_features: {
            gravity: 1.0,
            atmosphere: "breathable",
            temperature: "temperate"
        }
    };
    
    // Clear command history
    ds_list_clear(global.editor_state.command_history);
    global.editor_state.history_index = -1;
    
    // Reset camera to center using proper hex positioning
    var center_hex = hex_axial_to_pixel(width / 2, height / 2);
    global.editor_state.camera.x = center_hex.x;
    global.editor_state.camera.y = center_hex.y;
    global.editor_state.camera.zoom_level = 1.0;
    global.editor_state.camera.zoom_target = 1.0;
    
    // Update hex instances
    editor_update_hex_instances();
    
    // Notify observers
    gamestate_notify_observers(EVENT_EDITOR_PLANET_RESET, {});
}