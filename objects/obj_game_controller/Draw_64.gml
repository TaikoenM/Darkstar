// Only draw debug info if debug flag is set
if (!variable_global_exists("debug_show_info")) {
    global.debug_show_info = true; // Default to true for now
}

if (global.debug_show_info) {
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_font(-1); // Default font
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var x_pos = 10;
    var y_pos = 10;
    var line_height = 20;
    
    // Basic debug information
    var debug_info = [
        "=== DEBUG INFO ===",
        string("FPS: {0} / {1}", fps, fps_real),
        string("Room: {0}", room_get_name(room)),
        string("Scene State: {0}", scenestate_get()),
        string("Instances: {0}", instance_count),
        string("Time: {0}", current_time),
        "",
        "Objects in room:"
    ];
    
    // Dynamic object counting
    var object_counts = ds_map_create();
    
    // Count all objects dynamically
    with (all) {
        var obj_name = object_get_name(object_index);
        if (ds_map_exists(object_counts, obj_name)) {
            object_counts[? obj_name]++;
        } else {
            object_counts[? obj_name] = 1;
        }
    }
    
    // Add object counts to debug info
    var key = ds_map_find_first(object_counts);
    while (!is_undefined(key)) {
        array_push(debug_info, string("- {0}: {1}", key, object_counts[? key]));
        key = ds_map_find_next(object_counts, key);
    }
    
    ds_map_destroy(object_counts);
    
    // Calculate background size
    var max_width = 300;
    var total_height = array_length(debug_info) * line_height + 20;
    
    // Draw background for readability
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(x_pos - 5, y_pos - 5, x_pos + max_width, y_pos + total_height, false);
    
    // Draw text
    draw_set_color(c_white);
    draw_set_alpha(1);
    for (var i = 0; i < array_length(debug_info); i++) {
        draw_text(x_pos, y_pos + (i * line_height), debug_info[i]);
    }
    
    // Reset draw settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}
