/// @description Initialize menu button with native GameMaker approach
/// @description Button handles its own rendering and input detection

// Button identity
button_id = "";  // Set by creator (e.g., "START_GAME", "EXIT")
text = "Button";

// Visual properties
width = 300;
height = 60;
button_color = c_gray;
button_color_hover = c_ltgray;
button_color_pressed = c_dkgray;
text_color = c_white;

// State
is_hovered = false;
is_pressed = false;
enabled = true;
visible = true;