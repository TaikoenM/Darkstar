/// @description Initialize unit view instance

// This unit's ID in the game state
unit_id = "";  // Set by factory
unit_data = undefined;  // Will reference data from GameState

// Visual state (not saved)
selected = false;
hover = false;
health_bar_alpha = 0;

// Animation state
move_progress = 0;
visual_x = x;
visual_y = y;