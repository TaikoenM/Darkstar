/// @description Initialize the asset management system
/// @description Creates data structures for asset caching and loads manifest file
/// @description Requires config system to be initialized first for asset paths
function assets_init() {
    global.loaded_sprites = ds_map_create();
    global.loaded_sounds = ds_map_create();
    global.asset_manifest = ds_map_create();
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager initialized", "System startup");
    }
    
    assets_load_manifest();
}

/// @description Load asset manifest file that maps asset keys to file paths
/// @description Creates default manifest if none exists
function assets_load_manifest() {
    var manifest_file = "";
    
    // Use correct property path with proper type checking
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "assets") && 
            variable_struct_exists(global.game_options.assets, "data_path")) {
            manifest_file = working_directory + global.game_options.assets.data_path + "asset_manifest.ini";
        } else {
            manifest_file = working_directory + "datafiles/assets/data/asset_manifest.ini";
        }
    } else {
        manifest_file = working_directory + "datafiles/assets/data/asset_manifest.ini";
    }
    
    if (!file_exists(manifest_file)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.WARNING, "AssetManager", "Asset manifest not found, creating default", manifest_file);
        }
        assets_create_default_manifest();
        // After creating the file, we need to continue and load it
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Loading asset manifest", manifest_file);
    }
    
    try {
        // Open the INI file for reading
        ini_open(manifest_file);
        
        // Load image assets
        var image_count = ini_read_real("Images", "count", 0);
        for (var i = 0; i < image_count; i++) {
            var asset_key = ini_read_string("Images", string("asset_{0}_key", i), "");
            var asset_file = ini_read_string("Images", string("asset_{0}_file", i), "");
            
            if (asset_key != "" && asset_file != "") {
                // For included files, just use the filename
                ds_map_add(global.asset_manifest, asset_key, asset_file);
            }
        }
        
        // Close the INI file
        ini_close();
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", 
                        string("Loaded {0} asset definitions", ds_map_size(global.asset_manifest)), "Manifest processed");
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Error loading manifest", string(error));
        }
    }
}

/// @description Create a default asset manifest file with basic entries
/// @description Called when no manifest file exists
function assets_create_default_manifest() {
    var manifest_file = "";
    
    // Use correct property path with proper type checking
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "assets") && 
            variable_struct_exists(global.game_options.assets, "data_path")) {
            manifest_file = working_directory + global.game_options.assets.data_path + "asset_manifest.ini";
        } else {
            manifest_file = working_directory + "datafiles/assets/data/asset_manifest.ini";
        }
    } else {
        manifest_file = working_directory + "datafiles/assets/data/asset_manifest.ini";
    }
    
    try {
        // Open INI file for writing
        ini_open(manifest_file);
        
        // Create default manifest entries - files from datafiles are accessed directly by name
        ini_write_real("Images", "count", 1);
        ini_write_string("Images", "asset_0_key", "mainmenu_background");
        ini_write_string("Images", "asset_0_file", "mainmenu_background.png");
        
        // Close INI file
        ini_close();
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Created default asset manifest", manifest_file);
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to create default manifest", string(error));
        }
    }
}

/// @description Load a sprite dynamically from disk and cache it
/// @param {string} asset_key Key identifier for the asset in the manifest
/// @return {Asset.GMSprite} Sprite resource ID or -1 if loading failed
function assets_load_sprite(asset_key) {
    // Validate input
    if (is_undefined(asset_key) || asset_key == "" || !is_string(asset_key)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Invalid asset key provided", "Empty, undefined, or non-string key");
        }
        return -1;
    }
    
    // Check if already loaded
    if (ds_map_exists(global.loaded_sprites, asset_key)) {
        var cached_sprite = ds_map_find_value(global.loaded_sprites, asset_key);
        if (!is_undefined(cached_sprite)) {
            // Check for special error values
            if (cached_sprite == -1) {
                // Already tried and failed, don't spam errors
                return -1;
            }
            if (sprite_exists(cached_sprite)) {
                return cached_sprite;
            }
        }
        // Remove invalid cache entry
        ds_map_delete(global.loaded_sprites, asset_key);
    }
    
    // Get file path from manifest
    var file_path = ds_map_find_value(global.asset_manifest, asset_key);
    if (is_undefined(file_path) || !is_string(file_path)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", 
                        string("Asset key not found in manifest: {0}", asset_key), "Missing asset definition");
        }
        // Cache the failure to prevent spam
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    // For included files in GameMaker, they are accessible directly by filename
    var loaded_sprite = -1;
    var path_found = "";
    
    try {
        // For included files, just use the filename directly
        loaded_sprite = sprite_add(file_path, 0, false, false, 0, 0);
        
        if (loaded_sprite != -1) {
            path_found = file_path;
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", 
                        string("Failed to load sprite: {0}", file_path), 
                        string("Error: {0}", error));
        }
    }
    
    if (loaded_sprite == -1) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", 
                        string("Failed to load sprite: {0}", file_path), 
                        "sprite_add returned -1");
        }
        // Cache the failure to prevent spam
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    // Cache the loaded sprite
    ds_map_add(global.loaded_sprites, asset_key, loaded_sprite);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", 
                    string("Loaded sprite: {0} from {1}", asset_key, path_found), "Dynamic loading");
    }
    return loaded_sprite;
}

/// @description Get a sprite resource, loading it if not already cached
/// @param {string} asset_key Key identifier for the asset
/// @return {Asset.GMSprite} Sprite resource ID or -1 if failed
function assets_get_sprite(asset_key) {
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        return -1;
    }
    
    var sprite_id = ds_map_find_value(global.loaded_sprites, asset_key);
    if (is_undefined(sprite_id) || !sprite_exists(sprite_id)) {
        return assets_load_sprite(asset_key);
    }
    return sprite_id;
}

/// @description Get a sprite resource that's safe to use in drawing functions
/// @param {string} asset_key Key identifier for the asset
/// @return {Asset.GMSprite} Valid sprite resource ID or -1 as fallback
function assets_get_sprite_safe(asset_key) {
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        return -1;
    }
    
    var sprite_id = assets_get_sprite(asset_key);
    
    // Return a valid sprite or -1
    if (sprite_id != -1 && sprite_exists(sprite_id)) {
        return sprite_id;
    }
    
    // In a real project, you'd have a default "missing texture" sprite
    return -1;
}

/// @description Cleanup asset manager and free all loaded resources
/// @description Should be called during game shutdown
function assets_cleanup() {
    // Free all loaded sprites
    var key = ds_map_find_first(global.loaded_sprites);
    while (!is_undefined(key)) {
        var sprite_id = ds_map_find_value(global.loaded_sprites, key);
        if (!is_undefined(sprite_id) && sprite_exists(sprite_id)) {
            sprite_delete(sprite_id);
        }
        key = ds_map_find_next(global.loaded_sprites, key);
    }
    
    // Destroy data structures
    ds_map_destroy(global.loaded_sprites);
    ds_map_destroy(global.loaded_sounds);
    ds_map_destroy(global.asset_manifest);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager cleaned up", "System shutdown");
    }
}