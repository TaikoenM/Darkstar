# Project Summary
**Generated on:** 2025-07-12 17:08:43
**Project Path:** I:/Darkstar

---
## Part A: All Files in Project
**Total Files:** 61

### .GML Files (31 files)
- `objects\obj_InputManager\Create_0.gml` (399 bytes)
- `objects\obj_InputManager\Step_0.gml` (179 bytes)
- `objects\obj_MainMenuBackground\Draw_0.gml` (712 bytes)
- `objects\obj_MainMenuManager\Create_0.gml` (3080 bytes)
- `objects\obj_MenuButton\Create_0.gml` (499 bytes)
- `objects\obj_MenuButton\Draw_0.gml` (770 bytes)
- `objects\obj_MenuButton\Mouse_11.gml` (73 bytes)
- `objects\obj_MenuButton\Mouse_7.gml` (357 bytes)
- `objects\obj_MenuButton\Step_0.gml` (313 bytes)
- `objects\obj_UIManager\Create_0.gml` (572 bytes)
- `objects\obj_Unit\Create_0.gml` (349 bytes)
- `objects\obj_Unit\Draw_0.gml` (1222 bytes)
- `objects\obj_Unit\Mouse_4.gml` (324 bytes)
- `objects\obj_Unit\Mouse_5.gml` (399 bytes)
- `objects\obj_Unit\Step_0.gml` (698 bytes)
- `objects\obj_ViewManager\Create_0.gml` (687 bytes)
- `objects\obj_game_controller\Create_0.gml` (1561 bytes)
- `objects\obj_game_controller\Step_0.gml` (1179 bytes)
- `objects\obj_main_menu_controller\Create_0.gml` (667 bytes)
- `objects\obj_main_menu_controller\Draw_0.gml` (811 bytes)
- `scripts\scr_asset_manager\scr_asset_manager.gml` (9542 bytes)
- `scripts\scr_config_manager\scr_config_manager.gml` (9914 bytes)
- `scripts\scr_debug_file_system\scr_debug_file_system.gml` (2221 bytes)
- `scripts\scr_enums_and_constants\scr_enums_and_constants.gml` (2564 bytes)
- `scripts\scr_game_control\scr_game_control.gml` (1952 bytes)
- `scripts\scr_game_state_manager\scr_game_state_manager.gml` (4373 bytes)
- `scripts\scr_gamestate_observer\scr_gamestate_observer.gml` (37 bytes)
- `scripts\scr_input_manager\scr_input_manager.gml` (9809 bytes)
- `scripts\scr_logger\scr_logger.gml` (2665 bytes)
- `scripts\scr_menu_system\scr_menu_system.gml` (6790 bytes)
- `scripts\scr_ui_manager\scr_ui_manager.gml` (5527 bytes)

### .MD Files (1 files)
- `project_summary.md` (7747 bytes)

### .PNG Files (1 files)
- `datafiles\assets\images\mainmenu_background.png` (2393382 bytes)

### .RESOURCE_ORDER Files (1 files)
- `DarkStar.resource_order` (3062 bytes)

### .YY Files (26 files)
- `objects\obj_InputManager\obj_InputManager.yy` (1051 bytes)
- `objects\obj_MainMenuBackground\obj_MainMenuBackground.yy` (903 bytes)
- `objects\obj_MainMenuManager\obj_MainMenuManager.yy` (897 bytes)
- `objects\obj_MenuButton\obj_MenuButton.yy` (1689 bytes)
- `objects\obj_UIManager\obj_UIManager.yy` (885 bytes)
- `objects\obj_Unit\obj_Unit.yy` (1515 bytes)
- `objects\obj_ViewManager\obj_ViewManager.yy` (889 bytes)
- `objects\obj_game_controller\obj_game_controller.yy` (1057 bytes)
- `objects\obj_main_menu_controller\obj_main_menu_controller.yy` (1067 bytes)
- `options\main\options_main.yy` (913 bytes)
- `options\operagx\options_operagx.yy` (989 bytes)
- `options\windows\options_windows.yy` (1619 bytes)
- `rooms\room_game_init\room_game_init.yy` (4470 bytes)
- `rooms\room_main_menu\room_main_menu.yy` (4061 bytes)
- `roomui\RoomUI\RoomUI.yy` (496 bytes)
- `scripts\scr_asset_manager\scr_asset_manager.yy` (257 bytes)
- `scripts\scr_config_manager\scr_config_manager.yy` (259 bytes)
- `scripts\scr_debug_file_system\scr_debug_file_system.yy` (265 bytes)
- `scripts\scr_enums_and_constants\scr_enums_and_constants.yy` (269 bytes)
- `scripts\scr_game_control\scr_game_control.yy` (255 bytes)
- `scripts\scr_game_state_manager\scr_game_state_manager.yy` (267 bytes)
- `scripts\scr_gamestate_observer\scr_gamestate_observer.yy` (267 bytes)
- `scripts\scr_input_manager\scr_input_manager.yy` (257 bytes)
- `scripts\scr_logger\scr_logger.yy` (243 bytes)
- `scripts\scr_menu_system\scr_menu_system.yy` (253 bytes)
- `scripts\scr_ui_manager\scr_ui_manager.yy` (251 bytes)

### .YYP Files (1 files)
- `DarkStar.yyp` (5819 bytes)


---
## Part B: GameMaker Objects and Events
**Total Objects:** 9

### Object: obj_InputManager
**Description:** Initialize the Input Manager Translates raw hardware input into abstract game commands Part of the Controller layer in MVC architecture
**Path:** `objects\obj_InputManager`
**Events (2):**
- **Create_0** (Create Event)
  - *Description:* Initialize the Input Manager Translates raw hardware input into abstract game commands Part of the Controller layer in MVC architecture
  - *Path:* `objects\obj_InputManager\Create_0.gml`

- **Step_0** (Step Event)
  - *Description:* Process input and convert to commands Called every frame to capture player input
  - *Path:* `objects\obj_InputManager\Step_0.gml`


### Object: obj_MainMenuBackground
**Description:** Draw the main menu background Pure view component - only renders background
**Path:** `objects\obj_MainMenuBackground`
**Events (1):**
- **Draw_0** (Draw Event)
  - *Description:* Draw the main menu background Pure view component - only renders background
  - *Path:* `objects\obj_MainMenuBackground\Draw_0.gml`


### Object: obj_MainMenuManager
**Description:** Initialize main menu manager with observer pattern
**Path:** `objects\obj_MainMenuManager`
**Events (1):**
- **Create_0** (Create Event)
  - *Description:* Initialize main menu manager with observer pattern
  - *Path:* `objects\obj_MainMenuManager\Create_0.gml`
  - *Functions:*
    - `main_menu_handle_button_click(event_data)`
    - `main_menu_handle_button_click(event_data)`


### Object: obj_MenuButton
**Description:** Initialize menu button with native GameMaker approach Button handles its own rendering and input detection
**Path:** `objects\obj_MenuButton`
**Events (5):**
- **Create_0** (Create Event)
  - *Description:* Initialize menu button with native GameMaker approach Button handles its own rendering and input detection
  - *Path:* `objects\obj_MenuButton\Create_0.gml`

- **Draw_0** (Draw Event)
  - *Path:* `objects\obj_MenuButton\Draw_0.gml`

- **Mouse_11** (Mouse Event)
  - *Description:* Reset press state if mouse leaves
  - *Path:* `objects\obj_MenuButton\Mouse_11.gml`

- **Mouse_7** (Mouse Event)
  - *Description:* Handle mouse release and notify observers
  - *Path:* `objects\obj_MenuButton\Mouse_7.gml`

- **Step_0** (Step Event)
  - *Description:* Update button hover state
  - *Path:* `objects\obj_MenuButton\Step_0.gml`


### Object: obj_UIManager
**Description:** Initialize the UI Manager Manages UI panels, focus, and layering Works with ViewManager to display UI elements
**Path:** `objects\obj_UIManager`
**Events (1):**
- **Create_0** (Create Event)
  - *Description:* Initialize the UI Manager Manages UI panels, focus, and layering Works with ViewManager to display UI elements
  - *Path:* `objects\obj_UIManager\Create_0.gml`


### Object: obj_Unit
**Description:** Initialize unit instance as view of GameState data
**Path:** `objects\obj_Unit`
**Events (5):**
- **Create_0** (Create Event)
  - *Description:* Initialize unit instance as view of GameState data
  - *Path:* `objects\obj_Unit\Create_0.gml`

- **Draw_0** (Draw Event)
  - *Description:* Draw unit based on data
  - *Path:* `objects\obj_Unit\Draw_0.gml`

- **Mouse_4** (Mouse Event)
  - *Description:* Handle unit selection
  - *Path:* `objects\obj_Unit\Mouse_4.gml`

- **Mouse_5** (Mouse Event)
  - *Description:* Handle unit orders
  - *Path:* `objects\obj_Unit\Mouse_5.gml`

- **Step_0** (Step Event)
  - *Description:* Update visual state and animations
  - *Path:* `objects\obj_Unit\Step_0.gml`


### Object: obj_ViewManager
**Description:** Initialize the View Manager Coordinates visual instances and synchronizes with GameState Part of the View layer in MVC architecture
**Path:** `objects\obj_ViewManager`
**Events (1):**
- **Create_0** (Create Event)
  - *Description:* Initialize the View Manager Coordinates visual instances and synchronizes with GameState Part of the View layer in MVC architecture
  - *Path:* `objects\obj_ViewManager\Create_0.gml`


### Object: obj_game_controller
**Description:** Initialize the game during startup phase Sets up all core systems in proper order and transitions to main menu This is the main entry point for the entire game
**Path:** `objects\obj_game_controller`
**Events (2):**
- **Create_0** (Create Event)
  - *Description:* Initialize the game during startup phase Sets up all core systems in proper order and transitions to main menu This is the main entry point for the entire game
  - *Path:* `objects\obj_game_controller\Create_0.gml`

- **Step_0** (Step Event)
  - *Description:* Update core game systems each frame Processes input, executes commands, and updates game state
  - *Path:* `objects\obj_game_controller\Step_0.gml`


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



---
## Part C: Script Files and Functions
**Total Scripts:** 11

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


### Script: scr_debug_file_system
**Description:** Debug file system to understand how GameMaker handles included files Call this to log information about file paths and included files
**Path:** `scripts\scr_debug_file_system\scr_debug_file_system.gml`
**Functions (1):**
- **`debug_file_system()`**


### Script: scr_enums_and_constants
**Description:** Game state enumeration for managing different phases of the game
**Path:** `scripts\scr_enums_and_constants\scr_enums_and_constants.gml`
**Functions:** No functions found

### Script: scr_game_control
**Description:** Handle unit selection events @param {struct} event_data Contains unit_id, modifiers
**Path:** `scripts\scr_game_control\scr_game_control.gml`
**Functions (6):**
- **`game_controller_handle_hex_click(event_data)`**
  - *Arguments:* event_data

- **`game_controller_handle_hex_click(event_data)`**
  - *Arguments:* event_data

- **`game_controller_handle_unit_click(event_data)`**
  - *Arguments:* event_data

- **`game_controller_handle_unit_click(event_data)`**
  - *Arguments:* event_data

- **`game_controller_handle_unit_order(event_data)`**
  - *Arguments:* event_data

- **`game_controller_handle_unit_order(event_data)`**
  - *Arguments:* event_data


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


### Script: scr_gamestate_observer
**Path:** `scripts\scr_gamestate_observer\scr_gamestate_observer.gml`
**Functions (1):**
- **`scr_gamestate_observer()`**


### Script: scr_input_manager
**Description:** Initialize the input management system Creates command queue and loads input mappings
**Path:** `scripts\scr_input_manager\scr_input_manager.gml`
**Functions (18):**
- **`input_cleanup()`**

- **`input_cleanup()`**

- **`input_create_command(type, data, player_id)`**
  - *Arguments:* type, data, player_id

- **`input_create_command(type, data, player_id = 0)`**
  - *Arguments:* type, data, player_id = 0

- **`input_dequeue_command()`**

- **`input_dequeue_command()`**

- **`input_init()`**

- **`input_init()`**

- **`input_load_mapping()`**

- **`input_load_mapping()`**

- **`input_queue_command(command)`**
  - *Arguments:* command

- **`input_queue_command(command)`**
  - *Arguments:* command

- **`input_save_mapping()`**

- **`input_save_mapping()`**

- **`input_set_ui_focus(has_focus)`**
  - *Arguments:* has_focus

- **`input_set_ui_focus(has_focus)`**
  - *Arguments:* has_focus

- **`input_update()`**

- **`input_update()`**


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


### Script: scr_ui_manager
**Description:** Create and open a UI panel @param {string} panel_type Type of panel to open @param {struct} data Data to pass to the panel @return {id} Instance ID of created panel
**Path:** `scripts\scr_ui_manager\scr_ui_manager.gml`
**Functions (10):**
- **`ui_cleanup()`**

- **`ui_cleanup()`**

- **`ui_close_all_panels()`**

- **`ui_close_all_panels()`**

- **`ui_close_panel(panel_instance)`**
  - *Arguments:* panel_instance

- **`ui_close_panel(panel_instance)`**
  - *Arguments:* panel_instance

- **`ui_focus_panel(panel_instance)`**
  - *Arguments:* panel_instance

- **`ui_focus_panel(panel_instance)`**
  - *Arguments:* panel_instance

- **`ui_open_panel(panel_type, data)`**
  - *Arguments:* panel_type, data

- **`ui_open_panel(panel_type, data = {})`**
  - *Arguments:* panel_type, data = {}


