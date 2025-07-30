/// @function editor_init()
/// @description Complete editor initialization with all necessary properties
function editor_init() {
    global.editor_state = {
        // Planet data
        planet_data: {
            metadata: {
                filename: "untitled.planet",
                name: "New Planet",
                description: "",
                icon_sprite: "spr_planet_icon_temperate",
                size_x: 60,
                size_y: 40,
                wraps_horizontal: true,
                global_features: {
                    gravity: 1.0,
                    atmosphere: "breathable",
                    temperature: "temperate"
                }
            },
            hexes: ds_map_create(), // Key: "q,r"
            buildings: ds_map_create(),
            units: ds_map_create(),
            unit_stacks: ds_map_create()
        },
        
        // Camera state (initialized by editor_camera_init)
        camera: {},
        
        // View settings - REQUIRED for UI
        view_flags: {
            show_grid: true,
            show_coordinates: false,
            show_resources: true,
            show_features: true,
            show_buildings: true,
            show_units: true,
            show_faction_borders: false
        },
        
        // Tool and selection state
        current_tool: "paint_terrain",
        current_layer: "terrain",
        selected_terrain: "water",
        selected_feature: "none",
        selected_building: "city",
        selected_unit: "infantry",
        selected_faction: 0,
        paint_faction: 1,
        
        // UI state
        quick_slots: array_create(12, undefined),
        active_slot: -1,
        pipette_target_slot: -1,
        
        // Selection state
        selected_hex: {q: -1, r: -1},
        locked_selection: false,
        
        // History for undo/redo
        command_history: ds_list_create(),
        history_index: -1,
        max_history: 100,
        
        // Performance optimization
        dirty_regions: ds_list_create()
    };

    // Initialize quick slots with default items
    global.editor_state.quick_slots[0] = {type: "terrain", value: "plains"};
    global.editor_state.quick_slots[1] = {type: "terrain", value: "forest"};
    global.editor_state.quick_slots[2] = {type: "terrain", value: "mountains"};
    global.editor_state.quick_slots[3] = {type: "terrain", value: "water"};

    // Populate the planet with default water hexes
    for (var r = 0; r < global.editor_state.planet_data.metadata.size_y; r++) {
        for (var q = 0; q < global.editor_state.planet_data.metadata.size_x; q++) {
            var hex_key = string(q) + "," + string(r);
            var hex_data = {
                terrain_type: "water",
                terrain_feature: "none",
                resource_type: "none",
                resource_amount: 0,
                faction_owner: -1,
                building_type: "none",
                building_faction: -1
            };
            ds_map_add(global.editor_state.planet_data.hexes, hex_key, hex_data);
        }
    }

    // Initialize camera
    editor_camera_init();
    
    // Log successful initialization
    if (variable_global_exists("logger_write")) {
        logger_write(LogLevel.INFO, "Editor", "Editor initialized", 
                    string("Planet size: {0}x{1}", 
                          global.editor_state.planet_data.metadata.size_x,
                          global.editor_state.planet_data.metadata.size_y));
    }
}

/// @function editor_cleanup_data()
/// @description Clean up editor data structures
function editor_cleanup_data() {
    if (variable_global_exists("editor_state")) {
        // Clean up data structures
        if (ds_exists(global.editor_state.planet_data.hexes, ds_type_map)) {
            ds_map_destroy(global.editor_state.planet_data.hexes);
        }
        if (ds_exists(global.editor_state.planet_data.buildings, ds_type_map)) {
            ds_map_destroy(global.editor_state.planet_data.buildings);
        }
        if (ds_exists(global.editor_state.planet_data.units, ds_type_map)) {
            ds_map_destroy(global.editor_state.planet_data.units);
        }
        if (ds_exists(global.editor_state.planet_data.unit_stacks, ds_type_map)) {
            ds_map_destroy(global.editor_state.planet_data.unit_stacks);
        }
        if (ds_exists(global.editor_state.command_history, ds_type_list)) {
            ds_list_destroy(global.editor_state.command_history);
        }
        if (ds_exists(global.editor_state.dirty_regions, ds_type_list)) {
            ds_list_destroy(global.editor_state.dirty_regions);
        }
    }
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