/// @function editor_get_view_bounds()
/// @description Get the visible view bounds
/// @return {Struct} Struct with left, top, right, bottom
function editor_get_view_bounds() {
    var cam = view_camera[0];
    return {
        left: camera_get_view_x(cam),
        top: camera_get_view_y(cam),
        right: camera_get_view_x(cam) + camera_get_view_width(cam),
        bottom: camera_get_view_y(cam) + camera_get_view_height(cam)
    };
}

/// @function editor_hex_is_visible(q, r)
/// @description Check if a hex is visible in the current view
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
/// @return {Bool} True if visible
function editor_hex_is_visible(q, r) {
    var pos = hex_axial_to_pixel(q, r);
    var bounds = editor_get_view_bounds();
    
    // Add some margin for hex size
    var margin = DEFAULT_HEX_SIZE;
    
    return pos.x >= bounds.left - margin && 
           pos.x <= bounds.right + margin &&
           pos.y >= bounds.top - margin && 
           pos.y <= bounds.bottom + margin;
}

/// @function editor_mark_all_dirty()
/// @description Mark all hexes as needing update
function editor_mark_all_dirty() {
    // TODO: Implement proper dirty tracking
    editor_update_hex_instances();
}/// @function draw_text_outline(x, y, text, text_color, outline_color)
/// @description Draw text with an outline
/// @param {Real} x X position
/// @param {Real} y Y position
/// @param {String} text Text to draw
/// @param {Constant.Color} text_color Text color
/// @param {Constant.Color} outline_color Outline color
function draw_text_outline(x, y, text, text_color, outline_color) {
    // Draw outline
    draw_set_color(outline_color);
    draw_text(x - 1, y - 1, text);
    draw_text(x + 1, y - 1, text);
    draw_text(x - 1, y + 1, text);
    draw_text(x + 1, y + 1, text);
    draw_text(x - 1, y, text);
    draw_text(x + 1, y, text);
    draw_text(x, y - 1, text);
    draw_text(x, y + 1, text);
    
    // Draw text
    draw_set_color(text_color);
    draw_text(x, y, text);
}

/// @function draw_line_width(x1, y1, x2, y2, width)
/// @description Draw a line with specified width
/// @param {Real} x1 Start X
/// @param {Real} y1 Start Y
/// @param {Real} x2 End X
/// @param {Real} y2 End Y
/// @param {Real} width Line width
function draw_line_width(x1, y1, x2, y2, width) {
    draw_line_width_colour(x1, y1, x2, y2, width, draw_get_color(), draw_get_color());
}/// @function editor_undo()
/// @description Undo the last editor command
function editor_undo() {
    if (global.editor_state.history_index >= 0) {
        var cmd = global.editor_state.command_history[| global.editor_state.history_index];
        cmd.undo(global.editor_state);
        global.editor_state.history_index--;
        show_debug_message("Undo: " + cmd.type);
    }
}

/// @function editor_redo()
/// @description Redo the next editor command
function editor_redo() {
    if (global.editor_state.history_index < ds_list_size(global.editor_state.command_history) - 1) {
        global.editor_state.history_index++;
        var cmd = global.editor_state.command_history[| global.editor_state.history_index];
        cmd.execute(global.editor_state);
        show_debug_message("Redo: " + cmd.type);
    }
}/// @function editor_pipette_from_hex(q, r)
/// @description Use pipette tool to copy hex properties
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
function editor_pipette_from_hex(q, r) {
    var hex_data = editor_get_hex_data(q, r);
    
    if (!is_undefined(hex_data)) {
        // Copy the terrain type to current selection
        global.editor_state.selected_terrain = hex_data.terrain_type;
        
        // If a quick slot is targeted, fill it
        if (global.editor_state.pipette_target_slot >= 0) {
            global.editor_state.quick_slots[global.editor_state.pipette_target_slot] = {
                type: "terrain",
                terrain_type: hex_data.terrain_type,
                preview_sprite: spr_hex_terrain_plains, // TODO: Get actual sprite
                preview_color: c_white
            };
            global.editor_state.pipette_target_slot = -1;
        }
        
        show_debug_message("Pipetted terrain: " + hex_data.terrain_type);
    }
}

/// @function editor_activate_quick_slot(slot_index)
/// @description Activate a quick slot
/// @param {Real} slot_index The slot to activate (0-11)
function editor_activate_quick_slot(slot_index) {
    if (slot_index >= 0 && slot_index < 12) {
        global.editor_state.active_slot = slot_index;
        
        var slot_data = global.editor_state.quick_slots[slot_index];
        if (!is_undefined(slot_data)) {
            // Apply slot data to current selection
            switch (slot_data.type) {
                case "terrain":
                    global.editor_state.selected_terrain = slot_data.terrain_type;
                    global.editor_state.current_tool = "paint_terrain";
                    break;
                case "feature":
                    global.editor_state.selected_feature = slot_data.feature_type;
                    global.editor_state.current_tool = "paint_feature";
                    break;
                case "building":
                    global.editor_state.selected_building = slot_data.building_type;
                    global.editor_state.current_tool = "place_building";
                    break;
                case "unit":
                    global.editor_state.selected_unit = slot_data.unit_type;
                    global.editor_state.current_tool = "place_unit";
                    break;
            }
        }
        
        show_debug_message("Activated quick slot: " + string(slot_index));
    }
}/// @function editor_zoom_in()
/// @description Zoom the editor camera in
function editor_zoom_in() {
    var cam = global.editor_state.camera;
    var current_index = 0;
    
    // Find current zoom level
    for (var i = 0; i < array_length(cam.zoom_levels); i++) {
        if (abs(cam.zoom_target - cam.zoom_levels[i]) < 0.01) {
            current_index = i;
            break;
        }
    }
    
    // Increase zoom
    if (current_index < array_length(cam.zoom_levels) - 1) {
        cam.zoom_target = cam.zoom_levels[current_index + 1];
    }
}

/// @function editor_zoom_out()
/// @description Zoom the editor camera out
function editor_zoom_out() {
    var cam = global.editor_state.camera;
    var current_index = array_length(cam.zoom_levels) - 1;
    
    // Find current zoom level
    for (var i = 0; i < array_length(cam.zoom_levels); i++) {
        if (abs(cam.zoom_target - cam.zoom_levels[i]) < 0.01) {
            current_index = i;
            break;
        }
    }
    
    // Decrease zoom
    if (current_index > 0) {
        cam.zoom_target = cam.zoom_levels[current_index - 1];
    }
}/// @function editor_get_slot_key_name(slot_index)
/// @description Get the display name for a quick slot key
/// @param {Real} slot_index The slot index (0-11)
/// @return {String} The key name to display
function editor_get_slot_key_name(slot_index) {
    switch (slot_index) {
        case 0: return "1";
        case 1: return "2";
        case 2: return "3";
        case 3: return "4";
        case 4: return "5";
        case 5: return "6";
        case 6: return "7";
        case 7: return "8";
        case 8: return "9";
        case 9: return "0";
        case 10: return "-";
        case 11: return "=";
        default: return "?";
    }
}

/// @function editor_get_quick_slot_key(slot_index)
/// @description Get the keyboard key for a quick slot
/// @param {Real} slot_index The slot index (0-11)
/// @return {Real} The keyboard key constant
function editor_get_quick_slot_key(slot_index) {
    switch (slot_index) {
        case 0: return ord("1");
        case 1: return ord("2");
        case 2: return ord("3");
        case 3: return ord("4");
        case 4: return ord("5");
        case 5: return ord("6");
        case 6: return ord("7");
        case 7: return ord("8");
        case 8: return ord("9");
        case 9: return ord("0");
        case 10: return vk_subtract;
        case 11: return vk_add;
        default: return -1;
    }
}/// @function editor_get_hex_data(q, r)
/// @description Get hex data for given coordinates
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
/// @return {Struct|Undefined} Hex data or undefined if not found
function editor_get_hex_data(q, r) {
    var hex_key = string(q) + "," + string(r);
    return global.editor_state.planet_data.hexes[? hex_key];
}

/// @function editor_set_hex_terrain(q, r, terrain_type)
/// @description Set terrain type for a hex
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
/// @param {String} terrain_type The terrain type to set
function editor_set_hex_terrain(q, r, terrain_type) {
    var hex_key = string(q) + "," + string(r);
    var hex_data = global.editor_state.planet_data.hexes[? hex_key];
    
    if (is_undefined(hex_data)) {
        // Create new hex data
        hex_data = {
            terrain_type: terrain_type,
            feature: "none",
            resource: "none",
            faction_owner: 0,
            building_id: -1,
            unit_ids: []
        };
        global.editor_state.planet_data.hexes[? hex_key] = hex_data;
    } else {
        // Update existing hex
        hex_data.terrain_type = terrain_type;
    }
    
    // Mark hex as dirty for redraw
    editor_mark_hex_dirty(q, r);
}

/// @function editor_mark_hex_dirty(q, r)
/// @description Mark a hex as needing redraw
/// @param {Real} q Hex Q coordinate
/// @param {Real} r Hex R coordinate
function editor_mark_hex_dirty(q, r) {
    // TODO: Implement dirty region tracking
    // For now, just update all hex instances
    editor_update_hex_instances();
}/// @function ds_map_keys_to_array(map)
/// @description Convert all keys from a ds_map to an array
/// @param {Id.DsMap} map The map to get keys from
/// @return {Array<String>} Array of all keys
function ds_map_keys_to_array(map) {
    var keys = [];
    var key = ds_map_find_first(map);
    
    while (!is_undefined(key)) {
        array_push(keys, key);
        key = ds_map_find_next(map, key);
    }
    
    return keys;
}

/// @function point_in_rectangle(px, py, x1, y1, x2, y2)
/// @description Check if a point is inside a rectangle
/// @param {Real} px Point X coordinate
/// @param {Real} py Point Y coordinate
/// @param {Real} x1 Rectangle left
/// @param {Real} y1 Rectangle top
/// @param {Real} x2 Rectangle right
/// @param {Real} y2 Rectangle bottom
/// @return {Bool} True if point is inside rectangle
function point_in_rectangle(px, py, x1, y1, x2, y2) {
    return px >= x1 && px <= x2 && py >= y1 && py <= y2;
}

/// @function editor_update_hex_instances()
/// @description Update visible hex instances (placeholder)
function editor_update_hex_instances() {
    // TODO: Implement hex instance management
    show_debug_message("Hex instance update called");
}

/// @function editor_mark_view_dirty()
/// @description Mark the view as needing update
function editor_mark_view_dirty() {
    // TODO: Implement dirty region tracking
}

/// @function editor_create_command_clear_all_buildings()
/// @description Create command to clear all buildings
function editor_create_command_clear_all_buildings() {
    // TODO: Implement clear buildings command
    return {
        type: "clear_all_buildings",
        execute: function(state) {
            ds_map_clear(state.planet_data.buildings);
            // Also clear building references from hexes
            var keys = ds_map_keys_to_array(state.planet_data.hexes);
            for (var i = 0; i < array_length(keys); i++) {
                var hex_data = state.planet_data.hexes[? keys[i]];
                if (!is_undefined(hex_data)) {
                    hex_data.building_id = -1;
                }
            }
        },
        undo: function(state) {
            // TODO: Store and restore building data
        }
    };
}

/// @function editor_create_command_clear_all_resources()
/// @description Create command to clear all resources
function editor_create_command_clear_all_resources() {
    // TODO: Implement clear resources command
    return {
        type: "clear_all_resources",
        execute: function(state) {
            var keys = ds_map_keys_to_array(state.planet_data.hexes);
            for (var i = 0; i < array_length(keys); i++) {
                var hex_data = state.planet_data.hexes[? keys[i]];
                if (!is_undefined(hex_data)) {
                    hex_data.resource = "none";
                }
            }
        },
        undo: function(state) {
            // TODO: Store and restore resource data
        }
    };
}

/// @function editor_create_command_clear_all_units()
/// @description Create command to clear all units
function editor_create_command_clear_all_units() {
    // TODO: Implement clear units command
    return {
        type: "clear_all_units",
        execute: function(state) {
            ds_map_clear(state.planet_data.units);
            ds_map_clear(state.planet_data.unit_stacks);
            // Also clear unit references from hexes
            var keys = ds_map_keys_to_array(state.planet_data.hexes);
            for (var i = 0; i < array_length(keys); i++) {
                var hex_data = state.planet_data.hexes[? keys[i]];
                if (!is_undefined(hex_data)) {
                    hex_data.unit_ids = [];
                }
            }
        },
        undo: function(state) {
            // TODO: Store and restore unit data
        }
    };
}

/// @function editor_execute_command(cmd)
/// @description Execute an editor command (placeholder)
function editor_execute_command(cmd) {
    // Execute the command
    cmd.execute(global.editor_state);
    
    // TODO: Add to history for undo/redo
    
    // Notify observers
    gamestate_notify_observers(EVENT_EDITOR_PLANET_MODIFIED, {
        command_type: cmd.type
    });
}

/// @function editor_save_planet(filename)
/// @description Save planet to file (placeholder)
/// @param {String} filename Path to save file
/// @return {Bool} Success
function editor_save_planet(filename) {
    // TODO: Implement actual save functionality
    show_debug_message("Would save to: " + filename);
    return true;
}