/// @description Initialize camera

// Initialize camera to planet center
var meta = global.editor_state.planet_data.metadata;
var center_hex = hex_axial_to_pixel(meta.size_x / 2, meta.size_y / 2);

global.editor_state.camera.x = center_hex.x;
global.editor_state.camera.y = center_hex.y;

// Track previous mouse position for panning
mouse_previous_x = mouse_x;
mouse_previous_y = mouse_y;

    // Apply camera settings
    camera_set_view_pos(view_camera[0],
        global.editor_state.camera.x - view_wport[0] / (2 * global.editor_state.camera.zoom_level),
        global.editor_state.camera.y - view_hport[0] / (2 * global.editor_state.camera.zoom_level)
    );
    
    camera_set_view_size(view_camera[0],
        view_wport[0] / global.editor_state.camera.zoom_level,
        view_hport[0] / global.editor_state.camera.zoom_level
    );
    
    // Update previous mouse position
    mouse_previous_x = mouse_x;
    mouse_previous_y = mouse_y;