/// @description Initialize the configuration manager and load settings from file
/// @description Sets up default configuration values and loads user settings from config file
/// @description Must be called before any other systems that depend on configuration
function config_init() {
    global.config_file = "game_config.ini";
    global.config_loaded = false;
    
    // Initialize config structure with defaults
    global.config = {
        // Display settings
        game_width: DEFAULT_GAME_WIDTH,
        game_height: DEFAULT_GAME_HEIGHT,
        fullscreen: DEFAULT_FULLSCREEN,
        vsync: true,
        
        // UI settings
        menu_button_width: 300,
        menu_button_height: 60,
        menu_button_spacing: 80,
        menu_font_size: 24,
        
        // Asset paths - Updated to match your actual directory structure
        asset_path_images: "datafiles/assets/images/",
        asset_path_sounds: "datafiles/assets/sounds/",
        asset_path_data: "datafiles/assets/data/",
        
        // Logging settings
        log_enabled: true,
        log_level: LogLevel.INFO,
        log_file: "game_log.txt",
        
        // Menu layout
        menu_center_x_offset: 0,
        menu_center_y_offset: 0,
        menu_start_y_offset: -240,
        
        // Performance settings
        target_fps: 60,
        fixed_timestep: true
    };
    
    config_load();
    config_apply_display_settings();
}

/// @description Load configuration values from the INI file
/// @description Reads settings from file and applies them to global.config
/// @description Creates default config file if none exists or if file is empty
function config_load() {
    var needs_save = false;
    
    if (!file_exists(global.config_file)) {
        needs_save = true;
    } else {
        // Check if file is empty or corrupted
        try {
            ini_open(global.config_file);
            var test_value = ini_read_string("Display", "width", "");
            ini_close();
            
            // If no sections exist or key returns empty, file is empty/corrupted
            if (test_value == "") {
                needs_save = true;
            }
        } catch (error) {
            needs_save = true;
        }
    }
    
    if (needs_save) {
        config_save(); // Create default config file
        return;
    }
    
    try {
        ini_open(global.config_file);
        
        // Display settings
        global.config.game_width = ini_read_real("Display", "width", global.config.game_width);
        global.config.game_height = ini_read_real("Display", "height", global.config.game_height);
        global.config.fullscreen = ini_read_real("Display", "fullscreen", global.config.fullscreen);
        global.config.vsync = ini_read_real("Display", "vsync", global.config.vsync);
        
        // UI settings
        global.config.menu_button_width = ini_read_real("UI", "button_width", global.config.menu_button_width);
        global.config.menu_button_height = ini_read_real("UI", "button_height", global.config.menu_button_height);
        global.config.menu_button_spacing = ini_read_real("UI", "button_spacing", global.config.menu_button_spacing);
        global.config.menu_font_size = ini_read_real("UI", "font_size", global.config.menu_font_size);
        
        // Asset paths
        global.config.asset_path_images = ini_read_string("Assets", "images_path", global.config.asset_path_images);
        global.config.asset_path_sounds = ini_read_string("Assets", "sounds_path", global.config.asset_path_sounds);
        global.config.asset_path_data = ini_read_string("Assets", "data_path", global.config.asset_path_data);
        
        // Logging settings
        global.config.log_enabled = ini_read_real("Logging", "enabled", global.config.log_enabled);
        global.config.log_level = ini_read_real("Logging", "level", global.config.log_level);
        global.config.log_file = ini_read_string("Logging", "file", global.config.log_file);
        
        // Menu layout
        global.config.menu_center_x_offset = ini_read_real("Menu", "center_x_offset", global.config.menu_center_x_offset);
        global.config.menu_center_y_offset = ini_read_real("Menu", "center_y_offset", global.config.menu_center_y_offset);
        global.config.menu_start_y_offset = ini_read_real("Menu", "start_y_offset", global.config.menu_start_y_offset);
        
        // Performance settings
        global.config.target_fps = ini_read_real("Performance", "target_fps", global.config.target_fps);
        global.config.fixed_timestep = ini_read_real("Performance", "fixed_timestep", global.config.fixed_timestep);
        
        ini_close();
        global.config_loaded = true;
        
    } catch (error) {
        global.config_loaded = false;
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Error loading configuration", string(error));
        }
    }
}

/// @description Save current configuration values to the INI file
/// @description Writes all current config settings to persistent storage
function config_save() {
    try {
        ini_open(global.config_file);
        
        // Display settings
        ini_write_real("Display", "width", global.config.game_width);
        ini_write_real("Display", "height", global.config.game_height);
        ini_write_real("Display", "fullscreen", global.config.fullscreen);
        ini_write_real("Display", "vsync", global.config.vsync);
        
        // UI settings
        ini_write_real("UI", "button_width", global.config.menu_button_width);
        ini_write_real("UI", "button_height", global.config.menu_button_height);
        ini_write_real("UI", "button_spacing", global.config.menu_button_spacing);
        ini_write_real("UI", "font_size", global.config.menu_font_size);
        
        // Asset paths
        ini_write_string("Assets", "images_path", global.config.asset_path_images);
        ini_write_string("Assets", "sounds_path", global.config.asset_path_sounds);
        ini_write_string("Assets", "data_path", global.config.asset_path_data);
        
        // Logging settings
        ini_write_real("Logging", "enabled", global.config.log_enabled);
        ini_write_real("Logging", "level", global.config.log_level);
        ini_write_string("Logging", "file", global.config.log_file);
        
        // Menu layout
        ini_write_real("Menu", "center_x_offset", global.config.menu_center_x_offset);
        ini_write_real("Menu", "center_y_offset", global.config.menu_center_y_offset);
        ini_write_real("Menu", "start_y_offset", global.config.menu_start_y_offset);
        
        // Performance settings
        ini_write_real("Performance", "target_fps", global.config.target_fps);
        ini_write_real("Performance", "fixed_timestep", global.config.fixed_timestep);
        
        ini_close();
        
    } catch (error) {
        // Log error if logging system is available
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "ConfigManager", "Failed to save configuration", string(error));
        }
    }
}

/// @description Apply display settings from configuration to the game window
/// @description Sets window size, fullscreen mode, VSync, and FPS based on config values
function config_apply_display_settings() {
    // Set window size
    window_set_size(global.config.game_width, global.config.game_height);
    
    // Set fullscreen mode
    window_set_fullscreen(global.config.fullscreen);
    
    // Apply VSync
    display_set_timing_method(global.config.vsync ? tm_systemtiming : tm_sleep);
    
    // Set target FPS
    game_set_speed(global.config.target_fps, gamespeed_fps);
    
    // Update surface and application surface
    surface_resize(application_surface, global.config.game_width, global.config.game_height);
}

/// @description Get a configuration value from a specific section and key
/// @param {string} section Configuration section name
/// @param {string} key Configuration key name  
/// @param {any} default_value Default value if key not found
/// @return {any} Configuration value or default if not found
function config_get(section, key, default_value = undefined) {
    var struct_key = string("{0}.{1}", section, key);
    return struct_exists(global.config, struct_key) ? global.config[$ struct_key] : default_value;
}

/// @description Set a configuration value for a specific section and key
/// @param {string} section Configuration section name
/// @param {string} key Configuration key name
/// @param {any} value Value to set
function config_set(section, key, value) {
    var struct_key = string("{0}.{1}", section, key);
    global.config[$ struct_key] = value;
}