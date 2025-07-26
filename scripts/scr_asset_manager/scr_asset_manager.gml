/// @description Enhanced asset management system with detailed logging and proper paths
function assets_init() {
    global.loaded_sprites = ds_map_create();
	global.asset_hex_sprite = ds_map_create();
    global.loaded_sounds = ds_map_create();
    global.asset_manifest = ds_map_create();
    
	show_debug_message("======== ASSETS ========")
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager initialized", "System startup");
    }
	// Load Sprites

	load_sprites_from_directory(working_directory + IMAGES_PATH + "hex\\","hex", global.asset_hex_sprite)
    
    assets_load_manifest();
}

function assets_load_manifest() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Starting manifest load process", "Loading asset definitions");
    }
    
    var manifest_file = working_directory + DATA_PATH + "asset_manifest.json";
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Manifest file path determined", manifest_file);
        logger_write(LogLevel.INFO, "AssetManager", "Checking manifest file existence", 
                    string("File exists: {0}", file_exists(manifest_file)));
    }
    
    if (!file_exists(manifest_file)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.WARNING, "AssetManager", "Asset manifest not found, creating default", manifest_file);
        }
        assets_create_default_manifest();
        // After creating the file, try loading again
        manifest_file = working_directory + DATA_PATH + "asset_manifest.json";
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Loading asset manifest", manifest_file);
    }
    
    try {
        // Load JSON manifest
        var manifest = json_load_file(manifest_file);
        
        if (is_undefined(manifest)) {
            // If still undefined, create default and return
            assets_create_default_manifest();
            return;
        }
        
        // Process images
        if (variable_struct_exists(manifest, "images")) {
            var images = manifest.images;
            var image_keys = variable_struct_get_names(images);
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.INFO, "AssetManager", "Found image assets in manifest", 
                            string("Count: {0}", array_length(image_keys)));
            }
            
            for (var i = 0; i < array_length(image_keys); i++) {
                var asset_key = image_keys[i];
                var asset_data = images[$ asset_key];
                
                if (variable_struct_exists(asset_data, "file")) {
                    var file_path = asset_data.file;
                    ds_map_add(global.asset_manifest, asset_key, file_path);
                } else {
                    logger_write(LogLevel.WARNING, "AssetManager", "Asset missing file field", 
                                string("Key: '{0}'", asset_key));
                }
            }
        }
        
        // Process sounds (for future use)
        if (variable_struct_exists(manifest, "sounds")) {
            // TODO: Process sound assets
        }
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Manifest load complete", 
                        string("Loaded {0} asset definitions successfully", ds_map_size(global.asset_manifest)));
        }
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Error loading manifest", string(error));
        }
    }
}

function assets_create_default_manifest() {
    var manifest_file = working_directory + DATA_PATH + "asset_manifest.json";
    
    // Ensure data directory exists
    var data_dir = working_directory + DATA_PATH;
    
    if (!directory_exists(data_dir)) {
        try {
            directory_create(data_dir);
        } catch (error) {
            show_debug_message("Failed to create data directory: " + string(error));
        }
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Creating default manifest", manifest_file);
    }
    
    try {
        // Create default manifest structure
        var manifest = {
            version: "1.0",
            images: {
                mainmenu_background: {
                    file: "assets/images/mainmenu_background.png",
                    type: "background"
                }
            },
            sounds: {},
            music: {}
        };
        
        // Save to file
        json_save_file(manifest_file, manifest);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Created default asset manifest", 
                        string("File: {0}", manifest_file));
        }
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to create default manifest", string(error));
        }
    }
}

function assets_load_sprite(asset_key) {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Loading sprite requested", 
                    string("Asset key: '{0}'", asset_key));
    }
    
    // Validate input
    if (is_undefined(asset_key) || asset_key == "" || !is_string(asset_key)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Invalid asset key provided", 
                        string("Type: {0}, Value: '{1}'", typeof(asset_key), string(asset_key)));
        }
        return -1;
    }
    
    // Check if already loaded
    if (ds_map_exists(global.loaded_sprites, asset_key)) {
        var cached_sprite = ds_map_find_value(global.loaded_sprites, asset_key);
        
        if (!is_undefined(cached_sprite)) {
            // Check for special error values
            if (cached_sprite == -1) {
                return -1;
            }
            if (sprite_exists(cached_sprite)) {
                return cached_sprite;
            } else {
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.WARNING, "AssetManager", "Cached sprite no longer exists", 
                                string("Key: '{0}', Invalid sprite ID: {1}", asset_key, cached_sprite));
                }
            }
        }
        // Remove invalid cache entry
        ds_map_delete(global.loaded_sprites, asset_key);
    }
    
    // Get file path from manifest
    var file_path = ds_map_find_value(global.asset_manifest, asset_key);
    
    if (is_undefined(file_path) || !is_string(file_path)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Asset key not found in manifest", 
                        string("Key: '{0}' not in manifest with {1} entries", asset_key, ds_map_size(global.asset_manifest)));
        }
        // Cache the failure to prevent spam
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Attempting to load sprite", 
                    string("Key: '{0}' -> Path: '{1}'", asset_key, file_path));
    }
    
    var loaded_sprite = -1;
    
    try {
        // For included files, use the path directly - load 1 frame
        loaded_sprite = sprite_add(file_path, 1, false, false, 0, 0);
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "sprite_add threw exception", 
                        string("Path: '{0}', Error: {1}", file_path, error));
        }
    }
    
    if (loaded_sprite == -1) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to load sprite", 
                        string("Path: '{0}' returned -1", file_path));
        }
        // Cache the failure to prevent spam
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    // Verify the loaded sprite
    if (!sprite_exists(loaded_sprite)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Loaded sprite failed validation", 
                        string("sprite_exists({0}) returned false", loaded_sprite));
        }
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    // Cache the loaded sprite
    ds_map_add(global.loaded_sprites, asset_key, loaded_sprite);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Successfully loaded and cached sprite", 
                    string("Key: '{0}' -> Sprite ID: {1}, Size: {2}x{3}", 
                           asset_key, loaded_sprite, sprite_get_width(loaded_sprite), sprite_get_height(loaded_sprite)));
    }
    
    return loaded_sprite;
}

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

function assets_get_sprite_safe(asset_key) {
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        return -1;
    }
    
    var sprite_id = assets_get_sprite(asset_key);
    
    // Return a valid sprite or -1
    if (sprite_id != -1 && sprite_exists(sprite_id)) {
        return sprite_id;
    }
    
    return -1;
}

function assets_cleanup() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Starting asset cleanup", 
                    string("Loaded sprites: {0}, Manifest entries: {1}", 
                           ds_map_size(global.loaded_sprites), 
                           ds_map_size(global.asset_manifest)));
    }
    
    var sprites_freed = 0;
    
    // Free all loaded sprites
    var key = ds_map_find_first(global.loaded_sprites);
    while (!is_undefined(key)) {
        var sprite_id = ds_map_find_value(global.loaded_sprites, key);
        
        if (!is_undefined(sprite_id) && sprite_id != -1 && sprite_exists(sprite_id)) {
            sprite_delete(sprite_id);
            sprites_freed++;
        }
        key = ds_map_find_next(global.loaded_sprites, key);
    }
    
    // Destroy data structures
    ds_map_destroy(global.loaded_sprites);
    ds_map_destroy(global.loaded_sounds);
    ds_map_destroy(global.asset_manifest);
	ds_map_destroy(global.asset_hex_sprite);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager cleanup complete", 
                    string("Freed {0} sprites and destroyed data structures", sprites_freed));
    }
}