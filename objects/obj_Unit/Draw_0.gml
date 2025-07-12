/// @description Draw unit based on data

if (unit_data == undefined) exit;

// Draw unit sprite at visual position
draw_sprite_ext(
    spr_units,
    unit_data.sprite_index,
    visual_x,
    visual_y,
    1, 1, 0,
    unit_data.faction_color,
    1
);

// Draw selection indicator
if (selected) {
    draw_set_color(c_lime);
    draw_circle(visual_x, visual_y, 32, true);
    draw_set_color(c_white);
}

// Draw health bar
if (health_bar_alpha > 0) {
    var bar_width = 48;
    var bar_height = 6;
    var bar_y = visual_y - 40;
    
    // Background
    draw_set_alpha(health_bar_alpha * 0.7);
    draw_set_color(c_black);
    draw_rectangle(visual_x - bar_width/2, bar_y, visual_x + bar_width/2, bar_y + bar_height, false);
    
    // Health
    draw_set_alpha(health_bar_alpha);
    var health_percent = unit_data.health / unit_data.max_health;
    var health_color = (health_percent > 0.5) ? c_lime : (health_percent > 0.25) ? c_yellow : c_red;
    draw_set_color(health_color);
    draw_rectangle(visual_x - bar_width/2, bar_y, visual_x - bar_width/2 + (bar_width * health_percent), bar_y + bar_height, false);
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}