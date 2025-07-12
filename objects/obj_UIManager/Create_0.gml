// @description Initialize the UI Manager
/// @description Manages UI elements and input focus
/// @description Simplified for native observer pattern

// Make this manager persistent
persistent = true;

// Currently focused element (receives input)
focused_panel = noone;

// Mapping of panel types to instances (for singleton panels)
panel_instances = ds_map_create();

logger_write(LogLevel.INFO, "UIManager", "UI Manager created and initialized", "System startup");