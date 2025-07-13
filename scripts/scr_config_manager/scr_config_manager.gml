/// @description Configuration manager using JSON format
/// @description Loads and saves user settings from/to JSON file

/// @description Initialize the configuration manager and load settings
function config_init() {
    global.config_file = CONFIG_FILE;
    global.config_loaded = false;
    
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
            level: LogLevel.INFO,
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
    
    // Keep global.config for backwards compatibility
    global.config = global.game_options;
    
    config_load();
    config_apply_display_settings();
}

/// @description Load configuration from JSON file
function config_load() {
    // Ensure config directory exists
    var config_dir = working_directory + CONFIG_PATH;
    if (!directory_exists(config_dir)) {
        try {
            directory_create(config_dir);
        } catch (error) {
            show_debug_message("Failed to create config directory: " + string(error));
        }
    }
    
    var config_path = working_directory + global.config_file;
    
    if (!file_exists(config_path)) {
        // Create default config
        config_save();
        return;
    }
    
    try {
        // Load JSON file
        var json_string = "";
        var file = file_text_open_read(config_path);
        
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        
        file_text_close(file);
        
        // Parse JSON
        var loaded_config = json_parse(json_string);
        
        // Merge with defaults (in case new options were added)
        global.game_options = json_merge_structures(global.game_options, loaded_config);
        
        global.config_loaded = true;
        
        // Update backwards compatibility reference
        global.config = global.game_options;
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "ConfigManager", "Configuration loaded successfully", config_path);
        }
        
    } catch (error) {
        global.config_loaded = false;
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Error loading configuration", string(error));
        }
        
        // Create default config file
        config_save();
    }
}

/// @description Save configuration to JSON file
function config_save() {
    // Ensure config directory exists
    var config_dir = working_directory + CONFIG_PATH;
    if (!directory_exists(config_dir)) {
        directory_create(config_dir);
    }
    
    var config_path = working_directory + global.config_file;
    
    try {
        // Convert to JSON string with pretty printing
        var json_string = json_stringify(global.game_options);
        
        // Write to file
        var file = file_text_open_write(config_path);
        file_text_write_string(file, json_string);
        file_text_close(file);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "ConfigManager", "Configuration saved successfully", config_path);
        }
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Failed to save configuration", string(error));
        }
    }
}

/// @description Apply display settings from configuration
function config_apply_display_settings() {
    // Set window size
    window_set_size(global.game_options.display.width, global.game_options.display.height);
    
    // Set fullscreen mode
    window_set_fullscreen(global.game_options.display.fullscreen);
    
    // Apply VSync
    display_set_timing_method(global.game_options.display.vsync ? tm_systemtiming : tm_sleep);
    
    // Set target FPS
    game_set_speed(global.game_options.performance.target_fps, gamespeed_fps);
    
    // Update surface and application surface
    surface_resize(application_surface, global.game_options.display.width, global.game_options.display.height);
}

/// @description Get a configuration value using path notation
/// @param {string} path Path to value (e.g., "display.width")
/// @param {any} default_value Default if not found
/// @return {any} Configuration value or default
function config_get(path, default_value = undefined) {
    return json_get_nested_value(global.game_options, path, default_value);
}

/// @description Set a configuration value using path notation
/// @param {string} path Path to value (e.g., "display.width")
/// @param {any} value Value to set
function config_set(path, value) {
    json_set_nested_value(global.game_options, path, value);
    
    // Update backwards compatibility reference
    global.config = global.game_options;
}