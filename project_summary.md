# Project Summary
**Generated on:** 2025-07-12 12:19:02
**Project Path:** I:/Darkstar

---
## Part A: All Files in Project
**Total Files:** 23

### .GML Files (12 files)
- `objects\obj_game_controller\Create_0.gml` (884 bytes)
- `objects\obj_main_menu_controller\Create_0.gml` (667 bytes)
- `objects\obj_main_menu_controller\Draw_0.gml` (656 bytes)
- `objects\obj_menu_button\Create_0.gml` (483 bytes)
- `objects\obj_menu_button\Draw_64.gml` (1371 bytes)
- `objects\obj_menu_button\Step_0.gml` (1966 bytes)
- `scripts\scr_asset_manager\scr_asset_manager.gml` (9454 bytes)
- `scripts\scr_config_manager\scr_config_manager.gml` (9034 bytes)
- `scripts\scr_enums_and_constants\scr_enums_and_constants.gml` (1615 bytes)
- `scripts\scr_game_state_manager\scr_game_state_manager.gml` (4373 bytes)
- `scripts\scr_logger\scr_logger.gml` (2627 bytes)
- `scripts\scr_menu_system\scr_menu_system.gml` (7237 bytes)

### .MD Files (1 files)
- `project_summary.md` (9960 bytes)

### .PNG Files (1 files)
- `datafiles\assets\images\mainmenu_background.png` (2393382 bytes)

### .RESOURCE_ORDER Files (1 files)
- `DarkStar.resource_order` (1051 bytes)

### .YY Files (7 files)
- `objects\obj_game_controller\obj_game_controller.yy` (898 bytes)
- `objects\obj_main_menu_controller\obj_main_menu_controller.yy` (1067 bytes)
- `objects\obj_menu_button\obj_menu_button.yy` (1210 bytes)
- `options\main\options_main.yy` (913 bytes)
- `options\operagx\options_operagx.yy` (989 bytes)
- `options\windows\options_windows.yy` (1619 bytes)
- `rooms\Room1\Room1.yy` (3449 bytes)

### .YYP Files (1 files)
- `DarkStar.yyp` (3257 bytes)


---
## Part B: GameMaker Objects and Events
**Total Objects:** 3

### Object: obj_game_controller
**Description:** Initialize the game during startup phase Sets up all core systems in proper order and transitions to main menu This is the main entry point for the entire game
**Path:** `objects\obj_game_controller`
**Events (1):**
- **Create_0** (Create Event)
  - *Description:* Initialize the game during startup phase Sets up all core systems in proper order and transitions to main menu This is the main entry point for the entire game
  - *Path:* `objects\obj_game_controller\Create_0.gml`


### Object: obj_main_menu_controller
**Description:** Initialize the main menu controller when room is entered Sets up menu state and creates all menu buttons Called automatically when main menu room is entered
**Path:** `objects\obj_main_menu_controller`
**Events (2):**
- **Create_0** (Create Event)
  - *Description:* Initialize the main menu controller when room is entered Sets up menu state and creates all menu buttons Called automatically when main menu room is entered
  - *Path:* `objects\obj_main_menu_controller\Create_0.gml`

- **Draw_0** (Draw Event)
  - *Description:* Draw the main menu background image Renders background sprite stretched to fill entire screen Called every frame while in main menu room
  - *Path:* `objects\obj_main_menu_controller\Draw_0.gml`


### Object: obj_menu_button
**Description:** Initialize menu button instance variables Sets up button state and visual properties with defaults Called when button instance is created
**Path:** `objects\obj_menu_button`
**Events (3):**
- **Create_0** (Create Event)
  - *Description:* Initialize menu button instance variables Sets up button state and visual properties with defaults Called when button instance is created
  - *Path:* `objects\obj_menu_button\Create_0.gml`

- **Draw_64** (Draw GUI Event)
  - *Description:* Draw the menu button with current state styling Renders button background, border, and text in GUI layer Uses different colors based on hover/press state
  - *Path:* `objects\obj_menu_button\Draw_64.gml`

- **Step_0** (Step Event)
  - *Description:* Handle button input detection and state updates Processes mouse hover and click interactions each frame Executes button callback when clicked while enabled
  - *Path:* `objects\obj_menu_button\Step_0.gml`



---
## Part C: Script Files and Functions
**Total Scripts:** 6

### Script: scr_asset_manager
**Description:** Initialize the asset management system Creates data structures for asset caching and loads manifest file Requires config system to be initialized first for asset paths
**Path:** `scripts\scr_asset_manager\scr_asset_manager.gml`
**Functions (7):**
- **`assets_cleanup()`**

- **`assets_create_default_manifest()`**

- **`assets_get_sprite(asset_key)`**
  - *Arguments:* asset_key

- **`assets_get_sprite_safe(asset_key)`**
  - *Arguments:* asset_key

- **`assets_init()`**

- **`assets_load_manifest()`**

- **`assets_load_sprite(asset_key)`**
  - *Arguments:* asset_key


### Script: scr_config_manager
**Description:** Initialize the configuration manager and load settings from file Sets up default configuration values and loads user settings from config file Must be called before any other systems that depend on configuration
**Path:** `scripts\scr_config_manager\scr_config_manager.gml`
**Functions (6):**
- **`config_apply_display_settings()`**

- **`config_get(section, key, default_value = undefined)`**
  - *Arguments:* section, key, default_value = undefined

- **`config_init()`**

- **`config_load()`**

- **`config_save()`**

- **`config_set(section, key, value)`**
  - *Arguments:* section, key, value


### Script: scr_enums_and_constants
**Description:** Game state enumeration for managing different phases of the game
**Path:** `scripts\scr_enums_and_constants\scr_enums_and_constants.gml`
**Functions:** No functions found

### Script: scr_game_state_manager
**Description:** Initialize the game state management system Sets up global state variables and callback system Must be called during game initialization before any state changes
**Path:** `scripts\scr_game_state_manager\scr_game_state_manager.gml`
**Functions (7):**
- **`gamestate_change(new_state, reason = "")`**
  - *Arguments:* new_state, reason = ""

- **`gamestate_cleanup()`**

- **`gamestate_execute_callbacks(state)`**
  - *Arguments:* state

- **`gamestate_get()`**

- **`gamestate_get_previous()`**

- **`gamestate_init()`**

- **`gamestate_register_callback(state, callback)`**
  - *Arguments:* state, callback


### Script: scr_logger
**Description:** Initialize the logging system with configuration settings Sets up global logging variables and creates initial log file Requires config system to be initialized first
**Path:** `scripts\scr_logger\scr_logger.gml`
**Functions (2):**
- **`logger_init()`**

- **`logger_write(level, source, message, reason = "")`**
  - *Arguments:* level, source, message, reason = ""


### Script: scr_menu_system
**Description:** Create a menu button data structure with all necessary properties @param {Constant.ButtonType} type ButtonType enum value for the button type @param {string} text Display text for the button @param {real} x X position in GUI coordinates @param {real} y Y position in GUI coordinates @param {function} callback Function to call when button is clicked @return {struct} Button data structure with all properties set
**Path:** `scripts\scr_menu_system\scr_menu_system.gml`
**Functions (9):**
- **`menu_callback_continue()`**

- **`menu_callback_exit()`**

- **`menu_callback_map_editor()`**

- **`menu_callback_new_game()`**

- **`menu_callback_options()`**

- **`menu_callback_run_tests()`**

- **`menu_create_button_data(type, text, x, y, callback)`**
  - *Arguments:* type, text, x, y, callback

- **`menu_create_buttons(button_configs)`**
  - *Arguments:* button_configs

- **`menu_get_main_menu_buttons()`**


