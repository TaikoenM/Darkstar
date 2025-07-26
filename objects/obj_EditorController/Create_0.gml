// --- VIEWPORT AND CAMERA SETUP ---
// This is the crucial step to ensure the camera system is active.
view_enabled = true;        // Master switch to enable viewports for the room
view_visible[0] = true;     // Make Viewport 0 visible on the screen

// Assign the default camera (view_camera[0]) to Viewport 0.
// This links our camera data to the screen area.
view_set_camera(0, view_camera[0]);

// Set the on-screen size of the viewport to fill the entire window.
// This makes the game view take up the whole screen.
view_set_wport(0, display_get_gui_width());
view_set_hport(0, display_get_gui_height());
// --- END VIEWPORT SETUP ---


// Initialize the editor's data structures
editor_init();

// Calculate map dimensions and resize room
var meta = global.editor_state.planet_data.metadata;
var map_end_pos = editor_hex_axial_to_pixel(meta.size_x, meta.size_y);
room_width = map_end_pos.x + 200;
room_height = map_end_pos.y + 200;

logger_write(LogLevel.INFO, "EditorController", "Resized editor room", "w: " + string(room_width) + " h: " + string(room_height));

// Create the camera controller object
instance_create_layer(0, 0, "Instances", obj_EditorCamera);

// Ensure necessary layers exist
if (!layer_exists("Instances")) {
    layer_create(0, "Instances");
}

// Create the entire hex grid at once, now that the room is large enough
editor_create_full_hex_grid();