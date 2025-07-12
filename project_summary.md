# Project Summary
**Generated on:** 2025-07-11 18:53:57
**Project Path:** I:/Hexframe/Hexframe

---
# Game Maker Studio 2 Project Context

## Available Scripts

### Create_0

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\objects\obj_game_controller\Create_0.gml

```gml
/// @description Initialize the game during startup phase
/// @description Sets up all core systems in proper order and transitions to main menu
/// @description This is the main entry point for the entire game

// Initialize configuration first (before logging to get logging settings)
config_init();

// Initialize logging system (requires config to be initialized)
logger_init();

// ... (more code continues)
```

### Create_0

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\objects\obj_main_menu_controller\Create_0.gml

```gml
/// @description Initialize the main menu controller when room is entered
/// @description Sets up menu state and creates all menu buttons
/// @description Called automatically when main menu room is entered

logger_write(LogLevel.INFO, "MainMenuController", "Main menu controller created", "Room transition");

// Set game state to main menu
gamestate_change(GameState.MAIN_MENU, "Entered main menu room");

// Create menu buttons using factory system
// ... (more code continues)
```

### Draw_0

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\objects\obj_main_menu_controller\Draw_0.gml

```gml
/// @description Draw the main menu background image
/// @description Renders background sprite stretched to fill entire screen
/// @description Called every frame while in main menu room

// Get background sprite safely
var bg_sprite = assets_get_sprite_safe("mainmenu_background");

// Draw background if sprite is valid
if (bg_sprite != -1 && sprite_exists(bg_sprite)) {
    draw_sprite_stretched(bg_sprite, 0, 0, 0, GAME_WIDTH, GAME_HEIGHT);
// ... (more code continues)
```

### Create_0

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\objects\obj_menu_button\Create_0.gml

```gml
/// @description Initialize menu button instance variables
/// @description Sets up button state and visual properties with defaults
/// @description Called when button instance is created

// Button data will be set by menu factory
button_data = undefined;

// Button state tracking
is_hovered = false;
is_pressed = false;
// ... (more code continues)
```

### Draw_64

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\objects\obj_menu_button\Draw_64.gml

```gml
/// @description Draw the menu button with current state styling
/// @description Renders button background, border, and text in GUI layer
/// @description Uses different colors based on hover/press state

// Early exit if no button data or button is hidden
if (button_data == undefined || !button_data.visible) {
    return;
}

// Determine button color based on current state
// ... (more code continues)
```

### Step_0

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\objects\obj_menu_button\Step_0.gml

```gml
/// @description Handle button input detection and state updates
/// @description Processes mouse hover and click interactions each frame
/// @description Executes button callback when clicked while enabled

// Early exit if no button data
if (button_data == undefined) {
    return;
}

// Get mouse position in GUI coordinates
// ... (more code continues)
```

### scr_asset_manager

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\scripts\scr_asset_manager\scr_asset_manager.gml

```gml
/// @description Initialize the asset management system
/// @description Creates data structures for asset caching and loads manifest file
/// @description Requires config system to be initialized first for asset paths
function assets_init() {
    global.loaded_sprites = ds_map_create();
    global.loaded_sounds = ds_map_create();
    global.asset_manifest = ds_map_create();
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager initialized", "System startup");
// ... (more code continues)
```

### scr_config_manager

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\scripts\scr_config_manager\scr_config_manager.gml

```gml
/// @description Initialize the configuration manager and load settings from file
/// @description Sets up default configuration values and loads user settings from config file
/// @description Must be called before any other systems that depend on configuration
function config_init() {
    global.config_file = "game_config.ini";
    global.config_loaded = false;
    
    // Initialize config structure with defaults
    global.config = {
        // Display settings
// ... (more code continues)
```

### scr_enums_and_constants

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\scripts\scr_enums_and_constants\scr_enums_and_constants.gml

```gml
/// @description Game state enumeration for managing different phases of the game
enum GameState {
    INITIALIZING,   // Game is starting up and initializing systems
    MAIN_MENU,      // Main menu is displayed
    IN_GAME,        // Gameplay is active
    PAUSED,         // Game is paused
    MAP_EDITOR,     // Map editor is active
    OPTIONS,        // Options menu is displayed
    TESTING         // Automated testing mode
}
// ... (more code continues)
```

### scr_game_state_manager

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\scripts\scr_game_state_manager\scr_game_state_manager.gml

```gml
/// @description Initialize the game state management system
/// @description Sets up global state variables and callback system
/// @description Must be called during game initialization before any state changes
function gamestate_init() {
    global.game_state = GameState.INITIALIZING;
    global.previous_game_state = GameState.INITIALIZING;
    global.state_change_callbacks = ds_map_create();
    
    // Safe logging - check if logger is initialized
    if (variable_global_exists("log_enabled") && global.log_enabled) {
// ... (more code continues)
```

### scr_logger

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\scripts\scr_logger\scr_logger.gml

```gml
/// @description Initialize the logging system with configuration settings
/// @description Sets up global logging variables and creates initial log file
/// @description Requires config system to be initialized first
function logger_init() {
    // Check if config system is available and logging is enabled
    if (!variable_global_exists("config") || !global.config.log_enabled) {
        global.log_enabled = false;
        return;
    }
    
// ... (more code continues)
```

### scr_menu_system

**Description**: Missing description

**Path**: I:/Hexframe/Hexframe\scripts\scr_menu_system\scr_menu_system.gml

```gml
/// @description Create a menu button data structure with all necessary properties
/// @param {Constant.ButtonType} type ButtonType enum value for the button type
/// @param {string} text Display text for the button
/// @param {real} x X position in GUI coordinates
/// @param {real} y Y position in GUI coordinates
/// @param {function} callback Function to call when button is clicked
/// @return {struct} Button data structure with all properties set
function menu_create_button_data(type, text, x, y, callback) {
    var button_width = 300;
    var button_height = 60;
// ... (more code continues)
```

## Other Assets

- **obj_game_controller** (unknown): Error parsing metadata file

- **obj_main_menu_controller** (unknown): Error parsing metadata file

- **obj_menu_button** (unknown): Error parsing metadata file

- **options_main** (unknown): Error parsing metadata file

- **options_operagx** (unknown): Error parsing metadata file

- **options_windows** (unknown): Error parsing metadata file

- **room_game_init** (unknown): Error parsing metadata file

- **room_main_menu** (unknown): Error parsing metadata file

- **scr_asset_manager** (unknown): Error parsing metadata file

- **scr_config_manager** (unknown): Error parsing metadata file

- **scr_enums_and_constants** (unknown): Error parsing metadata file

- **scr_game_state_manager** (unknown): Error parsing metadata file

- **scr_logger** (unknown): Error parsing metadata file

- **scr_menu_system** (unknown): Error parsing metadata file

---
## Code Structure Analysis
- **Total Files:** 0
- **Total Modules:** 0
- **Total Classes:** 0
- **Total Functions:** 0

### Functions
No functions found.

### Classes
No classes found.

### Modules
No modules found.

### Dependencies
No dependencies found.
