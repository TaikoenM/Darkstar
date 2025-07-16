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
scenestate_init();  // Scene state (UI states)
gamestate_init();   // Game state (actual game data)
assets_init();

// Create manager objects
instance_create_layer(0, 0, "Managers", obj_DataManager);
instance_create_layer(0, 0, "Managers", obj_GameState);
instance_create_layer(0, 0, "Managers", obj_InputManager);
instance_create_layer(0, 0, "Managers", obj_UIManager);
instance_create_layer(0, 0, "Managers", obj_DevConsole);


// Pre-load critical assets
assets_load_sprite("mainmenu_background");


// Register game controller as observer for game events
gamestate_add_observer(EVENT_UNIT_CLICKED, game_controller_handle_unit_click);
gamestate_add_observer(EVENT_UNIT_ORDER_ISSUED, game_controller_handle_unit_order);
gamestate_add_observer(EVENT_HEX_CLICKED, game_controller_handle_hex_click);

logger_write(LogLevel.INFO, "GameController", "Game initialization complete", "All systems ready");

// Change scene state before room transition
scenestate_change(SceneState.MAIN_MENU, "Transitioning to main menu");

// Transition to main menu
logger_write(LogLevel.INFO, "GameController", "Attempting room transition", string("Current room: {0}, Target: room_main_menu", room_get_name(room)));
room_goto(room_main_menu);
logger_write(LogLevel.INFO, "GameController", "Room transition initiated", "room_goto called");