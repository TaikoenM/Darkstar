/// @description Clean up editor resources

// Unregister all editor observers
gamestate_remove_observer(EVENT_EDITOR_HEX_CLICKED, editor_handle_hex_click);
gamestate_remove_observer(EVENT_EDITOR_BUTTON_CLICKED, editor_handle_button_click);
gamestate_remove_observer(EVENT_EDITOR_QUICK_SLOT_CLICKED, editor_handle_quick_slot);
gamestate_remove_observer(EVENT_EDITOR_MINIMAP_CLICKED, editor_handle_minimap_click);
gamestate_remove_observer(EVENT_EDITOR_DROPDOWN_CHANGED, editor_handle_dropdown);
gamestate_remove_observer(EVENT_EDITOR_MENU_ITEM_CLICKED, editor_handle_menu_click);

// Clean up editor data structures
editor_cleanup_data();