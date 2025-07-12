/// @description Game enums and constants with expanded definitions

// ============================================================================
// SCENE STATES (formerly GameState)
// ============================================================================
/// @description Scene state enumeration for managing different UI states
enum SceneState {
    INITIALIZING,   // Game is starting up and initializing systems
    MAIN_MENU,      // Main menu is displayed
    IN_GAME,        // Gameplay is active
    PAUSED,         // Game is paused
    MAP_EDITOR,     // Map editor is active
    OPTIONS,        // Options menu is displayed
    TESTING         // Automated testing mode
}

// ============================================================================
// LOGGING
// ============================================================================
/// @description Logging severity levels for the logging system
enum LogLevel {
    DEBUG,      // Detailed debug information
    INFO,       // General information messages
    WARNING,    // Warning messages
    ERROR,      // Error messages
    CRITICAL    // Critical error messages
}

// ============================================================================
// INPUT & COMMANDS
// ============================================================================
/// @description Command types for the command pattern input system
enum CommandType {
    // Movement commands
    MOVE,               // Move unit/player
    STOP,               // Stop movement
    
    // Action commands
    ACTION_PRIMARY,     // Primary action (e.g., select, attack)
    ACTION_SECONDARY,   // Secondary action (e.g., special ability)
    ACTION_CANCEL,      // Cancel current action
    
    // Selection commands
    SELECT_UNIT,        // Select a single unit
    ADD_TO_SELECTION,   // Add unit to current selection
    TOGGLE_SELECTION,   // Toggle unit selection
    UNIT_ORDER,         // Issue order to unit(s)
    
    // UI commands
    PAUSE,              // Pause/unpause game
    OPEN_MENU,          // Open a specific menu
    CLOSE_MENU,         // Close current menu
    
    // Game flow commands
    START_NEW_GAME,     // Start a new game
    
    // Editor commands
    EDITOR_PLACE,       // Place object in editor
    EDITOR_DELETE,      // Delete object in editor
    EDITOR_SELECT,      // Select object in editor
    
    // System commands
    SAVE_GAME,          // Save game state
    LOAD_GAME,          // Load game state
    QUIT_GAME           // Quit to menu/desktop
}

// ============================================================================
// BUTTON TYPES
// ============================================================================
/// @description Menu button type identifiers
enum ButtonID {
    CONTINUE,           // Continue from saved game
    NEW_GAME,           // Start a new game
    OPTIONS,            // Open options menu
    MAP_EDITOR,         // Open map editor
    INPUT_BINDINGS,     // Open input bindings
    EXIT,               // Exit the game
    RUN_TESTS           // Run automated tests
}

// ============================================================================
// OBSERVER EVENTS
// ============================================================================
/// @description Observer event names as constants
#macro EVENT_BUTTON_CLICKED "button_clicked"
#macro EVENT_UNIT_CLICKED "unit_clicked"
#macro EVENT_UNIT_ORDER_ISSUED "unit_order_issued"
#macro EVENT_HEX_CLICKED "hex_clicked"
#macro EVENT_CITY_CLICKED "city_clicked"
#macro EVENT_TURN_ENDED "turn_ended"
#macro EVENT_SCENE_CHANGED "scene_changed"

// ============================================================================
// NETWORK
// ============================================================================
/// @description Network command types
enum NetworkCommand {
    CONNECT,            // Client connecting
    DISCONNECT,         // Client disconnecting
    STATE_UPDATE,       // Full state synchronization
    COMMAND             // Player command
}

// ============================================================================
// GAME ENTITIES
// ============================================================================
/// @description Faction enumeration for different playable and NPC factions
enum Faction {
    NEUTRAL,            // Neutral/unaligned
    PLAYER_1,           // First player faction
    PLAYER_2,           // Second player faction
    PLAYER_3,           // Third player faction
    PLAYER_4,           // Fourth player faction
    IMPERIAL,           // Imperial forces
    REBEL,              // Rebel faction
    ALIEN_TRADE,        // Trading alien species
    ALIEN_HOSTILE,      // Hostile alien species
    RELIGIOUS,          // Religious institution
    MERCANTILE         // Mercantile guild
}

/// @description Unit types enumeration
enum UnitType {
    INFANTRY,           // Basic infantry unit
    ARMOR,              // Armored vehicles
    ARTILLERY,          // Artillery units
    AIR,                // Air units
    NAVAL,              // Naval units
    SPACE,              // Space units
    HERO,               // Hero/commander units
    CIVILIAN            // Civilian units
}

/// @description Terrain types for hex tiles
enum TerrainType {
    PLAINS,             // Open plains
    FOREST,             // Forest terrain
    HILLS,              // Hilly terrain
    MOUNTAINS,          // Mountain terrain
    DESERT,             // Desert terrain
    SWAMP,              // Swamp terrain
    WATER,              // Water/ocean
    ARCTIC,             // Arctic/ice terrain
    URBAN,              // Urban/city terrain
    INDUSTRIAL          // Industrial terrain
}

// ============================================================================
// KEYBOARD CONSTANTS
// ============================================================================
#macro KEY_DEV_CONSOLE 192          // Tilde key (~)
#macro KEY_QUICK_SAVE vk_f5        // Quick save
#macro KEY_QUICK_LOAD vk_f9        // Quick load
#macro KEY_TOGGLE_DEBUG vk_f3      // Toggle debug display

// ============================================================================
// DISPLAY CONSTANTS
// ============================================================================
#macro DEFAULT_GAME_WIDTH 1920      // Default window width in pixels
#macro DEFAULT_GAME_HEIGHT 1080     // Default window height in pixels  
#macro DEFAULT_FULLSCREEN false     // Default fullscreen setting

// For backwards compatibility
#macro GAME_WIDTH 1920
#macro GAME_HEIGHT 1080

// ============================================================================
// HEX GRID
// ============================================================================
#macro DEFAULT_HEX_SIZE 32          // Default hex tile size in pixels
#macro HEX_SQRT3 1.732050807568877  // Square root of 3 constant

// ============================================================================
// UI CONSTANTS
// ============================================================================
#macro DEFAULT_BUTTON_WIDTH 300     // Default button width
#macro DEFAULT_BUTTON_HEIGHT 60     // Default button height
#macro DEFAULT_BUTTON_SPACING 80    // Default spacing between buttons

// ============================================================================
// GAME BALANCE
// ============================================================================
#macro MAX_PLAYERS 8                // Maximum number of players
#macro DEFAULT_TURN_TIMER 300       // Default turn timer in seconds
#macro MAX_UNITS_PER_STACK 12       // Maximum units in one hex

// ============================================================================
// FILE PATHS
// ============================================================================
#macro CONFIG_FILE "config/game_config.json"
#macro INPUT_MAPPING_FILE "config/input_mapping.json"
#macro ASSET_MANIFEST_FILE "data/asset_manifest.json"
#macro LOG_FILE "logs/game_log.txt"
#macro SAVE_FILE_EXTENSION ".sav"

// Directory structure
#macro DATA_PATH "data/"
#macro CONFIG_PATH "config/"
#macro IMAGES_PATH "assets/images/"
#macro SOUNDS_PATH "assets/sounds/"
#macro SAVES_PATH "saves/"
#macro LOGS_PATH "logs/"

// ============================================================================
// NETWORK
// ============================================================================
#macro DEFAULT_PORT 7777            // Default network port
#macro MAX_PACKET_SIZE 1024         // Maximum network packet size
#macro NETWORK_TIMEOUT 30000        // Network timeout in milliseconds

// ============================================================================
// DEBUG
// ============================================================================
#macro DEBUG_SHOW_HEX_COORDS false  // Show hex coordinates on screen
#macro DEBUG_SHOW_UNIT_IDS false    // Show unit IDs on screen
#macro DEBUG_ENABLE_CHEATS false    // Enable debug cheats