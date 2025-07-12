/// @description Draw unit based on data

if (unit_data == undefined) exit;

// Check if we have a valid sprite - use fallback if not
var unit_sprite = -1;
if (variable_struct_exists(unit_data, "sprite_name")) {
    unit_sprite = assets_get_sprite_safe(unit_data.sprite_name);
}

// Draw unit sprite at visual position
if (unit_sprite != -1 && sprite_exists(unit_sprite)) {
    var faction_color = c_white;
    if (variable_struct_exists(unit_data, "faction_color")) {
        faction_color = unit_data.faction_color;
    }
    
    var sprite_index = 0;
    if (variable_struct_exists(unit_data, "sprite_index")) {
        sprite_index = unit_data.sprite_index;
    }
    
    draw_sprite_ext(
        unit_sprite,
        sprite_index,
        visual_x,
        visual_y,
        1, 1, 0,
        faction_color,
        1
    );
} else {
    // Fallback drawing - simple colored circle
    var faction_color = c_white;
    if (variable_struct_exists(unit_data, "faction_color")) {
        faction_color = unit_data.faction_color;
    }
    
    draw_set_color(faction_color);
    draw_circle(visual_x, visual_y, 16, false);
    draw_set_color(c_black);
    draw_circle(visual_x, visual_y, 16, true);
    draw_set_color(c_white);
}

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
    
    // Health - ensure we have valid health data
    if (variable_struct_exists(unit_data, "health") && variable_struct_exists(unit_data, "max_health")) {
        draw_set_alpha(health_bar_alpha);
        var health_percent = unit_data.health / unit_data.max_health;
        var health_color = (health_percent > 0.5) ? c_lime : (health_percent > 0.25) ? c_yellow : c_red;
        draw_set_color(health_color);
        draw_rectangle(visual_x - bar_width/2, bar_y, visual_x - bar_width/2 + (bar_width * health_percent), bar_y + bar_height, false);
    }
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}