/// @description Handle mouse release and notify observers

if (is_hovered && is_pressed && enabled) {
    // Button was clicked - notify observers
    gamestate_notify_observers("button_clicked", {
        button_id: button_id,
        button_text: text,
        x: x,
        y: y
    });
    
    // Visual feedback
    is_pressed = false;
}