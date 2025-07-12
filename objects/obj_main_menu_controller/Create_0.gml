/// @description Initialize the main menu controller when room is entered
/// @description Sets up menu state and creates all menu buttons
/// @description Called automatically when main menu room is entered

logger_write(LogLevel.INFO, "MainMenuController", "Main menu controller created", "Room transition");

// Set game state to main menu
gamestate_change(GameState.MAIN_MENU, "Entered main menu room");

// Create menu buttons using factory system
var button_configs = menu_get_main_menu_buttons();
menu_create_buttons(button_configs);

logger_write(LogLevel.INFO, "MainMenuController", "Main menu initialization complete", "Menu setup finished");
