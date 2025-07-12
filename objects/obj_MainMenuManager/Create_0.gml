/// @description Initialize main menu manager with observer pattern

logger_write(LogLevel.INFO, "MainMenuManager", "Starting main menu initialization", "Create event");

// Register as observer for button clicks
gamestate_add_observer("button_clicked", main_menu_handle_button_click);

// Create menu buttons
var center_x = display_get_gui_width() / 2;
var center_y = display_get_gui_height() / 2;
var start_y = center_y - 200;
var spacing = 80;

logger_write(LogLevel.INFO, "MainMenuManager", 
            string("Display dimensions: {0}x{1}", display_get_gui_width(), display_get_gui_height()), 
            "Layout calculation");

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
    if (instance_exists(btn)) {
        btn.button_id = buttons[i].id;
        btn.text = buttons[i].text;
        logger_write(LogLevel.DEBUG, "MainMenuManager", 
                    string("Created button: {0} at ({1}, {2})", buttons[i].text, center_x, start_y + (i * spacing)), 
                    "Button creation");
    } else {
        logger_write(LogLevel.ERROR, "MainMenuManager", 
                    string("Failed to create button: {0}", buttons[i].text), 
                    "Button creation failed");
    }
}

// Create background
var bg = instance_create_layer(0, 0, "Background", obj_MainMenuBackground);
if (instance_exists(bg)) {
    logger_write(LogLevel.INFO, "MainMenuManager", "Created main menu background", "Background creation");
} else {
    logger_write(LogLevel.ERROR, "MainMenuManager", "Failed to create main menu background", "Background creation failed");
}

logger_write(LogLevel.INFO, "MainMenuManager", "Main menu initialized", "Created menu buttons and background");