// === CREATE EVENT ===
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

// === CLEANUP EVENT ===
/// @description Unregister observers when destroyed

gamestate_remove_observer("button_clicked", main_menu_handle_button_click);

// === USER DEFINED FUNCTIONS ===

/// @function main_menu_handle_button_click(event_data)
/// @description Handle button click events from menu
/// @param {struct} event_data Event data containing button_id
function main_menu_handle_button_click(event_data) {
    var button_id = event_data.button_id;
    
    logger_write(LogLevel.INFO, "MainMenuManager", 
                string("Button clicked: {0}", button_id), "User interaction");
    
    switch (button_id) {
        case "NEW_GAME":
            // Create command to start new game
            var cmd = input_create_command(CommandType.START_NEW_GAME, {});
            input_queue_command(cmd);
            break;
            
        case "CONTINUE":
            // Create command to load save
            var cmd = input_create_command(CommandType.LOAD_GAME, {
                save_slot: "quicksave"
            });
            input_queue_command(cmd);
            break;
            
        case "OPTIONS":
            // Open options panel
            instance_create_layer(display_get_gui_width()/2, display_get_gui_height()/2, 
                                "UI", obj_OptionsPanel);
            break;
            
        case "INPUT_BINDINGS":
            // Open input bindings panel
            instance_create_layer(display_get_gui_width()/2, display_get_gui_height()/2, 
                                "UI", obj_InputBindingsPanel);
            break;
            
        case "MAP_EDITOR":
            // Change to map editor state
            gamestate_change(GameState.MAP_EDITOR, "Opening map editor");
            break;
            
        case "EXIT":
            // Save and quit
            config_save();
            game_end();
            break;
    }
}