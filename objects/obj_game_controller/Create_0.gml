/// @description Initialize the game during startup phase
/// @description Sets up all core systems in proper order and transitions to main menu
/// @description This is the main entry point for the entire game

// Initialize configuration first (before logging to get logging settings)
config_init();

// Initialize logging system (requires config to be initialized)
logger_init();

// Initialize other core systems
gamestate_init();
assets_init();

logger_write(LogLevel.INFO, "GameController", "Game initialization started", "System startup");

// Pre-load critical assets
assets_load_sprite("mainmenu_background");

// Transition to main menu state and room
gamestate_change(GameState.MAIN_MENU, "Initialization complete");
room_goto(room_main_menu);

logger_write(LogLevel.INFO, "GameController", "Transitioning to main menu", "Initialization complete");
