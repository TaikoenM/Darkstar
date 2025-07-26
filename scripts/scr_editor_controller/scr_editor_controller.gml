/// @function editor_init()
/// @description Initializes the entire planet editor state.
function editor_init() {
    global.editor_state = {
        planet_data: {
            metadata: {
                filename: "untitled.planet",
                name: "New Planet",
                size_x: 60,
                size_y: 40,
                wraps_horizontal: true, // Added for clarity
            },
            hexes: ds_map_create(), // Key: "q,r"
        },
        camera: {} // Will be initialized by camera script
    };

    // Populate the planet with default water hexes
    for (var r = 0; r < global.editor_state.planet_data.metadata.size_y; r++) {
        for (var q = 0; q < global.editor_state.planet_data.metadata.size_x; q++) {
            var hex_key = string(q) + "," + string(r);
            var hex_data = {
                terrain_type: "water",
            };
            ds_map_add(global.editor_state.planet_data.hexes, hex_key, hex_data);
        }
    }

    editor_camera_init();
}

/// @function editor_create_full_hex_grid()
/// @description Creates instances for the map, including "ghost" instances for horizontal wrapping.
function editor_create_full_hex_grid() {
    var meta = global.editor_state.planet_data.metadata;
    var hex_height = EDITOR_HEX_HEIGHT;
    var hex_width = hex_height * (2 / sqrt(3));
    
    // CORRECTED: This calculation must match the new horizontal spacing
    var map_pixel_width = meta.size_x * (hex_width * 0.75);

    for (var r = 0; r < meta.size_y; r++) {
        for (var q = 0; q < meta.size_x; q++) {
            var pos = editor_hex_axial_to_pixel(q, r);
            var inst = instance_create_layer(pos.x, pos.y, "Instances", obj_EditorHex);
            inst.hex_q = q;
            inst.hex_r = r;

            if (meta.wraps_horizontal) {
                var ghost_left = instance_create_layer(pos.x - map_pixel_width, pos.y, "Instances", obj_EditorHex);
                ghost_left.hex_q = q;
                ghost_left.hex_r = r;
                
                var ghost_right = instance_create_layer(pos.x + map_pixel_width, pos.y, "Instances", obj_EditorHex);
                ghost_right.hex_q = q;
                ghost_right.hex_r = r;
            }
        }
    }
}