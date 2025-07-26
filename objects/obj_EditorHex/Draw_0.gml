var hex_key = string(hex_q) + "," + string(hex_r);
var hex_data = global.editor_state.planet_data.hexes[? hex_key];

if (!is_undefined(hex_data)) {
    // For now, only draw water. The object's sprite will be used.
    draw_self(); 
}