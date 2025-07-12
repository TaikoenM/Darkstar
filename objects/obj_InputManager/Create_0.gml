/// @description Initialize the Input Manager
/// @description Translates raw hardware input into abstract game commands
/// @description Part of the Controller layer in MVC architecture

// Make this manager persistent
persistent = true;

// Initialize the input system
input_init();

logger_write(LogLevel.INFO, "InputManager", "Input Manager created and initialized", "System startup");