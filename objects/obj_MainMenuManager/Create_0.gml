/// @description Initialize main menu manager with factory pattern

logger_write(LogLevel.INFO, "MainMenuManager", "Starting main menu initialization", "Create event");

// Register as observer for button clicks FIRST
gamestate_add_observer(EVENT_BUTTON_CLICKED, main_menu_handle_button_click);

// Create menu buttons using factory pattern
menu_factory_create_main_menu();

// Create background using factory
menu_factory_create_background();

logger_write(LogLevel.INFO, "MainMenuManager", "Main menu initialized", "Menu setup complete");