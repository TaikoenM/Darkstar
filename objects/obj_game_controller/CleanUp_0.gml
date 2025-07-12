/// @description Clean up all systems on game exit

// Unregister observers
gamestate_remove_observer("unit_clicked", game_controller_handle_unit_click);
gamestate_remove_observer("unit_order_issued", game_controller_handle_unit_order);
gamestate_remove_observer("hex_clicked", game_controller_handle_hex_click);

// Save configuration
config_save();

// Clean up systems in reverse order
assets_cleanup();
gamestate_cleanup();

logger_write(LogLevel.INFO, "GameController", "Game shutdown complete", "All systems cleaned up");