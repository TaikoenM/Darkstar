/// @description Draw debug information

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
    
    // Debug information
    var debug_info = [
        "=== DEBUG INFO ===",
        string("FPS: {0} / {1}", fps, fps_real),
        string("Room: {0}", room_get_name(room)),
        string("Game State: {0}", gamestate_get()),
        string("Instances: {0}", instance_count),
        string("Time: {0}", current_time),
        "",
        "Objects in room:",
        string("- GameController: {0}", instance_exists(obj_game_controller)),
        string("- MainMenuManager: {0}", instance_exists(obj_MainMenuManager)),
        string("- InputManager: {0}", instance_exists(obj_InputManager)),
        string("- UIManager: {0}", instance_exists(obj_UIManager)),
        string("- MenuButtons: {0}", instance_number(obj_MenuButton)),
        string("- Background: {0}", instance_exists(obj_MainMenuBackground))
    ];
    
    // Draw background for readability
    var max_width = 300;
    var total_height = array_length(debug_info) * line_height + 20;
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