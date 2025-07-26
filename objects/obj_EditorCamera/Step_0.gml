var cam_struct = global.editor_state.camera;

// --- ZOOM LOGIC ---
if (mouse_wheel_up()) {
    if (cam_struct.current_zoom_index > 0) {
        cam_struct.current_zoom_index--;
        cam_struct.zoom_target = cam_struct.zoom_levels[cam_struct.current_zoom_index];
    }
} else if (mouse_wheel_down()) {
    if (cam_struct.current_zoom_index < array_length(cam_struct.zoom_levels) - 1) {
        cam_struct.current_zoom_index++;
        cam_struct.zoom_target = cam_struct.zoom_levels[cam_struct.current_zoom_index];
    }
}
cam_struct.zoom_level = lerp(cam_struct.zoom_level, cam_struct.zoom_target, 0.15);

// --- PANNING LOGIC (Middle Mouse) ---
if (mouse_check_button_pressed(mb_middle)) {
    cam_struct.is_panning = true;
    cam_struct.pan_last_gui_x = device_mouse_x_to_gui(0);
    cam_struct.pan_last_gui_y = device_mouse_y_to_gui(0);
}
if (mouse_check_button_released(mb_middle)) {
    cam_struct.is_panning = false;
}
if (cam_struct.is_panning) {
    var current_gui_x = device_mouse_x_to_gui(0);
    var current_gui_y = device_mouse_y_to_gui(0);
    var dx = current_gui_x - cam_struct.pan_last_gui_x;
    var dy = current_gui_y - cam_struct.pan_last_gui_y;
    cam_struct.x -= dx / cam_struct.zoom_level;
    cam_struct.y -= dy / cam_struct.zoom_level;
    cam_struct.pan_last_gui_x = current_gui_x;
    cam_struct.pan_last_gui_y = current_gui_y;
}

// --- NEW: WSAD KEYBOARD MOVEMENT ---
var scroll_speed = 20 / cam_struct.zoom_level;
if (keyboard_check(ord("A"))) {
    cam_struct.x -= scroll_speed;
}
if (keyboard_check(ord("D"))) {
    cam_struct.x += scroll_speed;
}
if (keyboard_check(ord("W"))) {
    cam_struct.y -= scroll_speed;
}
if (keyboard_check(ord("S"))) {
    cam_struct.y += scroll_speed;
}

// --- VERTICAL BOUNDING/CLAMPING LOGIC ---
var view_h_half = camera_get_view_height(view_camera[0]) / 2;
var buffer = 100;
if (cam_struct.y - view_h_half < -buffer) {
    cam_struct.y = -buffer + view_h_half;
}
if (cam_struct.y + view_h_half > room_height + buffer) {
    cam_struct.y = (room_height + buffer) - view_h_half;
}

// --- WRAPPING LOGIC ---
var meta = global.editor_state.planet_data.metadata;
if (meta.wraps_horizontal) {
    var hex_height = EDITOR_HEX_HEIGHT;
    var hex_width = (2 / sqrt(3)) * hex_height;
    var map_pixel_width = meta.size_x * hex_width;
    
    if (cam_struct.x < 0) cam_struct.x += map_pixel_width;
    if (cam_struct.x >= map_pixel_width) cam_struct.x -= map_pixel_width;
}