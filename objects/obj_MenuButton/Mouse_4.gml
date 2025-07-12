/// @description Handle mouse pressed and notify observers
if (enabled && is_hovered) {
    logger_write(LogLevel.DEBUG, "MenuButton", 
                string("Button clicked: {0}", button_id), 
                string("Text: {0}", text));
                
    // Button was clicked - notify observers
    gamestate_notify_observers("button_clicked", {
        button_id: button_id,
        button_text: text,
        x: x,
        y: y
    });
}