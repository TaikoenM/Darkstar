/// @function unit_factory_create(unit_type, faction, hex_q, hex_r)
/// @description Create a new unit and add it to the game state
/// @param {string} unit_type Unit type from data definitions
/// @param {Constant.Faction} faction Faction that owns the unit
/// @param {real} hex_q Hex coordinate Q
/// @param {real} hex_r Hex coordinate R
/// @return {string} Unit ID or empty string on failure
function unit_factory_create(unit_type, faction, hex_q, hex_r) {
    // First try to get unit definition from CSV data
    var unit_def = data_manager_get_unit_type_from_csv(unit_type);
    var use_csv_data = false;
    
    if (!is_undefined(unit_def)) {
        logger_write(LogLevel.DEBUG, "UnitFactory", "Using CSV data for unit type", unit_type);
        use_csv_data = true;
    } else {
        // Fall back to JSON definitions
        unit_def = data_manager_get_unit_definition(unit_type);
        if (is_undefined(unit_def)) {
            logger_write(LogLevel.ERROR, "UnitFactory", "Unit type not found in definitions", unit_type);
            return "";
        }
    }
    
    // Get faction definition for color
    var faction_color = c_white;
    var faction_def = undefined;
    
    // Find faction definition that matches the enum
    switch (faction) {
        case Faction.PLAYER_1:
            faction_def = data_manager_get_faction_definition("hawkwood");
            break;
        case Faction.PLAYER_2:
            faction_def = data_manager_get_faction_definition("decados");
            break;
        case Faction.PLAYER_3:
            faction_def = data_manager_get_faction_definition("li_halan");
            break;
        case Faction.IMPERIAL:
            faction_def = data_manager_get_faction_definition("church");
            break;
        case Faction.MERCANTILE:
            faction_def = data_manager_get_faction_definition("merchants");
            break;
    }
    
    if (!is_undefined(faction_def) && variable_struct_exists(faction_def, "color")) {
        faction_color = faction_def.color;
    } else {
        // Use default colors
        switch (faction) {
            case Faction.PLAYER_1: faction_color = c_blue; break;
            case Faction.PLAYER_2: faction_color = c_red; break;
            case Faction.PLAYER_3: faction_color = c_green; break;
            case Faction.PLAYER_4: faction_color = c_yellow; break;
            case Faction.IMPERIAL: faction_color = c_purple; break;
            case Faction.REBEL: faction_color = c_orange; break;
            default: faction_color = c_white; break;
        }
    }
    
    var pixel_coords = hex_axial_to_pixel(hex_q, hex_r);
    
    // Create unit data from definition
    var unit_data = {};
    
    if (use_csv_data) {
        // Create from CSV data - only use what's actually in the CSV
        unit_data = {
            type: unit_type,
            name: variable_struct_exists(unit_def, "Name") ? unit_def.Name : unit_type,
            faction: faction,
            hex_q: hex_q,
            hex_r: hex_r,
            x: pixel_coords.x,
            y: pixel_coords.y,
            // Copy all CSV properties
            csv_data: unit_def,
            // Visual properties
            sprite_name: "unit_" + string_lower(unit_type),
            faction_color: faction_color
        };
        
        // If the CSV has enum columns, parse them
        var enum_mappings = {
            "UseRoads": "Unit_UseRoads",
            "UseTransportTubes": "Unit_UseTransportTubes",
            "SurviveInSpace": "Unit_SurviveInSpace",
            "Planetfall": "Unit_Planetfall",
            "LaunchToSpace": "Unit_LaunchToSpace",
            "FuelType": "Unit_FuelType",
            "Refuel": "Unit_Refuel"
        };
        
        var enum_names = variable_struct_get_names(enum_mappings);
        for (var i = 0; i < array_length(enum_names); i++) {
            var csv_column = enum_names[i];
            var enum_type = enum_mappings[$ csv_column];
            
            if (variable_struct_exists(unit_def, csv_column)) {
                var string_value = string(unit_def[$ csv_column]);
                var enum_value = csv_parse_enum_value(string_value, enum_type);
                if (enum_value != -1) {
                    unit_data[$ string_lower(csv_column)] = enum_value;
                }
            }
        }
        
    } else {
        // Create from JSON data (legacy)
        unit_data = {
            type: unit_type,
            name: unit_def.name,
            faction: faction,
            hex_q: hex_q,
            hex_r: hex_r,
            x: pixel_coords.x,
            y: pixel_coords.y,
            health: unit_def.stats.health,
            max_health: unit_def.stats.health,
            movement: unit_def.stats.movement,
            movement_remaining: unit_def.stats.movement,
            attack: unit_def.stats.attack,
            defense: unit_def.stats.defense,
            range: unit_def.stats.range,
            experience: 0,
            level: 1,
            abilities: unit_def.abilities,
            sprite_name: "unit_" + string_lower(unit_type),
            faction_color: faction_color
        };
    }
    
    // Add to game state
    var unit_id = gamestate_add_unit(unit_data);
    
    // Create visual instance
    var unit_instance = instance_create_layer(pixel_coords.x, pixel_coords.y, "Instances", obj_Unit);
    if (instance_exists(unit_instance)) {
        unit_instance.unit_id = unit_id;
        unit_instance.unit_data = unit_data;
        
        logger_write(LogLevel.INFO, "UnitFactory", 
                    string("Created unit: {0}", unit_id), 
                    string("Type: {0}, Faction: {1}, Hex: ({2},{3})", unit_data.name, faction, hex_q, hex_r));
    } else {
        // Failed to create instance, remove from game state
        gamestate_remove_unit(unit_id);
        logger_write(LogLevel.ERROR, "UnitFactory", "Failed to create unit instance", "Instance creation failed");
        return "";
    }
    
    return unit_id;
}

/// @function game_controller_handle_unit_click(event_data)
/// @description Handle unit selection events
/// @param {struct} event_data Contains unit_id, modifiers
function game_controller_handle_unit_click(event_data) {
    var unit_id = event_data.unit_id;
    var shift_held = event_data.shift_held;
    var ctrl_held = event_data.ctrl_held;
    
    // Create appropriate command based on modifiers
    var cmd_type = CommandType.SELECT_UNIT;
    var cmd_data = { unit_id: unit_id };
    
    if (shift_held) {
        cmd_type = CommandType.ADD_TO_SELECTION;
    } else if (ctrl_held) {
        cmd_type = CommandType.TOGGLE_SELECTION;
    }
    
    // Queue command for processing
    var cmd = input_create_command(cmd_type, cmd_data);
    input_queue_command(cmd);
}

/// @function game_controller_handle_unit_order(event_data)  
/// @description Handle unit order events
/// @param {struct} event_data Contains unit_id, order_type, target coordinates
function game_controller_handle_unit_order(event_data) {
    var cmd = input_create_command(CommandType.UNIT_ORDER, {
        unit_id: event_data.unit_id,
        order_type: event_data.order_type,
        target_q: event_data.target_q,
        target_r: event_data.target_r
    });
    
    input_queue_command(cmd);
}

/// @function game_controller_handle_hex_click(event_data)
/// @description Handle hex tile interactions
/// @param {struct} event_data Contains hex coordinates, mouse button
function game_controller_handle_hex_click(event_data) {
    // Determine action based on current state and click type
    var current_state = scenestate_get();
    
    if (current_state == SceneState.MAP_EDITOR) {
        // Get editor selected tile type - provide default if not set
        var selected_tile = TerrainType.PLAINS; // Default terrain type
        if (variable_global_exists("editor_selected_tile")) {
            selected_tile = global.editor_selected_tile;
        }
        
        var cmd = input_create_command(CommandType.EDITOR_PLACE, {
            q: event_data.q,
            r: event_data.r,
            tile_type: selected_tile
        });
        input_queue_command(cmd);
    }
}