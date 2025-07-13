/// @description Configuration manager using JSON format
/// @description Loads and saves user settings from/to JSON file

/// @description Initialize the configuration manager and load settings
function config_init() {
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_init called", "Configuration initialization started");
    
    global.config_file = CONFIG_FILE;
    global.config_loaded = false;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Config variables initialized", 
                string("Config file: '{0}', Loaded: {1}", global.config_file, global.config_loaded));
    
    // Initialize game options structure with defaults
    global.game_options = {
        display: {
            width: DEFAULT_GAME_WIDTH,
            height: DEFAULT_GAME_HEIGHT,
            fullscreen: DEFAULT_FULLSCREEN,
            vsync: true
        },
        ui: {
            button_width: DEFAULT_BUTTON_WIDTH,
            button_height: DEFAULT_BUTTON_HEIGHT,
            button_spacing: DEFAULT_BUTTON_SPACING,
            font_size: 24
        },
        assets: {
            images_path: IMAGES_PATH,
            sounds_path: SOUNDS_PATH,
            data_path: DATA_PATH
        },
        logging: {
            enabled: true,
            level: LogLevel.DEBUG,  // Set to DEBUG for extensive logging
            file: LOGS_PATH + LOG_FILE
        },
        menu: {
            center_x_offset: 0,
            center_y_offset: 0,
            start_y_offset: -240
        },
        performance: {
            target_fps: 60,
            fixed_timestep: true
        },
        hex: {
            size: DEFAULT_HEX_SIZE
        }
    };
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Default game options created", 
                string("Logging level set to: {0} (DEBUG)", global.game_options.logging.level));
    
    // Keep global.config for backwards compatibility
    global.config = global.game_options;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Calling config_load", "Loading configuration from file");
    config_load();
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Calling config_apply_display_settings", "Applying display configuration");
    config_apply_display_settings();
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_init completed", "Configuration ready");
}

/// @description Load configuration from JSON file
function config_load() {
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_load called", "Loading configuration from file");
    
    // Ensure config directory exists
    var config_dir = working_directory + CONFIG_PATH;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Checking config directory", 
                string("Path: '{0}', Exists: {1}", config_dir, directory_exists(config_dir)));
    
    if (!directory_exists(config_dir)) {
        try {
            logger_write(LogLevel.DEBUG, "ConfigManager", "Creating config directory", string("Path: '{0}'", config_dir));
            directory_create(config_dir);
            logger_write(LogLevel.DEBUG, "ConfigManager", "Config directory created", "Success");
        } catch (error) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Failed to create config directory", 
                        string("Path: '{0}', Error: {1}", config_dir, error));
            show_debug_message("Failed to create config directory: " + string(error));
        }
    }
    
    var config_path = working_directory + global.config_file;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Config file path determined", 
                string("Path: '{0}', Exists: {1}", config_path, file_exists(config_path)));
    
    if (!file_exists(config_path)) {
        logger_write(LogLevel.DEBUG, "ConfigManager", "Config file not found, creating default", 
                    string("Path: '{0}'", config_path));
        // Create default config
        config_save();
        return;
    }
    
    try {
        logger_write(LogLevel.DEBUG, "ConfigManager", "Reading config file", string("Path: '{0}'", config_path));
        
        // Load JSON file
        var json_string = "";
        var file = file_text_open_read(config_path);
        
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        
        file_text_close(file);
        
        logger_write(LogLevel.DEBUG, "ConfigManager", "Config file read", 
                    string("JSON length: {0} characters", string_length(json_string)));
        
        // Parse JSON
        logger_write(LogLevel.DEBUG, "ConfigManager", "Parsing JSON", "json_parse call");
        var loaded_config = json_parse(json_string);
        
        logger_write(LogLevel.DEBUG, "ConfigManager", "JSON parsed", 
                    string("Type: {0}, Is struct: {1}", typeof(loaded_config), is_struct(loaded_config)));
        
        // Merge with defaults (in case new options were added)
        logger_write(LogLevel.DEBUG, "ConfigManager", "Merging with defaults", "json_merge_structures call");
        global.game_options = json_merge_structures(global.game_options, loaded_config);
        
        global.config_loaded = true;
        
        // Update backwards compatibility reference
        global.config = global.game_options;
        
        logger_write(LogLevel.DEBUG, "ConfigManager", "Config merge completed", 
                    string("Loaded: {0}, Final logging level: {1}", global.config_loaded, global.game_options.logging.level));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "ConfigManager", "Configuration loaded successfully", config_path);
        }
        
    } catch (error) {
        global.config_loaded = false;
        
        logger_write(LogLevel.ERROR, "ConfigManager", "Config loading failed", 
                    string("Path: '{0}', Error: {1}", config_path, error));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Error loading configuration", string(error));
        }
        
        // Create default config file
        logger_write(LogLevel.DEBUG, "ConfigManager", "Creating default config due to load error", "Fallback to defaults");
        config_save();
    }
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_load completed", 
                string("Loaded: {0}", global.config_loaded));
}

/// @description Save configuration to JSON file
function config_save() {
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_save called", "Saving configuration to file");
    
    // Ensure config directory exists
    var config_dir = working_directory + CONFIG_PATH;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Ensuring config directory exists", 
                string("Path: '{0}'", config_dir));
    
    if (!directory_exists(config_dir)) {
        logger_write(LogLevel.DEBUG, "ConfigManager", "Creating config directory", string("Path: '{0}'", config_dir));
        directory_create(config_dir);
    }
    
    var config_path = working_directory + global.config_file;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Config save path determined", 
                string("Path: '{0}'", config_path));
    
    try {
        logger_write(LogLevel.DEBUG, "ConfigManager", "Converting to JSON", "json_stringify call");
        
        // Convert to JSON string with pretty printing
        var json_string = json_stringify(global.game_options);
        
        logger_write(LogLevel.DEBUG, "ConfigManager", "JSON created", 
                    string("Length: {0} characters", string_length(json_string)));
        
        // Write to file
        logger_write(LogLevel.DEBUG, "ConfigManager", "Writing to file", string("Path: '{0}'", config_path));
        var file = file_text_open_write(config_path);
        file_text_write_string(file, json_string);
        file_text_close(file);
        
        logger_write(LogLevel.DEBUG, "ConfigManager", "File written successfully", "Config save completed");
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "ConfigManager", "Configuration saved successfully", config_path);
        }
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "ConfigManager", "Config save failed", 
                    string("Path: '{0}', Error: {1}", config_path, error));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Failed to save configuration", string(error));
        }
    }
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_save completed", "Save operation finished");
}

/// @description Apply display settings from configuration
function config_apply_display_settings() {
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_apply_display_settings called", "Applying display configuration");
    
    var width = global.game_options.display.width;
    var height = global.game_options.display.height;
    var fullscreen = global.game_options.display.fullscreen;
    var vsync = global.game_options.display.vsync;
    var target_fps = global.game_options.performance.target_fps;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "Display settings to apply", 
                string("Size: {0}x{1}, Fullscreen: {2}, VSync: {3}, FPS: {4}", 
                       width, height, fullscreen, vsync, target_fps));
    
    // Set window size
    logger_write(LogLevel.DEBUG, "ConfigManager", "Setting window size", string("Size: {0}x{1}", width, height));
    window_set_size(width, height);
    
    // Set fullscreen mode
    logger_write(LogLevel.DEBUG, "ConfigManager", "Setting fullscreen mode", string("Fullscreen: {0}", fullscreen));
    window_set_fullscreen(fullscreen);
    
    // Apply VSync
    logger_write(LogLevel.DEBUG, "ConfigManager", "Setting VSync", string("VSync: {0}", vsync));
    display_set_timing_method(vsync ? tm_systemtiming : tm_sleep);
    
    // Set target FPS
    logger_write(LogLevel.DEBUG, "ConfigManager", "Setting target FPS", string("FPS: {0}", target_fps));
    game_set_speed(target_fps, gamespeed_fps);
    
    // Update surface and application surface
    logger_write(LogLevel.DEBUG, "ConfigManager", "Resizing application surface", string("Size: {0}x{1}", width, height));
    surface_resize(application_surface, width, height);
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_apply_display_settings completed", "Display settings applied");
}

/// @description Get a configuration value using path notation
/// @param {string} path Path to value (e.g., "display.width")
/// @param {any} default_value Default if not found
/// @return {any} Configuration value or default
function config_get(path, default_value = undefined) {
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_get called", 
                string("Path: '{0}', Default: {1}", path, default_value));
    
    var result = json_get_nested_value(global.game_options, path, default_value);
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_get result", 
                string("Path: '{0}', Value: {1}", path, result));
    
    return result;
}

/// @description Set a configuration value using path notation
/// @param {string} path Path to value (e.g., "display.width")
/// @param {any} value Value to set
function config_set(path, value) {
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_set called", 
                string("Path: '{0}', Value: {1}", path, value));
    
    json_set_nested_value(global.game_options, path, value);
    
    // Update backwards compatibility reference
    global.config = global.game_options;
    
    logger_write(LogLevel.DEBUG, "ConfigManager", "config_set completed", 
                string("Path: '{0}' set to: {1}", path, value));
}