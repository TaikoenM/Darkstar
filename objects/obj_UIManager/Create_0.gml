/// @description Initialize the UI Manager
/// @description Manages UI panels, focus, and layering
/// @description Works with ViewManager to display UI elements

// Make this manager persistent
persistent = true;

// Stack of active UI panels (for layering and focus management)
ui_panel_stack = ds_list_create();

// Currently focused panel (receives input)
focused_panel = noone;

// Mapping of panel types to instances
panel_instances = ds_map_create();

logger_write(LogLevel.INFO, "UIManager", "UI Manager created and initialized", "System startup");