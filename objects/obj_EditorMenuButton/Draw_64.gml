/// @description Draw menu button and dropdown

// Draw button background
var button_color = color_normal;
if (is_open) {
    button_color = color_pressed;
} else if (hover) {
    button_color = color_hover;
}

draw_set_color(button_color);
draw_rectangle(gui_x, gui_y, gui_x + button_width, gui_y + button_height, false);

// Draw button text
if (font_exists(fnt_ui_medium)) {
    draw_set_font(fnt_ui_medium);
} else {
    draw_set_font(-1); // Use default font
}
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(color_text);
draw_text(gui_x + button_width / 2, gui_y + button_height / 2, menu_text);

// Draw dropdown arrow
var arrow_x = gui_x + button_width - 20;
var arrow_y = gui_y + button_height / 2;
draw_triangle(arrow_x - 4, arrow_y - 2, arrow_x + 4, arrow_y - 2, arrow_x, arrow_y + 4, false);

// Draw dropdown if open
if (is_open) {
    var dropdown_y = gui_y + button_height;
    var dropdown_height = editor_menu_get_dropdown_height();
    
    // Draw dropdown background
    draw_set_color(color_dropdown_bg);
    draw_rectangle(gui_x, dropdown_y, gui_x + dropdown_width, dropdown_y + dropdown_height, false);
    
    // Draw dropdown border
    draw_set_color(c_black);
    draw_rectangle(gui_x, dropdown_y, gui_x + dropdown_width, dropdown_y + dropdown_height, true);
    
    // Draw menu items
    var item_y = dropdown_y;
    draw_set_halign(fa_left);
    
    for (var i = 0; i < array_length(menu_items); i++) {
        var item = menu_items[i];
        
        if (item.type == "separator") {
            // Draw separator line
            draw_set_color(c_gray);
            draw_line(gui_x + 10, item_y + separator_height / 2, gui_x + dropdown_width - 10, item_y + separator_height / 2);
            item_y += separator_height;
        } else {
            // Draw item background if hovered
            if (i == hovered_item_index) {
                draw_set_color(color_dropdown_item_hover);
                draw_rectangle(gui_x, item_y, gui_x + dropdown_width, item_y + item_height, false);
            }
            
            // Draw checkbox if needed
            var text_x = gui_x + 10;
            if (item.type == "checkbox") {
                var check_size = 16;
                var check_x = text_x;
                var check_y = item_y + (item_height - check_size) / 2;
                
                draw_set_color(c_white);
                draw_rectangle(check_x, check_y, check_x + check_size, check_y + check_size, true);
                
                if (item.checked) {
                    // Draw checkmark
                    draw_line_width(check_x + 3, check_y + 8, check_x + 7, check_y + 12, 2);
                    draw_line_width(check_x + 7, check_y + 12, check_x + 13, check_y + 4, 2);
                }
                
                text_x += check_size + 8;
            }
            
            // Draw item text
            draw_set_color(item.enabled ? color_text : c_gray);
            draw_set_valign(fa_middle);
            draw_text(text_x, item_y + item_height / 2, item.text);
            
            // Draw shortcut if present
            if (item.shortcut != undefined) {
                draw_set_halign(fa_right);
                draw_set_color(c_gray);
                draw_text(gui_x + dropdown_width - 10, item_y + item_height / 2, item.shortcut);
                draw_set_halign(fa_left);
            }
            
            item_y += item_height;
        }
    }
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);