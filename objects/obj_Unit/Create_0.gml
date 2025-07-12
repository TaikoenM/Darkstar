/// @description Initialize unit instance as view of GameState data

// Reference to data in GameState
unit_id = "";  // Set by factory
unit_data = undefined;  // Will reference GameState.units[unit_id]

// Visual state
selected = false;
hover = false;
health_bar_alpha = 0;

// Animation
move_progress = 0;
visual_x = x;
visual_y = y;