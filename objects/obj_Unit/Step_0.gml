/// @description Update visual state and animations

// Get reference to our data
if (unit_data == undefined && unit_id != "") {
    unit_data = gamestate_get_unit(unit_id);
}

if (unit_data == undefined) exit;

// Update hover state
hover = position_meeting(mouse_x, mouse_y, id);

// Smooth movement animation
visual_x = lerp(visual_x, unit_data.x, 0.15);
visual_y = lerp(visual_y, unit_data.y, 0.15);

// Update actual position for collision detection
x = unit_data.x;
y = unit_data.y;

// Fade in health bar when hovered or damaged
var target_alpha = (hover || unit_data.health < unit_data.max_health) ? 1 : 0;
health_bar_alpha = lerp(health_bar_alpha, target_alpha, 0.1);