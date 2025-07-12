/// @function unit_factory_create(unit_type, faction, hex_q, hex_r)
/// @description Create a new unit and add it to the game state
/// @param {string} unit_type Unit type from data definitions
/// @param {Constant.Faction} faction Faction that owns the unit
/// @param {real} hex_q Hex coordinate Q
/// @param {real} hex_r Hex coordinate R
/// @return {string} Unit ID or empty string on failure
function unit_factory_create(unit_type, faction, hex_q, hex_r) {
    // Get unit definition from loaded data
    var unit_def = data_manager_get_unit_definition(unit_type);
    if (is_undefined(unit_def)) {
        logger_write(LogLevel.ERROR, "UnitFactory", "Unit type not found in definitions", unit_type);
        return "";
    }
    
    // Get faction definition for color
    var faction_color = c_white;
    var faction_names = variable_struct_get_names(global.faction_definitions);
    for (var i = 0; i < array_length(faction_names); i++) {
        var faction_def = global.faction_definitions[$ faction_names[i]];
        if (variable_struct_exists(faction_def, "faction_id") && faction_def.faction_id == faction) {
            if (variable_struct_exists(faction_def, "color")) {
                faction_color = faction_def.color;
            }
            break;
        }
    }
    
    // If no faction definition found, use default colors
    if (faction_color == c_white) {
        switch (faction) {
            case Faction.PLAYER_1: faction_color = c_blue; break;
            case Faction.PLAYER_2: faction_color = c_red; break;
            case Faction.PLAYER_3: faction_color = c_green; break;
            case Faction.PLAYER_4: faction_color = c_yellow; break;
            case Faction.IMPERIAL: faction_color = c_purple; break;
            case Faction.REBEL: faction_color = c_orange; break;
        }
    }
    
    var pixel_coords = hex_axial_to_pixel(hex_q, hex_r);
    
    // Create unit data from definition
    var unit_data = {
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
    
    // Add to game state
    var unit_id = gamestate_add_unit(unit_data);
    
    // Create visual instance
    var unit_instance = instance_create_layer(pixel_coords.x, pixel_coords.y, "Instances", obj_Unit);
    if (instance_exists(unit_instance)) {
        unit_instance.unit_id = unit_id;
        unit_instance.unit_data = unit_data;
        
        logger_write(LogLevel.INFO, "UnitFactory", 
                    string("Created unit: {0}", unit_id), 
                    string("Type: {0}, Faction: {1}, Hex: ({2},{3})", unit_def.name, faction, hex_q, hex_r));
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