/// @description Initialize main menu manager with observer pattern

// Register as observer for button clicks
gamestate_add_observer("button_clicked", main_menu_handle_button_click);

// Create menu buttons
var center_x = display_get_gui_width() / 2;
var center_y = display_get_gui_height() / 2;
var start_y = center_y - 200;
var spacing = 80;

// Button definitions
var buttons = [
    { id: "CONTINUE", text: "Continue" },
    { id: "NEW_GAME", text: "New Game" },
    { id: "OPTIONS", text: "Options" },
    { id: "MAP_EDITOR", text: "Map Editor" },
    { id: "INPUT_BINDINGS", text: "Controls" },
    { id: "EXIT", text: "Exit" }
];

// Create button instances
for (var i = 0; i < array_length(buttons); i++) {
    var btn = instance_create_layer(center_x, start_y + (i * spacing), "UI", obj_MenuButton);
    btn.button_id = buttons[i].id;
    btn.text = buttons[i].text;
}

// Create background
instance_create_layer(0, 0, "Background", obj_MainMenuBackground);

logger_write(LogLevel.INFO, "MainMenuManager", "Main menu initialized", "Created menu buttons");