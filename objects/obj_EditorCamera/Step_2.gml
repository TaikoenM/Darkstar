// Apply camera transformations to the view
var cam_struct = global.editor_state.camera;
var view_w = display_get_gui_width();
var view_h = display_get_gui_height();

var target_width = view_w / cam_struct.zoom_level;
var target_height = view_h / cam_struct.zoom_level;

// This updates the data for view_camera[0]
camera_set_view_pos(view_camera[0], cam_struct.x - target_width / 2, cam_struct.y - target_height / 2);
camera_set_view_size(view_camera[0], target_width, target_height);