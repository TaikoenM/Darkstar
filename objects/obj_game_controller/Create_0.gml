/// @description Initialize the game during startup phase
/// @description Sets up all core systems in proper order and transitions to main menu
/// @description This is the main entry point for the entire game

// Make this controller persistent
persistent = true;

// Initialize configuration first (before logging to get logging settings)
config_init();

// Initialize logging system (requires config to be initialized)
logger_init();

logger_write(LogLevel.INFO, "GameController", "Game initialization started", "System startup");

// Initialize core systems in proper order
gamestate_init();
assets_init();

// Create manager objects
instance_create_layer(0, 0, "Managers", obj_InputManager);
instance_create_layer(0, 0, "Managers", obj_ViewManager);
instance_create_layer(0, 0, "Managers", obj_UIManager);

// Pre-load critical assets
assets_load_sprite("mainmenu_background");

// Transition to main menu state
gamestate_change(GameState.MAIN_MENU, "Initialization complete");

// Open main menu UI panel
ui_open_panel("main_menu");

logger_write(LogLevel.INFO, "GameController", "Game initialization complete", "All systems ready");

// === Additional code for CREATE EVENT ===
/// @description Register game controller as observer for game events

// Register for unit interactions
gamestate_add_observer("unit_clicked", game_controller_handle_unit_click);
gamestate_add_observer("unit_order_issued", game_controller_handle_unit_order);
gamestate_add_observer("hex_clicked", game_controller_handle_hex_click);
