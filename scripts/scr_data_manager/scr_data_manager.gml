/// @description Data manager functions for loading game data from external files

// Initialize global game data structure
if (!variable_global_exists("game_data")) {
    global.game_data = {};
}

#region enums
// Enums for unit properties
enum Unit_UseRoads {
    NO,
    YES
}

enum Unit_UseTransportTubes {
    NO,
    YES
}

enum Unit_SurviveInSpace {
    NO,
    TEMPORARY,
    YES,
    SPACE_ONLY
}

enum Unit_Planetfall {
    NEVER,
    SPACEPORT,
    BUILDING,
    ANYWHERE
}

enum Unit_LaunchToSpace {
    NEVER,
    SPACEPORT,
    ANYWHERE
}

enum Unit_FuelType {
    NOTHING,
    USED_PER_MOVE,
    USED_PER_TURN
}

enum Unit_Refuel {
    NOWHERE,
    MILITARY_BUILDINGS,
    CIVILIAN_BUILDINGS,
    ANYWHERE    
}




/// @function variable_struct_names_count(struct)
/// @description Get the number of variables in a struct
/// @param {struct} struct The struct to count
/// @return {real} Number of variables in the struct
function variable_struct_names_count(struct) {
    return array_length(variable_struct_get_names(struct));
}

/// @function csv_parse_file(filepath, has_headers)
/// @description Generic CSV parser that reads a CSV file and returns structured data
/// @param {string} filepath Path to the CSV file
/// @param {bool} has_headers Whether the first non-comment row contains headers
/// @return {struct} Parsed CSV data with headers array and rows array
function csv_parse_file(filepath, has_headers = true) {
    logger_write(LogLevel.DEBUG, "DataManager", "Starting CSV parse", string("File: {0}", filepath));
	
    // Check if file exists
    if (!file_exists(filepath)) {
        logger_write(LogLevel.ERROR, "DataManager", "CSV file not found", filepath);
        show_message_async("Error: CSV file not found - " + filepath);
        game_end();
        return undefined;
    }
    
    var result = {
        headers: [],
        rows: []
    };
    
    try {
        // Read file content
        var file = file_text_open_read(filepath);
        var line_number = 0;
        var headers_read = false;
        
        while (!file_text_eof(file)) {
            var line = file_text_read_string(file);
            file_text_readln(file);
			
            line_number++;
            
            // Skip empty lines
            if (string_length(string_trim(line)) == 0) {
                continue;
            }
            
            // Skip comment lines
            if (string_pos("//", line) == 1) {
                logger_write(LogLevel.DEBUG, "DataManager", "Skipping comment line", 
                            string("Line {0}: {1}", line_number, line));
                continue;
            }
            
            // Parse CSV line using string_split
            var values = string_split(line, ",");
            
            // Trim whitespace from each value
            for (var i = 0; i < array_length(values); i++) {
                values[i] = string_trim(values[i]);
            }
            
            // Handle headers
            if (has_headers && !headers_read) {
                result.headers = values;
                headers_read = true;
                logger_write(LogLevel.DEBUG, "DataManager", "CSV headers parsed", 
                            string("Headers: {0}", array_length(values)));
            } else {
                // Add data row
                array_push(result.rows, values);
            }
        }
        
        file_text_close(file);
        
        logger_write(LogLevel.INFO, "DataManager", "CSV parse complete", 
                    string("File: {0}, Rows: {1}", filepath, array_length(result.rows)));
        
        return result;
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "DataManager", "CSV parse failed", 
                    string("File: {0}, Error: {1}", filepath, error));
        show_message_async("Error parsing CSV: " + string(error));
        game_end();
        return undefined;
    }
}

/// @function string_replace_all(str, find, replace)
/// @description Replace all occurrences of a substring
/// @param {string} str String to search in
/// @param {string} find String to find
/// @param {string} replace String to replace with
/// @return {string} Modified string
function string_replace_all(str, find, replace) {
    var result = str;
    while (string_pos(find, result) > 0) {
        result = string_replace(result, find, replace);
    }
    return result;
}

/// @function string_trim(str)
/// @description Remove leading and trailing whitespace from a string
/// @param {string} str String to trim
/// @return {string} Trimmed string
function string_trim(str) {
    var start = 1;
    var end_pos = string_length(str);
    
    // Find first non-whitespace character
    while (start <= end_pos && string_char_at(str, start) == " ") {
        start++;
    }
    
    // Find last non-whitespace character
    while (end_pos >= start && string_char_at(str, end_pos) == " ") {
        end_pos--;
    }
    
    // Return trimmed string
    if (start > end_pos) {
        return "";
    }
    
    return string_copy(str, start, end_pos - start + 1);
}

/// @function csv_parse_enum_value(value, enum_type)
/// @description Parse a string value into the appropriate enum
/// @param {string} value The string value to parse
/// @param {string} enum_type The type of enum to parse into
/// @return {real} The enum value or -1 if invalid
function csv_parse_enum_value(value, enum_type) {
    var upper_value = string_upper(value);
    
    switch (enum_type) {
        case "Unit_UseRoads":
            if (upper_value == "YES") return Unit_UseRoads.YES;
            if (upper_value == "NO") return Unit_UseRoads.NO;
            break;
            
        case "Unit_UseTransportTubes":
            if (upper_value == "YES") return Unit_UseTransportTubes.YES;
            if (upper_value == "NO") return Unit_UseTransportTubes.NO;
            break;
            
        case "Unit_SurviveInSpace":
            if (upper_value == "NO") return Unit_SurviveInSpace.NO;
            if (upper_value == "TEMPORARY") return Unit_SurviveInSpace.TEMPORARY;
            if (upper_value == "YES") return Unit_SurviveInSpace.YES;
            if (upper_value == "SPACE_ONLY") return Unit_SurviveInSpace.SPACE_ONLY;
            break;
            
        case "Unit_Planetfall":
            if (upper_value == "NEVER") return Unit_Planetfall.NEVER;
            if (upper_value == "SPACEPORT") return Unit_Planetfall.SPACEPORT;
            if (upper_value == "BUILDING") return Unit_Planetfall.BUILDING;
            if (upper_value == "ANYWHERE") return Unit_Planetfall.ANYWHERE;
            break;
            
        case "Unit_LaunchToSpace":
            if (upper_value == "NEVER") return Unit_LaunchToSpace.NEVER;
            if (upper_value == "SPACEPORT") return Unit_LaunchToSpace.SPACEPORT;
            if (upper_value == "ANYWHERE") return Unit_LaunchToSpace.ANYWHERE;
            break;
            
        case "Unit_FuelType":
            if (upper_value == "NOTHING") return Unit_FuelType.NOTHING;
            if (upper_value == "USED_PER_MOVE") return Unit_FuelType.USED_PER_MOVE;
            if (upper_value == "USED_PER_TURN") return Unit_FuelType.USED_PER_TURN;
            break;
            
        case "Unit_Refuel":
            if (upper_value == "NOWHERE") return Unit_Refuel.NOWHERE;
            if (upper_value == "MILITARY_BUILDINGS") return Unit_Refuel.MILITARY_BUILDINGS;
            if (upper_value == "CIVILIAN_BUILDINGS") return Unit_Refuel.CIVILIAN_BUILDINGS;
            if (upper_value == "ANYWHERE") return Unit_Refuel.ANYWHERE;
            break;
    }
    
    logger_write(LogLevel.WARNING, "DataManager", "Invalid enum value", 
                string("Type: {0}, Value: {1}", enum_type, value));
    return -1;
}

/// @function data_manager_load_csv_to_struct(filename)
/// @description Load any CSV file and convert to a struct of structs
/// @param {string} filename Name of the CSV file to load
/// @return {struct|undefined} Struct containing parsed data or undefined on error
function data_manager_load_csv_to_struct(filename) {
    logger_write(LogLevel.INFO, "DataManager", "Loading CSV file", filename);
    
    var csv_file = working_directory + DATA_PATH + filename;
    var csv_data = csv_parse_file(csv_file, true);
    
    if (is_undefined(csv_data)) {
        logger_write(LogLevel.ERROR, "DataManager", "Failed to load CSV", csv_file);
        return undefined;
    }
    
    // Check if we have headers and rows
    if (array_length(csv_data.headers) == 0) {
        logger_write(LogLevel.ERROR, "DataManager", "CSV has no headers", csv_file);
        show_message_async("Error: CSV file has no headers - " + filename);
        game_end();
        return undefined;
    }
    
    if (array_length(csv_data.rows) == 0) {
        logger_write(LogLevel.WARNING, "DataManager", "CSV has no data rows", csv_file);
        return {}; // Return empty struct
    }
    
    // Create result struct
    var result = {};
    
    // Process each row
    for (var row_index = 0; row_index < array_length(csv_data.rows); row_index++) {
        var row = csv_data.rows[row_index];
        
        // Validate row has correct number of columns
        if (array_length(row) < array_length(csv_data.headers)) {
            logger_write(LogLevel.WARNING, "DataManager", "Skipping incomplete row", 
                        string("Row {0} has {1} columns, expected {2}", 
                               row_index + 2, array_length(row), array_length(csv_data.headers)));
            continue;
        }
        
        // Create entry struct for this row
        var entry = {};
        
        // Get the first column as the key (ID)
        var entry_id = row[0];
        if (entry_id == "") {
            logger_write(LogLevel.WARNING, "DataManager", "Skipping row with empty ID", 
                        string("Row {0}", row_index + 2));
            continue;
        }
        
        // Map all columns to the entry
        for (var col = 0; col < array_length(csv_data.headers); col++) {
            var header = csv_data.headers[col];
            var value = row[col];
            
            // Try to parse as number if it looks like one
            var numeric_value = string_digits(value);
            if (numeric_value == value && value != "" && string_length(value) > 0) {
                value = real(value);
            }
            // Check for decimal numbers
            else if (string_pos(".", value) > 0) {
                // Check if it's a valid decimal number
                var decimal_test = string_replace_all(value, ".", "");
                decimal_test = string_replace_all(decimal_test, "-", ""); // Allow negative
                if (string_digits(decimal_test) == decimal_test && string_count(".", value) == 1) {
                    value = real(value);
                }
            }
            // Check for negative integers
            else if (string_char_at(value, 1) == "-" && string_length(value) > 1) {
                var negative_test = string_delete(value, 1, 1);
                if (string_digits(negative_test) == negative_test) {
                    value = real(value);
                }
            }
            
            // Store the value
            variable_struct_set(entry, header, value);
        }
        
        // Add entry to result using first column as key
        variable_struct_set(result, entry_id, entry);
        
        logger_write(LogLevel.DEBUG, "DataManager", "Loaded CSV entry", 
                    string("ID: {0}", entry_id));
    }
    
    logger_write(LogLevel.INFO, "DataManager", "CSV loaded successfully", 
                string("File: {0}, Entries: {1}", filename, variable_struct_names_count(result)));
    
    return result;
}

/// @function data_manager_create_default_units()
/// @description Create default unit definitions and save to JSON
function data_manager_create_default_units() {
    var units = {
        infantry: {
            name: "Infantry",
            type: UnitType.INFANTRY,
            cost: { production: 10, maintenance: 1 },
            stats: {
                health: 100,
                movement: 3,
                attack: 10,
                defense: 8,
                range: 1
            },
            abilities: [],
            requirements: []
        },
        armor: {
            name: "Armor",
            type: UnitType.ARMOR,
            cost: { production: 30, maintenance: 3 },
            stats: {
                health: 200,
                movement: 5,
                attack: 25,
                defense: 15,
                range: 2
            },
            abilities: ["breakthrough"],
            requirements: ["tech_armor"]
        },
        artillery: {
            name: "Artillery",
            type: UnitType.ARTILLERY,
            cost: { production: 25, maintenance: 2 },
            stats: {
                health: 80,
                movement: 2,
                attack: 40,
                defense: 5,
                range: 4
            },
            abilities: ["bombardment"],
            requirements: ["tech_artillery"]
        }
    };
    
    json_save_file(working_directory + DATA_PATH + "units.json", units);
    global.unit_definitions = units;
    
    logger_write(LogLevel.INFO, "DataManager", "Created default unit definitions", 
                string("Count: {0}", array_length(variable_struct_get_names(units))));
}

/// @function data_manager_create_default_buildings()
/// @description Create default building definitions
function data_manager_create_default_buildings() {
    var buildings = {
        city_center: {
            name: "City Center",
            cost: { production: 0 },
            maintenance: 0,
            effects: {
                production: 10,
                food: 10,
                science: 5
            },
            requirements: []
        },
        barracks: {
            name: "Barracks",
            cost: { production: 20 },
            maintenance: 1,
            effects: {
                unit_production_bonus: 0.25
            },
            allows_units: ["infantry"],
            requirements: []
        },
        factory: {
            name: "Factory",
            cost: { production: 50 },
            maintenance: 3,
            effects: {
                production: 20,
                unit_production_bonus: 0.5
            },
            allows_units: ["armor", "artillery"],
            requirements: ["tech_industrialization"]
        },
        spaceport: {
            name: "Spaceport",
            cost: { production: 100 },
            maintenance: 5,
            effects: {
                trade_capacity: 3
            },
            allows_units: ["space"],
            requirements: ["tech_space_flight"]
        }
    };
    
    json_save_file(working_directory + DATA_PATH + "buildings.json", buildings);
    global.building_definitions = buildings;
    
    logger_write(LogLevel.INFO, "DataManager", "Created default building definitions", 
                string("Count: {0}", array_length(variable_struct_get_names(buildings))));
}

/// @function data_manager_create_default_technologies()
/// @description Create default technology tree
function data_manager_create_default_technologies() {
    var technologies = {
        tech_agriculture: {
            name: "Agriculture",
            cost: 50,
            effects: {
                food_bonus: 0.25
            },
            unlocks: ["improved_farming"],
            prerequisites: []
        },
        tech_industrialization: {
            name: "Industrialization",
            cost: 200,
            effects: {
                production_bonus: 0.5
            },
            unlocks: ["factory"],
            prerequisites: ["tech_engineering"]
        },
        tech_armor: {
            name: "Armored Warfare",
            cost: 150,
            effects: {},
            unlocks: ["armor"],
            prerequisites: ["tech_industrialization"]
        },
        tech_space_flight: {
            name: "Space Flight",
            cost: 500,
            effects: {},
            unlocks: ["spaceport", "space"],
            prerequisites: ["tech_advanced_engineering", "tech_computing"]
        }
    };
    
    json_save_file(working_directory + DATA_PATH + "technologies.json", technologies);
    global.technology_definitions = technologies;
    
    logger_write(LogLevel.INFO, "DataManager", "Created default technology definitions", 
                string("Count: {0}", array_length(variable_struct_get_names(technologies))));
}

/// @function data_manager_create_default_factions()
/// @description Create default faction definitions
function data_manager_create_default_factions() {
    var factions = {
        hawkwood: {
            name: "House Hawkwood",
            type: "player",
            color: c_blue,
            traits: {
                military_bonus: 0.1,
                trade_penalty: -0.1
            },
            starting_units: ["infantry", "infantry"],
            description: "A proud military house known for discipline and honor."
        },
        decados: {
            name: "House Decados",
            type: "player",
            color: c_red,
            traits: {
                espionage_bonus: 0.2,
                diplomacy_penalty: -0.1
            },
            starting_units: ["infantry"],
            description: "Masters of intrigue and forbidden technologies."
        },
        li_halan: {
            name: "House Li Halan",
            type: "player",
            color: c_green,
            traits: {
                technology_bonus: 0.15,
                military_penalty: -0.05
            },
            starting_units: ["infantry"],
            description: "Mystics and technologists seeking enlightenment."
        },
        church: {
            name: "Universal Church",
            type: "npc",
            color: c_purple,
            traits: {
                influence_bonus: 0.3,
                cannot_declare_war: true
            },
            description: "The spiritual authority that guides humanity."
        },
        merchants: {
            name: "Merchant League",
            type: "npc",
            color: c_yellow,
            traits: {
                trade_bonus: 0.5,
                cannot_conquer: true
            },
            description: "Controllers of interstellar commerce."
        }
    };
    
    json_save_file(working_directory + DATA_PATH + "factions.json", factions);
    global.faction_definitions = factions;
    
    logger_write(LogLevel.INFO, "DataManager", "Created default faction definitions", 
                string("Count: {0}", array_length(variable_struct_get_names(factions))));
}

/// @function data_manager_create_default_terrain()
/// @description Create default terrain type definitions
function data_manager_create_default_terrain() {
    var terrain = {
        plains: {
            name: "Plains",
            movement_cost: 1,
            defense_bonus: 0,
            food: 2,
            production: 1,
            color: make_color_rgb(144, 238, 144)
        },
        forest: {
            name: "Forest",
            movement_cost: 2,
            defense_bonus: 0.25,
            food: 1,
            production: 2,
            color: make_color_rgb(34, 139, 34)
        },
        hills: {
            name: "Hills",
            movement_cost: 2,
            defense_bonus: 0.5,
            food: 1,
            production: 2,
            color: make_color_rgb(139, 90, 43)
        },
        mountains: {
            name: "Mountains",
            movement_cost: 3,
            defense_bonus: 1.0,
            food: 0,
            production: 3,
            color: make_color_rgb(105, 105, 105)
        },
        water: {
            name: "Water",
            movement_cost: -1,  // Impassable for land units
            defense_bonus: 0,
            food: 3,
            production: 0,
            color: make_color_rgb(65, 105, 225)
        }
    };
    
    json_save_file(working_directory + DATA_PATH + "terrain.json", terrain);
    global.terrain_definitions = terrain;
    
    logger_write(LogLevel.INFO, "DataManager", "Created default terrain definitions", 
                string("Count: {0}", array_length(variable_struct_get_names(terrain))));
}

/// @function data_manager_get_unit_definition(unit_type)
/// @description Get unit definition by type
/// @param {string} unit_type Unit type key
/// @return {struct|undefined} Unit definition or undefined
function data_manager_get_unit_definition(unit_type) {
    if (variable_struct_exists(global.unit_definitions, unit_type)) {
        return global.unit_definitions[$ unit_type];
    }
    return undefined;
}

/// @function data_manager_get_building_definition(building_type)
/// @description Get building definition by type
/// @param {string} building_type Building type key
/// @return {struct|undefined} Building definition or undefined
function data_manager_get_building_definition(building_type) {
    if (variable_struct_exists(global.building_definitions, building_type)) {
        return global.building_definitions[$ building_type];
    }
    return undefined;
}

/// @function data_manager_get_technology_definition(tech_id)
/// @description Get technology definition by ID
/// @param {string} tech_id Technology ID
/// @return {struct|undefined} Technology definition or undefined
function data_manager_get_technology_definition(tech_id) {
    if (variable_struct_exists(global.technology_definitions, tech_id)) {
        return global.technology_definitions[$ tech_id];
    }
    return undefined;
}

/// @function data_manager_get_faction_definition(faction_id)
/// @description Get faction definition by ID
/// @param {string} faction_id Faction ID
/// @return {struct|undefined} Faction definition or undefined
function data_manager_get_faction_definition(faction_id) {
    if (variable_struct_exists(global.faction_definitions, faction_id)) {
        return global.faction_definitions[$ faction_id];
    }
    return undefined;
}


	
	
	
/// @function data_manager_get_terrain_definition(terrain_type)
/// @description Get terrain definition by type
/// @param {string} terrain_type Terrain type key
/// @return {struct|undefined} Terrain definition or undefined
function data_manager_get_terrain_definition(terrain_type) {
    if (variable_struct_exists(global.terrain_definitions, terrain_type)) {
        return global.terrain_definitions[$ terrain_type];
    }
    return undefined;
}

/// @function data_manager_load_unit_types(filepath)
/// @description Load unit types from CSV file and parse enum columns
/// @param {string} filepath Path to the UnitTypes.csv file
/// @return {struct|undefined} Struct of unit types with parsed enums or undefined on error
function data_manager_load_unit_types(filepath) {
    logger_write(LogLevel.INFO, "DataManager", "Loading unit types", filepath);
    
    // First load the CSV data generically
    var csv_data = csv_parse_file(filepath, true);
    
    if (is_undefined(csv_data)) {
        logger_write(LogLevel.ERROR, "DataManager", "Failed to parse unit types CSV", filepath);
        return undefined;
    }
    
    // Check if we have headers and rows
    if (array_length(csv_data.headers) == 0) {
        logger_write(LogLevel.ERROR, "DataManager", "Unit types CSV has no headers", filepath);
        return undefined;
    }
    
    if (array_length(csv_data.rows) == 0) {
        logger_write(LogLevel.WARNING, "DataManager", "Unit types CSV has no data rows", filepath);
        return {}; // Return empty struct
    }
    
    // Create result struct to hold all unit types
    var unit_types = {};
    
    // Define which columns should be parsed as enums
    var enum_columns = {
        "use_roads": "Unit_UseRoads",
        "use_tubes": "Unit_UseTransportTubes", 
        "space": "Unit_SurviveInSpace",
        "planetfall": "Unit_Planetfall",
        "launch_to_space": "Unit_LaunchToSpace",
        "fuel_type": "Unit_FuelType",
        "refuels": "Unit_Refuel"
    };
    
    // Process each row
    for (var row_index = 0; row_index < array_length(csv_data.rows); row_index++) {
        var row = csv_data.rows[row_index];
        
        // Validate row has enough columns for non-empty headers
        var required_columns = 0;
        for (var i = 0; i < array_length(csv_data.headers); i++) {
            if (csv_data.headers[i] != "") {
                required_columns = i + 1;
            }
        }
        
        if (array_length(row) < required_columns) {
            logger_write(LogLevel.WARNING, "DataManager", "Skipping incomplete unit type row", 
                        string("Row {0} has {1} columns, expected at least {2}", 
                               row_index + 2, array_length(row), required_columns));
            continue;
        }
        
        // Create unit type struct for this row
        var unit_type = {};
        
        // Get the first column as the unit ID
        var unit_id = row[0];
        if (unit_id == "") {
            logger_write(LogLevel.WARNING, "DataManager", "Skipping unit type with empty ID", 
                        string("Row {0}", row_index + 2));
            continue;
        }
        
        // Map all columns to the unit type
        var num_columns = min(array_length(csv_data.headers), array_length(row));
        for (var col = 0; col < num_columns; col++) {
            var header = csv_data.headers[col];
            
            // Skip empty headers
            if (header == "" || is_undefined(header)) {
                continue;
            }
            
            var value = row[col];
            
            // Check if this column should be parsed as an enum
            if (variable_struct_exists(enum_columns, header)) {
                var enum_type = enum_columns[$ header];
                var enum_value = csv_parse_enum_value(value, enum_type);
                
                if (enum_value != -1) {
                    unit_type[$ header] = enum_value;
                } else {
                    logger_write(LogLevel.WARNING, "DataManager", "Invalid enum value in unit types", 
                                string("Unit: {0}, Column: {1}, Value: {2}", unit_id, header, value));
                    unit_type[$ header] = value; // Store original string as fallback
                }
            } else {
                // Try to parse as number if it looks like one
                var numeric_value = string_digits(value);
                if (numeric_value == value && value != "" && string_length(value) > 0) {
                    value = real(value);
                }
                // Check for decimal numbers
                else if (string_pos(".", value) > 0) {
                    var decimal_test = string_replace_all(value, ".", "");
                    decimal_test = string_replace_all(decimal_test, "-", "");
                    if (string_digits(decimal_test) == decimal_test && string_count(".", value) == 1) {
                        value = real(value);
                    }
                }
                // Check for negative integers
                else if (string_char_at(value, 1) == "-" && string_length(value) > 1) {
                    var negative_test = string_delete(value, 1, 1);
                    if (string_digits(negative_test) == negative_test) {
                        value = real(value);
                    }
                }
                
                // Store the value
                unit_type[$ header] = value;
            }
        }
        
        // Add unit type to result using first column as key
        unit_types[$ unit_id] = unit_type;
        
        logger_write(LogLevel.DEBUG, "DataManager", "Loaded unit type", 
                    string("ID: {0}, Name: {1}", unit_id, unit_type[$ "Name"]));
    }
    
    logger_write(LogLevel.INFO, "DataManager", "Unit types loaded successfully", 
                string("Count: {0}", variable_struct_names_count(unit_types)));
    
    return unit_types;
}

/// @function data_manager_get_unit_type_from_csv(unit_type_id)
/// @description Get unit type definition from CSV data
/// @param {string} unit_type_id Unit type ID from CSV
/// @return {struct|undefined} Unit type definition or undefined
function data_manager_get_unit_type_from_csv(unit_type_id) {
    if (variable_global_exists("game_data") && 
        variable_struct_exists(global.game_data, "unit_types") &&
        variable_struct_exists(global.game_data.unit_types, unit_type_id)) {
        return global.game_data.unit_types[$ unit_type_id];
    }
    return undefined;
}

/// @function data_manager_process_csv_enums(data, enum_mappings)
/// @description Process enum columns in CSV data
/// @param {struct} data The CSV data loaded by data_manager_load_csv_to_struct
/// @param {struct} enum_mappings Mapping of column names to enum type names
/// @return {struct} The same data with enum values parsed
function data_manager_process_csv_enums(data, enum_mappings) {
    var entry_ids = variable_struct_get_names(data);
    
    for (var i = 0; i < array_length(entry_ids); i++) {
        var entry = data[$ entry_ids[i]];
        var enum_columns = variable_struct_get_names(enum_mappings);
        
        for (var j = 0; j < array_length(enum_columns); j++) {
            var column_name = enum_columns[j];
            var enum_type = enum_mappings[$ column_name];
            
            if (variable_struct_exists(entry, column_name)) {
                var string_value = string(entry[$ column_name]);
                var enum_value = csv_parse_enum_value(string_value, enum_type);
                
                if (enum_value != -1) {
                    // Replace string with enum value
                    entry[$ column_name] = enum_value;
                } else {
                    logger_write(LogLevel.WARNING, "DataManager", "Invalid enum value", 
                                string("Entry: {0}, Column: {1}, Value: {2}", 
                                       entry_ids[i], column_name, string_value));
                }
            }
        }
    }
    
    return data;
}

/// @function filename_get_name_only(path);
/// @description Gets the filename from a path, without the extension.
/// @param {string} path The full path to the file.
function filename_get_name_only(path) {
    var _last_slash = string_last_pos("\\", path) + string_last_pos("/", path);
    var _filename = string_copy(path, _last_slash + 1, string_length(path));
    var _last_dot = string_last_pos(".", _filename);

    if (_last_dot > 0) {
        return string_copy(_filename, 1, _last_dot - 1);
    }

    return _filename;
}

/// @function path_get_directory_name(path)
/// @description Extracts the final directory name from a full path string.
/// @param {string} path      The full path to the directory.
/// @return {string}
function path_get_directory_name(path) {
    var _path = path;

    // First, remove any trailing slashes to correctly handle paths like "C:/Users/Test/"
    while (string_length(_path) > 0) {
        var last_char = string_char_at(_path, string_length(_path));
        if (last_char == "/" || last_char == "\\") {
            _path = string_copy(_path, 1, string_length(_path) - 1);
        } else {
            break;
        }
    }

    // Find the position of the last separator (either / or \)
    var last_sep_pos = max(string_last_pos("/", _path), string_last_pos("\\", _path));

    // If a separator was found, return the part of the string after it
    if (last_sep_pos > 0) {
        return string_copy(_path, last_sep_pos + 1, string_length(_path) - last_sep_pos);
    }
    
    // Otherwise, the path itself is the directory name
    return _path;
}

/// @function sprite_create_from_frames(directory)
/// @description Creates an animated sprite from a sequence of PNG files in a directory.
/// @param {string} directory The directory containing the PNG frames.
function sprite_create_from_frames(directory) {

    var image_files = ds_list_create();
    var file = file_find_first(directory + "/*.png", 0);

    // Find all PNG files in the directory
    while (file != "") {
        ds_list_add(image_files, directory + "/" + file);
        file = file_find_next();
    }
    file_find_close();

    // Sort the files to ensure correct frame order
    ds_list_sort(image_files, true);

    if (ds_list_size(image_files) == 0) {
        show_debug_message("No PNG files found in directory: " + directory);
        ds_list_destroy(image_files);
        return -1;
    }

    // Create the sprite from the first image
    var first_frame_path = image_files[| 0];
    var new_sprite = sprite_add(first_frame_path, 0, false, false, 0, 0);

    if (new_sprite < 0) {
        show_debug_message("Failed to create sprite from: " + first_frame_path);
        ds_list_destroy(image_files);
        return -1;
    }

    // If there are more frames, add them
    if (ds_list_size(image_files) > 1) {
        // Get the dimensions from the created sprite
        var w = sprite_get_width(new_sprite);
        var h = sprite_get_height(new_sprite);

        // Create a surface to draw the other frames on
        var temp_surface = surface_create(w, h);

        // Add the rest of the images as new frames
        for (var i = 1; i < ds_list_size(image_files); i++) {
            var frame_path = image_files[| i];
            var frame_sprite = sprite_add(frame_path, 1, false, false, 0, 0);

            if (frame_sprite >= 0) {
                surface_set_target(temp_surface);
                draw_clear_alpha(c_black, 0); // Clear the surface
                draw_sprite(frame_sprite, 0, 0, 0);
                surface_reset_target();
                
                // Add the surface as a new frame to our main sprite
                sprite_add_from_surface(new_sprite, temp_surface, 0, 0, w, h, false, false);
                
                sprite_delete(frame_sprite); // Clean up the temporary sprite
            }
        }
        
        // Clean up the surface
        surface_free(temp_surface);
    }
    
    // Clean up the list
    ds_list_destroy(image_files);

    // Return the index of the newly created animated sprite
    return new_sprite;
}
	
/// @function load_sprites_from_directory(directory, prefix);
/// @description loads sprites from directory and creates spr_prefix_dir sprites
/// @param {string} directory The path to the main directory to search in.
/// @param {string} prefix    The string to prefix to the created sprite assets.
/// @param {map} dsmap: place to store sprites with names
function load_sprites_from_directory(directory, prefix, dsmap) {
    // This is a recursive helper function to find all subdirectories
    function find_subdirectories(dir, sub_dir_list) {
		
        var file = file_find_first(dir + "*", fa_directory);
        while (file != "") {
            if (directory_exists(dir + file) && file != "." && file != "..") {
                ds_list_add(sub_dir_list, dir + file);
            }
            file = file_find_next();
        }
        file_find_close();
    }

    var all_subdirectories = ds_list_create();
    find_subdirectories(directory, all_subdirectories);
    ds_list_add(all_subdirectories, directory); // Include the root directory as well

	logger_write(LogLevel.INFO, "DataManager", "Loadeding "+string(ds_list_size(all_subdirectories)) + " sprites", load_sprites_from_directory);

    // Iterate through each found subdirectory
    for (var i = 0; i < ds_list_size(all_subdirectories); i++) {
        var current_dir = all_subdirectories[| i];
		var dir_name = path_get_directory_name(current_dir)

		var new_sprite = sprite_create_from_frames(current_dir)

        // Assign the new sprite a name in the asset browser
        var sprite_name = dir_name;
        ds_map_add(dsmap, sprite_name, new_sprite);
		logger_write(LogLevel.INFO, "DataManager", "Added "+prefix+" Sprite: "+sprite_name);

    }

    ds_list_destroy(all_subdirectories);
}
	
	
/// @function read_file_and_strip_comments(filepath)
/// @description Reads a file into a single string, removing any lines that start with "//".
/// @param {string} filepath      The path to the file to read.
/// @return {string} A single string containing the file's content with comments removed.
function read_file_and_strip_comments(filepath) {
    var file = file_text_open_read(filepath);
    if (file < 0) {
        show_debug_message("Error: Could not open file for stripping comments: " + filepath);
        return "";
    }
    
    var cleaned_content = "";
    
    // Read the file line by line
    while (!file_text_eof(file)) {
        var current_line = file_text_readln(file);
        var trimmed_line = string_trim(current_line);
        
        // If the line is valid (not empty and not a comment), add it to our result string
        if (string_length(trimmed_line) > 0 && string_pos("//", trimmed_line) != 1) {
            cleaned_content += current_line + "\n"; // Add the original line plus a newline char
        }
    }
    
    file_text_close(file);
    return cleaned_content;
}
	
/// @function load_keyed_database_from_csv(filepath)
/// @description Loads a CSV into a ds_map of ds_maps. First column must be "ID".
///              Automatically converts numeric values to reals and skips commented (//) lines.
/// @param {string} filepath      The path to the CSV file.
/// @return {Id.DsMap} A ds_map of ds_maps, or -1 on failure.
function load_keyed_database_from_csv(filepath) {
    
    logger_write(LogLevel.INFO, "AssetManager", "Loading CSV at " + filepath);
    if (!file_exists(filepath)) {
        logger_write(LogLevel.ERROR, "AssetManager", "CSV file not found.", filepath);
        return -1;
    }

    var file = file_text_open_read(filepath);
    if (file < 0) {
        logger_write(LogLevel.ERROR, "AssetManager", "Could not open file.", filepath);
        return -1;
    }

    var database_map = ds_map_create();
    var headers = -1;
    var line_number = 0;

    while (!file_text_eof(file)) {
        line_number++;
        var current_line = file_text_readln(file);
        var trimmed_line = string_trim(current_line);

        if (string_length(trimmed_line) == 0 || string_pos("//", trimmed_line) == 1) {
            continue;
        }

        var values = string_split(trimmed_line, ",");

        if (headers == -1) { // This is the header row
            headers = values;
            if (array_length(headers) == 0 || string_trim(headers[0]) != "ID") {
                logger_write(LogLevel.ERROR, "AssetManager", "The first column in header must be 'ID'.", filepath);
                ds_map_destroy(database_map);
                file_text_close(file);
                return -1;
            }
        } else { // This is a data row
            if (array_length(values) == 0 || string_length(values[0]) == 0) continue; // Skip empty rows

            var object_id_string = string_trim(values[0]);
            var object_id;

            // Per the documentation, real() will throw an error on non-numeric strings.
            // We use try...catch to handle this exact behavior.
            try {
                object_id = floor(real(object_id_string));
            }
            catch (_ex) {
                logger_write(LogLevel.ERROR, "AssetManager", "Skipping non-numeric ID ('" + object_id_string + "') on line " + string(line_number), filepath);
                continue; // Skip this row and move to the next
            }
            
            if (ds_map_exists(database_map, object_id)) {
                logger_write(LogLevel.ERROR, "AssetManager", "Duplicate ID " + string(object_id) + " found. Overwriting.", filepath);
            }

            var properties_map = ds_map_create();
            for (var i = 0; i < array_length(headers); i++) {
                var key = string_trim(headers[i]);
                var value_string = (i < array_length(values)) ? string_trim(values[i]) : "";
                
                // Here we apply the same try...catch logic for every value in the row
                // to achieve automatic type conversion.
                var final_value;
                try {
                    // Attempt the conversion. This will succeed for "15", "5.5", etc.
                    final_value = real(value_string);
                }
                catch (_ex) {
                    // This block executes if real() throws an error (e.g., for "Sword").
                    // In that case, we keep it as a string.
                    final_value = value_string;
                }
                
                ds_map_add(properties_map, key, final_value);
            }
            
            ds_map_add(database_map, object_id, properties_map);
        }
    }

    file_text_close(file);

    if (ds_map_empty(database_map)) {
        logger_write(LogLevel.ERROR, "AssetManager", "No valid data loaded.", filepath);
        ds_map_destroy(database_map);
        return -1;
    }

    logger_write(LogLevel.INFO, "AssetManager", "Successfully loaded " + string(ds_map_size(database_map)) + " entries.", filepath);
    return database_map;
}
	
/// @function destroy_nested_maps(map)
/// @description Destroys target map with any maps included inside
function destroy_nested_maps(map) {
	if (ds_exists(map, ds_type_map)) {
	    var key = ds_map_find_first(map);
	    while (ds_map_exists(map, key)) {
	        // Get the inner map and destroy it
	        var inner_map = map[? key];
	        ds_map_destroy(inner_map);
        
	        key = ds_map_find_next(map, key);
	    }
	    // Finally, destroy the outer map
	    ds_map_destroy(map);
	}	
}

/// @function get_hex_property(hex_id, property)
/// @description Returns value for hex definition as read from hex.csv
function get_hex_property(hex_id, property) {
	if (ds_map_exists(global.hex_definitons, hex_id)) {
	    var properties = global.item_database[? hex_id];
	    return properties[? property];

	} else {
	    logger_write(LogLevel.WARNING, "DataManager", "Hex with ID " + string(hex_id) + " not found in database.");
		return undefined
	}	
}