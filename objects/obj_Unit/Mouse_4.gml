/// @description Handle unit selection

if (position_meeting(mouse_x, mouse_y, id)) {
    gamestate_notify_observers("unit_clicked", {
        unit_id: unit_id,
        shift_held: keyboard_check(vk_shift),
        ctrl_held: keyboard_check(vk_control),
        mouse_x: mouse_x,
        mouse_y: mouse_y
    });
}