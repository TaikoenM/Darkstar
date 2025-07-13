/// @description Update visual state based on game data

// Get reference to our data from GameState
if (unit_data == undefined && unit_id != "") {
    unit_data = gamestate_get_unit(unit_id);
}

if (unit_data == undefined) exit;

// Check if we're selected
selected = false;
for (var i = 0; i < array_length(global.game_state.selected_units); i++) {
    if (global.game_state.selected_units[i] == unit_id) {
        selected = true;
        break;
    }
}

// Update hover state
hover = position_meeting(mouse_x, mouse_y, id);

// Smooth movement animation
if (variable_struct_exists(unit_data, "x") && variable_struct_exists(unit_data, "y")) {
    visual_x = lerp(visual_x, unit_data.x, 0.15);
    visual_y = lerp(visual_y, unit_data.y, 0.15);
    
    // Update actual position for collision detection
    x = unit_data.x;
    y = unit_data.y;
}

// Fade in health bar when hovered or damaged
if (variable_struct_exists(unit_data, "health") && variable_struct_exists(unit_data, "max_health")) {
    var target_alpha = (hover || unit_data.health < unit_data.max_health) ? 1 : 0;
    health_bar_alpha = lerp(health_bar_alpha, target_alpha, 0.1);
}