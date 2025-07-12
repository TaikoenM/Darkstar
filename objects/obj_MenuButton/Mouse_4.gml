/// @description Handle mouse pressed and notify observers
if (enabled && is_hovered) {
    logger_write(LogLevel.DEBUG, "MenuButton", 
                string("Button clicked: ID={0}, Text={1}", button_id, text), 
                "User interaction");
                
    // Button was clicked - notify observers
    gamestate_notify_observers(EVENT_BUTTON_CLICKED, {
        button_id: button_id,
        button_text: text,
        x: x,
        y: y
    });
}