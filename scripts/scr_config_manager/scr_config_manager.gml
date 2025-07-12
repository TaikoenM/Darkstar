/// @description Initialize the configuration manager and load settings from file
/// @description Sets up default configuration values and loads user settings from config file
/// @description Must be called before any other systems that depend on configuration
function config_init() {
    global.config_file = "game_config.ini";
    global.config_loaded = false;
    
    // Initialize game options structure with subsections
    global.game_options = {
        display: {
            width: 1920,
            height: 1080,
            fullscreen: false,
            vsync: true
        },
        ui: {
            button_width: 300,
            button_height: 60,
            button_spacing: 80,
            font_size: 24
        },
        assets: {
            images_path: "assets/images/",
            sounds_path: "assets/sounds/",
            data_path: "assets/data/"
        },
        logging: {
            enabled: true,
            level: LogLevel.INFO,
            file: "game_log.txt"
        },
        menu: {
            center_x_offset: 0,
            center_y_offset: 0,
            start_y_offset: -240
        },
        performance: {
            target_fps: 60,
            fixed_timestep: true
        }
    };
    
    // Keep global.config for backwards compatibility during transition
    global.config = global.game_options;
    
    config_load();
    config_apply_display_settings();
}

/// @description Load configuration values from the INI file
/// @description Reads settings from file and applies them to global.game_options
/// @description Creates default config file if none exists or if file is empty
function config_load() {
    var needs_save = false;
    
    if (!file_exists(global.config_file)) {
        needs_save = true;
    } else {
        // Check if file is empty or corrupted
        try {
            ini_open(global.config_file);
            var test_value = ini_read_string("Display", "width", "NOT_FOUND");
            ini_close();
            
            // If no sections exist or key returns default, file is empty/corrupted
            if (test_value == "NOT_FOUND") {
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
        global.game_options.display.width = ini_read_real("Display", "width", global.game_options.display.width);
        global.game_options.display.height = ini_read_real("Display", "height", global.game_options.display.height);
        global.game_options.display.fullscreen = ini_read_real("Display", "fullscreen", global.game_options.display.fullscreen);
        global.game_options.display.vsync = ini_read_real("Display", "vsync", global.game_options.display.vsync);
        
        // UI settings
        global.game_options.ui.button_width = ini_read_real("UI", "button_width", global.game_options.ui.button_width);
        global.game_options.ui.button_height = ini_read_real("UI", "button_height", global.game_options.ui.button_height);
        global.game_options.ui.button_spacing = ini_read_real("UI", "button_spacing", global.game_options.ui.button_spacing);
        global.game_options.ui.font_size = ini_read_real("UI", "font_size", global.game_options.ui.font_size);
        
        // Asset paths - ensure we have valid defaults
        var default_images_path = global.game_options.assets.images_path;
        var default_sounds_path = global.game_options.assets.sounds_path;
        var default_data_path = global.game_options.assets.data_path;
        
        global.game_options.assets.images_path = ini_read_string("Assets", "images_path", default_images_path);
        global.game_options.assets.sounds_path = ini_read_string("Assets", "sounds_path", default_sounds_path);
        global.game_options.assets.data_path = ini_read_string("Assets", "data_path", default_data_path);
        
        // Logging settings
        global.game_options.logging.enabled = ini_read_real("Logging", "enabled", global.game_options.logging.enabled);
        global.game_options.logging.level = ini_read_real("Logging", "level", global.game_options.logging.level);
        var default_log_file = global.game_options.logging.file;
        global.game_options.logging.file = ini_read_string("Logging", "file", default_log_file);
        
        // Menu layout
        global.game_options.menu.center_x_offset = ini_read_real("Menu", "center_x_offset", global.game_options.menu.center_x_offset);
        global.game_options.menu.center_y_offset = ini_read_real("Menu", "center_y_offset", global.game_options.menu.center_y_offset);
        global.game_options.menu.start_y_offset = ini_read_real("Menu", "start_y_offset", global.game_options.menu.start_y_offset);
        
        // Performance settings
        global.game_options.performance.target_fps = ini_read_real("Performance", "target_fps", global.game_options.performance.target_fps);
        global.game_options.performance.fixed_timestep = ini_read_real("Performance", "fixed_timestep", global.game_options.performance.fixed_timestep);
        
        ini_close();
        global.config_loaded = true;
        
        // Update backwards compatibility reference
        global.config = global.game_options;
        
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
        ini_write_real("Display", "width", global.game_options.display.width);
        ini_write_real("Display", "height", global.game_options.display.height);
        ini_write_real("Display", "fullscreen", global.game_options.display.fullscreen);
        ini_write_real("Display", "vsync", global.game_options.display.vsync);
        
        // UI settings
        ini_write_real("UI", "button_width", global.game_options.ui.button_width);
        ini_write_real("UI", "button_height", global.game_options.ui.button_height);
        ini_write_real("UI", "button_spacing", global.game_options.ui.button_spacing);
        ini_write_real("UI", "font_size", global.game_options.ui.font_size);
        
        // Asset paths - ensure we write valid strings
        ini_write_string("Assets", "images_path", string(global.game_options.assets.images_path));
        ini_write_string("Assets", "sounds_path", string(global.game_options.assets.sounds_path));
        ini_write_string("Assets", "data_path", string(global.game_options.assets.data_path));
        
        // Logging settings
        ini_write_real("Logging", "enabled", global.game_options.logging.enabled);
        ini_write_real("Logging", "level", global.game_options.logging.level);
        ini_write_string("Logging", "file", string(global.game_options.logging.file));
        
        // Menu layout
        ini_write_real("Menu", "center_x_offset", global.game_options.menu.center_x_offset);
        ini_write_real("Menu", "center_y_offset", global.game_options.menu.center_y_offset);
        ini_write_real("Menu", "start_y_offset", global.game_options.menu.start_y_offset);
        
        // Performance settings
        ini_write_real("Performance", "target_fps", global.game_options.performance.target_fps);
        ini_write_real("Performance", "fixed_timestep", global.game_options.performance.fixed_timestep);
        
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

/// @description Get a configuration value from a specific section and key
/// @param {string} section Configuration section name
/// @param {string} key Configuration key name  
/// @param {any} default_value Default value if key not found
/// @return {any} Configuration value or default if not found
function config_get(section, key, default_value = undefined) {
    if (struct_exists(global.game_options, section)) {
        var section_struct = global.game_options[$ section];
        if (struct_exists(section_struct, key)) {
            return section_struct[$ key];
        }
    }
    return default_value;
}

/// @description Set a configuration value for a specific section and key
/// @param {string} section Configuration section name
/// @param {string} key Configuration key name
/// @param {any} value Value to set
function config_set(section, key, value) {
    if (struct_exists(global.game_options, section)) {
        var section_struct = global.game_options[$ section];
        section_struct[$ key] = value;
    }
}