// DEBUG INFO OVERLAY
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Check if our debug font exists. If not, fall back to the default font.
if (font_exists(fnt_editor_small)) {
    draw_set_font(fnt_editor_small);
} else {
    draw_set_font(-1); // Use the default engine font
}

// --- GATHER DEBUG DATA ---

var cam_struct = global.editor_state.camera;

// Mouse coordinates
var mx_gui = device_mouse_x_to_gui(0);
var my_gui = device_mouse_y_to_gui(0);

// Viewport (Camera) stats
var view_cam = view_camera[0];
var view_w = camera_get_view_width(view_cam);
var view_h = camera_get_view_height(view_cam);
var view_x = camera_get_view_x(view_cam);
var view_y = camera_get_view_y(view_cam); 

// Convert mouse GUI coords to room coords for hex calculation
var mx_room = view_x + (mx_gui / display_get_gui_width()) * view_w;
var my_room = view_y + (my_gui / display_get_gui_height()) * view_h;
var mouse_hex = editor_pixel_to_axial(mx_room, my_room);

// --- ASSEMBLE DEBUG TEXT STRING ---

var debug_text = "";
debug_text += "ROOM SIZE: " + string(room_width) + " x " + string(room_height) + "\n";
debug_text += "VIEWPORT (X,Y): " + string_format(view_x, 0, 1) + ", " + string_format(view_y, 0, 1) + "\n";
debug_text += "VIEWPORT (W,H): " + string_format(view_w, 0, 1) + ", " + string_format(view_h, 0, 1) + "\n";
debug_text += "--------------------------------\n";
debug_text += "CAMERA X: " + string_format(cam_struct.x, 0, 2) + "\n";
debug_text += "CAMERA Y: " + string_format(cam_struct.y, 0, 2) + "\n";
debug_text += "ZOOM: " + string_format(cam_struct.zoom_level, 1, 2) + "x\n";
debug_text += "--------------------------------\n";
debug_text += "MOUSE (GUI): " + string(mx_gui) + ", " + string(my_gui) + "\n";
debug_text += "MOUSE (Room): " + string_format(mx_room, 0, 1) + ", " + string_format(my_room, 0, 1) + "\n";
debug_text += "MOUSE HEX (q,r): " + string(mouse_hex.q) + ", " + string(mouse_hex.r) + "\n";
debug_text += "--------------------------------\n";
debug_text += "INSTANCES (obj_EditorHex): " + string(instance_number(obj_EditorHex)) + "\n";

// --- DRAW BACKGROUND AND TEXT ---

var padding = 8;
var text_x = 800;
var text_y = 10;

// Calculate background dimensions
var text_width = string_width(debug_text);
var text_height = string_height(debug_text);
var rect_x1 = text_x - padding;
var rect_y1 = text_y - padding;
var rect_x2 = text_x + text_width + padding;
var rect_y2 = text_y + text_height + padding;

// Draw the semi-transparent background rectangle
draw_set_color(c_black);
draw_set_alpha(0.75);
draw_rectangle(rect_x1, rect_y1, rect_x2, rect_y2, false);
draw_set_alpha(1.0); // Reset alpha for text

// Draw the debug text
draw_set_color(c_white);
draw_text(text_x, text_y, debug_text);

// --- RESET DRAW SETTINGS ---
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);