/// @description Data manager functions for creating default game data

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
                string("Count: {0}", variable_struct_names_count(units)));
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
                string("Count: {0}", variable_struct_names_count(buildings)));
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
                string("Count: {0}", variable_struct_names_count(technologies)));
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
                string("Count: {0}", variable_struct_names_count(factions)));
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
                string("Count: {0}", variable_struct_names_count(terrain)));
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