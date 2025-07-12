/// @description Handle unit orders
if (selected) {
    // Get hex coordinates of click
    var hex_coords = hex_pixel_to_axial(mouse_x, mouse_y);
    
    gamestate_notify_observers(EVENT_UNIT_ORDER_ISSUED, {
        unit_id: unit_id,
        order_type: "move",
        target_q: hex_coords.q,
        target_r: hex_coords.r,
        mouse_x: mouse_x,
        mouse_y: mouse_y
    });
}