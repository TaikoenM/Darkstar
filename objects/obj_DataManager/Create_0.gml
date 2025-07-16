// Create_0 Event
/// @description Load all game data from JSON files

// Make persistent
persistent = true;

logger_write(LogLevel.INFO, "DataManager", "Starting data loading", "System initialization");

// Initialize global data structures
global.unit_definitions = {};
global.building_definitions = {};
global.technology_definitions = {};
global.faction_definitions = {};
global.terrain_definitions = {};

// Initialize global.game_data if not exists
if (!variable_global_exists("game_data")) {
    global.game_data = {};
}

// Ensure data directory exists
var data_dir = working_directory + DATA_PATH;
if (!directory_exists(data_dir)) {
    try {
        directory_create(data_dir);
        logger_write(LogLevel.WARNING, "DataManager", "Data directory created", data_dir);
    } catch (error) {
        logger_write(LogLevel.ERROR, "DataManager", "Failed to create data directory", string(error));
    }
}

// Load Unit Types

var unittypes_file = data_dir + "UnitTypes.csv";
if (file_exists(unittypes_file)) {
    var unittypes_data = data_manager_load_unit_types(unittypes_file);
    if (!is_undefined(unittypes_data)) {
        global.game_data.unit_types = unittypes_data;
        logger_write(LogLevel.INFO, "DataManager", "Unit Types definitions loaded", 
                    string("Count: {0}", array_length(variable_struct_get_names(unittypes_data))));
					
    }
	else {
		show_error("Invalid UnitTypes.csv DATA FILE!", true)	
	}
} else {
	show_error("Missing UnitTypes.csv DATA FILE!", true)	
}



// Load unit definitions
var units_file = data_dir + "units.json";
if (file_exists(units_file)) {
    var units_data = json_load_file(units_file);
    if (!is_undefined(units_data)) {
        global.unit_definitions = units_data;
        logger_write(LogLevel.INFO, "DataManager", "Unit definitions loaded", 
                    string("Count: {0}", array_length(variable_struct_get_names(units_data))));
    }
} else {
    // Create default unit definitions
    data_manager_create_default_units();
}

// Load building definitions
var buildings_file = data_dir + "buildings.json";
if (file_exists(buildings_file)) {
    var buildings_data = json_load_file(buildings_file);
    if (!is_undefined(buildings_data)) {
        global.building_definitions = buildings_data;
        logger_write(LogLevel.INFO, "DataManager", "Building definitions loaded", 
                    string("Count: {0}", array_length(variable_struct_get_names(buildings_data))));
    }
} else {
    data_manager_create_default_buildings();
}

// Load technology definitions
var tech_file = data_dir + "technologies.json";
if (file_exists(tech_file)) {
    var tech_data = json_load_file(tech_file);
    if (!is_undefined(tech_data)) {
        global.technology_definitions = tech_data;
        logger_write(LogLevel.INFO, "DataManager", "Technology definitions loaded", 
                    string("Count: {0}", array_length(variable_struct_get_names(tech_data))));
    }
} else {
    data_manager_create_default_technologies();
}

// Load faction definitions
var factions_file = data_dir + "factions.json";
if (file_exists(factions_file)) {
    var factions_data = json_load_file(factions_file);
    if (!is_undefined(factions_data)) {
        global.faction_definitions = factions_data;
        logger_write(LogLevel.INFO, "DataManager", "Faction definitions loaded", 
                    string("Count: {0}", array_length(variable_struct_get_names(factions_data))));
    }
} else {
    data_manager_create_default_factions();
}

// Load terrain definitions
var terrain_file = data_dir + "terrain.json";
if (file_exists(terrain_file)) {
    var terrain_data = json_load_file(terrain_file);
    if (!is_undefined(terrain_data)) {
        global.terrain_definitions = terrain_data;
        logger_write(LogLevel.INFO, "DataManager", "Terrain definitions loaded", 
                    string("Count: {0}", array_length(variable_struct_get_names(terrain_data))));
    }
} else {
    data_manager_create_default_terrain();
}

logger_write(LogLevel.INFO, "DataManager", "All game data loaded successfully", "Data initialization complete");