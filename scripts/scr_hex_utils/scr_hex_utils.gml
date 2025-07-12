/// @description Hex utility functions for axial coordinate system
/// @description Provides conversion, distance, and pathfinding functions for hexagonal grids

/// @function hex_pixel_to_axial(px, py)
/// @description Convert pixel coordinates to axial hex coordinates
/// @param {real} px X position in pixels
/// @param {real} py Y position in pixels
/// @return {struct} Struct with q and r axial coordinates
function hex_pixel_to_axial(px, py) {
    // Default hex size - should be configurable
    var hex_size = 32;
    
    // Get hex size from config if available
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "hex") && 
            variable_struct_exists(global.game_options.hex, "size")) {
            hex_size = global.game_options.hex.size;
        }
    }
    
    // Convert pixel to axial coordinates
    var q = (sqrt(3)/3 * px - 1/3 * py) / hex_size;
    var r = (2/3 * py) / hex_size;
    
    return hex_round(q, r);
}

/// @function hex_axial_to_pixel(q, r)
/// @description Convert axial hex coordinates to pixel coordinates
/// @param {real} q Axial q coordinate
/// @param {real} r Axial r coordinate
/// @return {struct} Struct with x and y pixel coordinates
function hex_axial_to_pixel(q, r) {
    // Default hex size - should be configurable
    var hex_size = 32;
    
    // Get hex size from config if available
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "hex") && 
            variable_struct_exists(global.game_options.hex, "size")) {
            hex_size = global.game_options.hex.size;
        }
    }
    
    var pixel_x = hex_size * (sqrt(3) * q + sqrt(3)/2 * r);
    var pixel_y = hex_size * (3/2 * r);
    
    return {
        x: pixel_x,
        y: pixel_y
    };
}

/// @function hex_round(q, r)
/// @description Round fractional hex coordinates to nearest valid hex
/// @param {real} q Fractional q coordinate
/// @param {real} r Fractional r coordinate
/// @return {struct} Struct with integer q and r coordinates
function hex_round(q, r) {
    var s = -q - r;
    
    var round_q = round(q);
    var round_r = round(r);
    var round_s = round(s);
    
    var q_diff = abs(round_q - q);
    var r_diff = abs(round_r - r);
    var s_diff = abs(round_s - s);
    
    if (q_diff > r_diff && q_diff > s_diff) {
        round_q = -round_r - round_s;
    } else if (r_diff > s_diff) {
        round_r = -round_q - round_s;
    }
    
    return {
        q: round_q,
        r: round_r
    };
}

/// @function hex_distance(q1, r1, q2, r2)
/// @description Calculate distance between two hex coordinates
/// @param {real} q1 First hex q coordinate
/// @param {real} r1 First hex r coordinate
/// @param {real} q2 Second hex q coordinate
/// @param {real} r2 Second hex r coordinate
/// @return {real} Distance in hex tiles
function hex_distance(q1, r1, q2, r2) {
    return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2;
}

/// @function hex_neighbors(q, r)
/// @description Get all six neighboring hex coordinates
/// @param {real} q Center hex q coordinate
/// @param {real} r Center hex r coordinate
/// @return {Array<Struct>} Array of neighbor coordinate structs
function hex_neighbors(q, r) {
    var directions = [
        {q: 1, r: 0}, {q: 1, r: -1}, {q: 0, r: -1},
        {q: -1, r: 0}, {q: -1, r: 1}, {q: 0, r: 1}
    ];
    
    var neighbors = [];
    for (var i = 0; i < array_length(directions); i++) {
        array_push(neighbors, {
            q: q + directions[i].q,
            r: r + directions[i].r
        });
    }
    
    return neighbors;
}

/// @function hex_line(q1, r1, q2, r2)
/// @description Get line of hexes between two coordinates
/// @param {real} q1 Start hex q coordinate
/// @param {real} r1 Start hex r coordinate
/// @param {real} q2 End hex q coordinate
/// @param {real} r2 End hex r coordinate
/// @return {Array<Struct>} Array of hex coordinates along the line
function hex_line(q1, r1, q2, r2) {
    var distance = hex_distance(q1, r1, q2, r2);
    var results = [];
    
    if (distance == 0) {
        array_push(results, {q: q1, r: r1});
        return results;
    }
    
    for (var i = 0; i <= distance; i++) {
        var t = i / distance;
        var lerp_q = q1 * (1 - t) + q2 * t;
        var lerp_r = r1 * (1 - t) + r2 * t;
        var rounded = hex_round(lerp_q, lerp_r);
        array_push(results, rounded);
    }
    
    return results;
}

/// @function hex_ring(center_q, center_r, radius)
/// @description Get ring of hexes at specified radius from center
/// @param {real} center_q Center hex q coordinate
/// @param {real} center_r Center hex r coordinate
/// @param {real} radius Ring radius
/// @return {Array<Struct>} Array of hex coordinates in the ring
function hex_ring(center_q, center_r, radius) {
    if (radius == 0) {
        return [{q: center_q, r: center_r}];
    }
    
    var results = [];
    var directions = [
        {q: 1, r: 0}, {q: 1, r: -1}, {q: 0, r: -1},
        {q: -1, r: 0}, {q: -1, r: 1}, {q: 0, r: 1}
    ];
    
    // Start at the first vertex of the ring
    var hex_q = center_q + directions[4].q * radius;
    var hex_r = center_r + directions[4].r * radius;
    
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < radius; j++) {
            array_push(results, {q: hex_q, r: hex_r});
            hex_q += directions[i].q;
            hex_r += directions[i].r;
        }
    }
    
    return results;
}

/// @function hex_spiral(center_q, center_r, radius)
/// @description Get all hexes within radius of center (including center)
/// @param {real} center_q Center hex q coordinate
/// @param {real} center_r Center hex r coordinate
/// @param {real} radius Maximum radius
/// @return {Array<Struct>} Array of all hex coordinates within radius
function hex_spiral(center_q, center_r, radius) {
    var results = [];
    
    for (var k = 0; k <= radius; k++) {
        var ring = hex_ring(center_q, center_r, k);
        for (var i = 0; i < array_length(ring); i++) {
            array_push(results, ring[i]);
        }
    }
    
    return results;
}

/// @function hex_to_string(q, r)
/// @description Convert hex coordinates to string representation
/// @param {real} q Hex q coordinate
/// @param {real} r Hex r coordinate
/// @return {string} String representation of coordinates
function hex_to_string(q, r) {
    return string("({0},{1})", q, r);
}

/// @function hex_from_string(hex_string)
/// @description Parse hex coordinates from string representation
/// @param {string} hex_string String in format "(q,r)"
/// @return {struct|undefined} Hex coordinates or undefined if invalid
function hex_from_string(hex_string) {
    // Remove parentheses and split by comma
    var clean_string = string_replace_all(hex_string, "(", "");
    clean_string = string_replace_all(clean_string, ")", "");
    
    var parts = string_split(clean_string, ",");
    if (array_length(parts) != 2) {
        return undefined;
    }
    
    var q_val = real(parts[0]);
    var r_val = real(parts[1]);
    
    return {q: q_val, r: r_val};
}