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
    
    // Safe access to config
    if (variable_global_exists("config") && !is_undefined(global.config)) {
        manifest_file = global.config.asset_path_data + "asset_manifest.ini";
    } else {
        manifest_file = "datafiles/assets/data/asset_manifest.ini";
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
                var full_path = "";
                if (variable_global_exists("config") && !is_undefined(global.config)) {
                    full_path = global.config.asset_path_images + asset_file;
                } else {
                    full_path = "datafiles/assets/images/" + asset_file;
                }
                global.asset_manifest[? asset_key] = full_path;
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
    
    if (variable_global_exists("config") && !is_undefined(global.config)) {
        manifest_file = global.config.asset_path_data + "asset_manifest.ini";
    } else {
        manifest_file = "datafiles/assets/data/asset_manifest.ini";
    }
    
    // Ensure the directory exists
    var directory = filename_dir(manifest_file);
    if (!directory_exists(directory)) {
        directory_create(directory);
    }
    
    try {
        // Open INI file for writing
        ini_open(manifest_file);
        
        // Create default manifest entries
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
    if (is_undefined(asset_key) || asset_key == "") {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Invalid asset key provided", "Empty or undefined key");
        }
        return -1;
    }
    
    // Check if already loaded
    if (ds_map_exists(global.loaded_sprites, asset_key)) {
        var cached_sprite = global.loaded_sprites[? asset_key];
        if (!is_undefined(cached_sprite) && sprite_exists(cached_sprite)) {
            return cached_sprite;
        } else {
            // Remove invalid cache entry
            ds_map_delete(global.loaded_sprites, asset_key);
        }
    }
    
    // Get file path from manifest
    var file_path = global.asset_manifest[? asset_key];
    if (is_undefined(file_path)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", 
                        string("Asset key not found in manifest: {0}", asset_key), "Missing asset definition");
        }
        return -1;
    }
    
    // Check if file exists
    if (!file_exists(file_path)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", 
                        string("Asset file not found: {0}", file_path), "Missing file");
        }
        return -1;
    }
    
    try {
        // Load the sprite
        var sprite_id = sprite_add(file_path, 0, false, false, 0, 0);
        
        if (sprite_id == -1) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.ERROR, "AssetManager", 
                            string("Failed to load sprite: {0}", file_path), "Sprite loading error");
            }
            return -1;
        }
        
        // Cache the loaded sprite
        global.loaded_sprites[? asset_key] = sprite_id;
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", 
                        string("Loaded sprite: {0} from {1}", asset_key, file_path), "Dynamic loading");
        }
        return sprite_id;
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", 
                        string("Exception loading sprite {0}: {1}", asset_key, error), "Loading exception");
        }
        return -1;
    }
}

/// @description Get a sprite resource, loading it if not already cached
/// @param {string} asset_key Key identifier for the asset
/// @return {Asset.GMSprite} Sprite resource ID or -1 if failed
function assets_get_sprite(asset_key) {
    var sprite_id = global.loaded_sprites[? asset_key];
    if (is_undefined(sprite_id) || !sprite_exists(sprite_id)) {
        return assets_load_sprite(asset_key);
    }
    return sprite_id;
}

/// @description Get a sprite resource that's safe to use in drawing functions
/// @param {string} asset_key Key identifier for the asset
/// @return {Asset.GMSprite} Valid sprite resource ID or sprite_get("spr_missing") as fallback
function assets_get_sprite_safe(asset_key) {
    var sprite_id = assets_get_sprite(asset_key);
    
    // Return a valid sprite or a default missing sprite
    if (sprite_id != -1 && sprite_exists(sprite_id)) {
        return sprite_id;
    }
    
    // Try to return a built-in sprite as fallback
    // In a real project, you'd have a default "missing texture" sprite
    return -1;
}

/// @description Cleanup asset manager and free all loaded resources
/// @description Should be called during game shutdown
function assets_cleanup() {
    // Free all loaded sprites
    var key = ds_map_find_first(global.loaded_sprites);
    while (!is_undefined(key)) {
        var sprite_id = global.loaded_sprites[? key];
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