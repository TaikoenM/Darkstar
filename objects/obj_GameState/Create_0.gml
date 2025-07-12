/// @description Initialize game state data container
/// @description This object contains NO logic, only data

// This object is created by the GameController during initialization
// It holds the entire game state as defined in scr_game_state_manager

// The actual data is stored in global.game_state
// This object exists primarily for:
// 1. Serialization/save game purposes
// 2. To have a clear object that represents the game data
// 3. Future multiplayer synchronization

// Make this persistent
persistent = true;

// Log creation
if (variable_global_exists("log_enabled") && global.log_enabled) {
    logger_write(LogLevel.INFO, "GameState", "GameState object created", "Pure data container initialized");
}