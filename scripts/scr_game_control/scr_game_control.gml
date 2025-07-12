/// @function game_controller_handle_unit_click(event_data)
/// @description Handle unit selection events
/// @param {struct} event_data Contains unit_id, modifiers
function game_controller_handle_unit_click(event_data) {
    var unit_id = event_data.unit_id;
    var shift_held = event_data.shift_held;
    var ctrl_held = event_data.ctrl_held;
    
    // Create appropriate command based on modifiers
    var cmd_type = CommandType.SELECT_UNIT;
    var cmd_data = { unit_id: unit_id };
    
    if (shift_held) {
        cmd_type = CommandType.ADD_TO_SELECTION;
    } else if (ctrl_held) {
        cmd_type = CommandType.TOGGLE_SELECTION;
    }
    
    // Queue command for processing
    var cmd = input_create_command(cmd_type, cmd_data);
    input_queue_command(cmd);
}

/// @function game_controller_handle_unit_order(event_data)  
/// @description Handle unit order events
/// @param {struct} event_data Contains unit_id, order_type, target coordinates
function game_controller_handle_unit_order(event_data) {
    var cmd = input_create_command(CommandType.UNIT_ORDER, {
        unit_id: event_data.unit_id,
        order_type: event_data.order_type,
        target_q: event_data.target_q,
        target_r: event_data.target_r
    });
    
    input_queue_command(cmd);
}

/// @function game_controller_handle_hex_click(event_data)
/// @description Handle hex tile interactions
/// @param {struct} event_data Contains hex coordinates, mouse button
function game_controller_handle_hex_click(event_data) {
    // Determine action based on current state and click type
    var current_state = gamestate_get();
    
    if (current_state == GameState.MAP_EDITOR) {
        var cmd = input_create_command(CommandType.EDITOR_PLACE, {
            q: event_data.q,
            r: event_data.r,
            tile_type: global.editor_selected_tile
        });
        input_queue_command(cmd);
    }
}

/// @function hex_pixel_to_axial(px, py)
/// @description Convert pixel coordinates to axial hex coordinates
/// @param {real} px X position in pixels
/// @param {real} py Y position in pixels
/// @return {struct} Struct with q and r axial coordinates
function hex_pixel_to_axial(px, py) {
    // TODO: Implement hex coordinate conversion
    // This is a placeholder - will be implemented in scr_hex_utils
    return { q: 0, r: 0 };
}