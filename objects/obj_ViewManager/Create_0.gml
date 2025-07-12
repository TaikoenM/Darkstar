/// @description Initialize the View Manager
/// @description Coordinates visual instances and synchronizes with GameState
/// @description Part of the View layer in MVC architecture

// Make this manager persistent
persistent = true;

// Mapping from data IDs to visual instance IDs
data_to_view_map = ds_map_create();

// Current view mode (starmap, planet, etc.)
current_view_mode = "main_menu";

// Camera control variables
camera_x = 0;
camera_y = 0;
camera_zoom = 1.0;
camera_target_x = 0;
camera_target_y = 0;
camera_target_zoom = 1.0;
camera_speed = 0.1;

logger_write(LogLevel.INFO, "ViewManager", "View Manager created and initialized", "System startup");