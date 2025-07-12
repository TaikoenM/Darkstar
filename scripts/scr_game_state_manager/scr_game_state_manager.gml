/// @description Game state management system for actual game data
/// @description Holds all game data: units, planets, factions, resources, etc.
/// @description This is the single source of truth for all game data

/// @description Initialize the game state management system
function gamestate_init() {
    // Initialize observer system first
    gamestate_observer_init();
    
    // Create the master game state structure
    global.game_state = {
        // Game metadata
        version: "1.0.0",
        turn_number: 0,
        current_player: 0,
        
        // Core game data
        planets: {},        // Planet ID -> Planet data
        units: {},          // Unit ID -> Unit data
        factions: {},       // Faction ID -> Faction data
        technologies: {},   // Tech ID -> Tech data
        
        // Galaxy data
        wormholes: [],      // Wormhole connections between planets
        trade_routes: [],   // Trade route definitions
        
        // Political system
        imperial_court: {
            current_regent: -1,
            next_election_turn: 10,
            votes: {}
        },
        
        // Selection and UI state (temporary, not saved)
        selected_units: [],
        selected_planet: -1,
        camera_position: {x: 0, y: 0}
    };
    
    // ID counters for generating unique IDs
    global.next_unit_id = 1;
    global.next_planet_id = 1;
    global.next_city_id = 1;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateManager", "Game state manager initialized", "System startup");
    }
}

/// @description Get a unit from the game state
/// @param {string} unit_id Unit identifier
/// @return {struct|undefined} Unit data struct or undefined if not found
function gamestate_get_unit(unit_id) {
    if (variable_struct_exists(global.game_state.units, unit_id)) {
        return global.game_state.units[$ unit_id];
    }
    return undefined;
}

/// @description Add a unit to the game state
/// @param {struct} unit_data Unit data structure
/// @return {string} Unit ID
function gamestate_add_unit(unit_data) {
    var unit_id = "unit_" + string(global.next_unit_id++);
    unit_data.id = unit_id;
    global.game_state.units[$ unit_id] = unit_data;
    
    // Notify observers
    gamestate_notify_observers("unit_created", {
        unit_id: unit_id,
        unit_data: unit_data
    });
    
    return unit_id;
}

/// @description Remove a unit from the game state
/// @param {string} unit_id Unit identifier
function gamestate_remove_unit(unit_id) {
    if (variable_struct_exists(global.game_state.units, unit_id)) {
        var unit_data = global.game_state.units[$ unit_id];
        variable_struct_remove(global.game_state.units, unit_id);
        
        // Remove from selection if selected
        var selection_index = array_find_index(global.game_state.selected_units, 
            function(element, index) { return element == unit_id; });
        if (selection_index >= 0) {
            array_delete(global.game_state.selected_units, selection_index, 1);
        }
        
        // Notify observers
        gamestate_notify_observers("unit_destroyed", {
            unit_id: unit_id,
            unit_data: unit_data
        });
    }
}

/// @description Get a planet from the game state
/// @param {string} planet_id Planet identifier
/// @return {struct|undefined} Planet data struct or undefined if not found
function gamestate_get_planet(planet_id) {
    if (variable_struct_exists(global.game_state.planets, planet_id)) {
        return global.game_state.planets[$ planet_id];
    }
    return undefined;
}

/// @description Add a planet to the game state
/// @param {struct} planet_data Planet data structure
/// @return {string} Planet ID
function gamestate_add_planet(planet_data) {
    var planet_id = "planet_" + string(global.next_planet_id++);
    planet_data.id = planet_id;
    global.game_state.planets[$ planet_id] = planet_data;
    
    // Notify observers
    gamestate_notify_observers("planet_created", {
        planet_id: planet_id,
        planet_data: planet_data
    });
    
    return planet_id;
}

/// @description Get a faction from the game state
/// @param {string} faction_id Faction identifier
/// @return {struct|undefined} Faction data struct or undefined if not found
function gamestate_get_faction(faction_id) {
    if (variable_struct_exists(global.game_state.factions, faction_id)) {
        return global.game_state.factions[$ faction_id];
    }
    return undefined;
}

/// @description Select a unit
/// @param {string} unit_id Unit to select
/// @param {bool} add_to_selection Whether to add to existing selection
function gamestate_select_unit(unit_id, add_to_selection = false) {
    if (!add_to_selection) {
        global.game_state.selected_units = [];
    }
    
    // Check if unit exists and isn't already selected
    if (variable_struct_exists(global.game_state.units, unit_id)) {
        var already_selected = array_find_index(global.game_state.selected_units,
            function(element, index) { return element == unit_id; }) >= 0;
            
        if (!already_selected) {
            array_push(global.game_state.selected_units, unit_id);
            
            // Notify observers
            gamestate_notify_observers("unit_selected", {
                unit_id: unit_id,
                selection: global.game_state.selected_units
            });
        }
    }
}

/// @description Clear unit selection
function gamestate_clear_selection() {
    global.game_state.selected_units = [];
    gamestate_notify_observers("selection_cleared", {});
}

/// @description Serialize game state for saving
/// @return {string} JSON string of game state
function gamestate_serialize() {
    // Create a copy without temporary UI state
    var save_state = {
        version: global.game_state.version,
        turn_number: global.game_state.turn_number,
        current_player: global.game_state.current_player,
        planets: global.game_state.planets,
        units: global.game_state.units,
        factions: global.game_state.factions,
        technologies: global.game_state.technologies,
        wormholes: global.game_state.wormholes,
        trade_routes: global.game_state.trade_routes,
        imperial_court: global.game_state.imperial_court,
        
        // Save ID counters
        next_unit_id: global.next_unit_id,
        next_planet_id: global.next_planet_id,
        next_city_id: global.next_city_id
    };
    
    return json_stringify(save_state);
}

/// @description Deserialize game state from save
/// @param {string} json_string JSON string of saved game state
/// @return {bool} True if successful
function gamestate_deserialize(json_string) {
    try {
        var loaded_state = json_parse(json_string);
        
        // Restore game state
        global.game_state.version = loaded_state.version;
        global.game_state.turn_number = loaded_state.turn_number;
        global.game_state.current_player = loaded_state.current_player;
        global.game_state.planets = loaded_state.planets;
        global.game_state.units = loaded_state.units;
        global.game_state.factions = loaded_state.factions;
        global.game_state.technologies = loaded_state.technologies;
        global.game_state.wormholes = loaded_state.wormholes;
        global.game_state.trade_routes = loaded_state.trade_routes;
        global.game_state.imperial_court = loaded_state.imperial_court;
        
        // Restore ID counters
        global.next_unit_id = loaded_state.next_unit_id;
        global.next_planet_id = loaded_state.next_planet_id;
        global.next_city_id = loaded_state.next_city_id;
        
        // Clear temporary state
        global.game_state.selected_units = [];
        global.game_state.selected_planet = -1;
        
        // Notify observers
        gamestate_notify_observers("game_loaded", {});
        
        return true;
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "GameStateManager", 
                        "Failed to deserialize game state", string(error));
        }
        return false;
    }
}

/// @description Cleanup the game state manager
function gamestate_cleanup() {
    // Clean up observer system
    gamestate_observer_cleanup();
    
    // Clear game state
    global.game_state = undefined;
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "GameStateManager", "Game state manager cleaned up", "System shutdown");
    }
}