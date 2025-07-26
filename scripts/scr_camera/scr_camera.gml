/// @function editor_hex_axial_to_pixel(q, r)
/// @description CORRECTED: Converts axial hex coordinates to pixel coordinates for a vertically-stacked FLAT-TOP grid.
function editor_hex_axial_to_pixel(q, r) {
    var hex_height = EDITOR_HEX_HEIGHT;
    var hex_width = hex_height * (2 / sqrt(3)); // Full width from point to point

    var horizontal_spacing = hex_width * 0.75;

    var pixel_x = horizontal_spacing * q;
    var pixel_y = hex_height * r;

    // Offset every other COLUMN down by half a hex height to interlock them
    if (abs(q) % 2 == 1) {
        pixel_y += hex_height / 2;
    }

    return { x: pixel_x, y: pixel_y };
}

/// @function editor_pixel_to_axial(px, py)
/// @description CORRECTED: Converts pixel coordinates to the nearest axial hex coordinate for a vertically-stacked FLAT-TOP grid.
function editor_pixel_to_axial(px, py) {
    var hex_height = EDITOR_HEX_HEIGHT;
    var hex_width = hex_height * (2 / sqrt(3));
    var horizontal_spacing = hex_width * 0.75;

    // Approximate q first, as it determines the y-offset
    var q = round(px / horizontal_spacing);

    // De-apply the vertical offset based on the determined column
    var y_adjusted = py;
    if (abs(q) % 2 == 1) {
        y_adjusted -= hex_height / 2;
    }
    
    var r = round(y_adjusted / hex_height);

    return { q: q, r: r };
}


/// @function editor_camera_init()
/// @description Initializes the editor camera state.
function editor_camera_init() {
    var meta = global.editor_state.planet_data.metadata;
    var pos_center = editor_hex_axial_to_pixel(meta.size_x / 2, meta.size_y / 2);

    global.editor_state.camera = {
        x: pos_center.x,
        y: pos_center.y,
        pan_last_gui_x: 0,
        pan_last_gui_y: 0,
        is_panning: false,
        zoom_level: 1.0,
        zoom_target: 1.0,
        zoom_levels: [0.25, 0.5, 0.75, 1.0, 1.5, 2.0],
        current_zoom_index: 3
    };
}