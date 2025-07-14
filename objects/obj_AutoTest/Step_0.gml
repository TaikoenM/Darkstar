/// @description Update display timer

if (display_visible) {
    display_timer -= (current_time - start_time);
    start_time = current_time;
    
    if (display_timer <= 0) {
        display_visible = false;
        // Optionally destroy the instance after hiding
        alarm[0] = 1; // Destroy after 1 frame
    }
}