/// @description Handle mouse release and notify observers
show_debug_message("mouse pressed on button")
if (enabled) {
	show_debug_message("mouse pressed on button - inside if")
    // Button was clicked - notify observers
    gamestate_notify_observers("button_clicked", {
        button_id: button_id,
        button_text: text,
        x: x,
        y: y
    });

}