/// @description Enhanced asset management system with detailed logging and proper paths
function assets_init() {
    global.loaded_sprites = ds_map_create();
    global.loaded_sounds = ds_map_create();
    global.asset_manifest = ds_map_create();
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager initialized", "System startup");
        logger_write(LogLevel.INFO, "AssetManager", "Created data structures", 
                    string("Sprites: {0}, Sounds: {1}, Manifest: {2}", 
                           ds_exists(global.loaded_sprites, ds_type_map),
                           ds_exists(global.loaded_sounds, ds_type_map),
                           ds_exists(global.asset_manifest, ds_type_map)));
    }
    
    assets_load_manifest();
}

function assets_load_manifest() {
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Starting manifest load process", "Loading asset definitions");
    }
    
    var manifest_file = working_directory + DATA_PATH + ASSET_MANIFEST_FILE;
    
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
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Loading asset manifest", manifest_file);
    }
    
    try {
        // Load JSON manifest
        var manifest = json_load_file(manifest_file);
        if (is_undefined(manifest)) {
            assets_create_default_manifest();
            manifest = json_load_file(manifest_file);
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
                    ds_map_add(global.asset_manifest, asset_key, asset_data.file);
                    if (variable_global_exists("log_enabled") && global.log_enabled) {
                        logger_write(LogLevel.DEBUG, "AssetManager", "Loaded asset definition", 
                                    string("Key: '{0}' -> File: '{1}'", asset_key, asset_data.file));
                    }
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
    var manifest_file = "";
    
    // Use correct property path with proper type checking
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "assets") && 
            variable_struct_exists(global.game_options.assets, "data_path")) {
            manifest_file = working_directory + global.game_options.assets.data_path + "asset_manifest.ini";
        } else {
            manifest_file = working_directory + "assets/data/asset_manifest.ini";
        }
    } else {
        manifest_file = working_directory + "assets/data/asset_manifest.ini";
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Creating default manifest", manifest_file);
    }
    
    try {
        // Open INI file for writing
        ini_open(manifest_file);
        
        // Create default manifest entries - use the CORRECT path that works
        ini_write_real("Images", "count", 1);
        ini_write_string("Images", "asset_0_key", "mainmenu_background");
        ini_write_string("Images", "asset_0_file", "assets/images/mainmenu_background.png"); // This is the correct path!
        
        // Close INI file
        ini_close();
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Created default asset manifest", 
                        string("File: {0} with 1 default asset", manifest_file));
            logger_write(LogLevel.DEBUG, "AssetManager", "Default asset created", 
                        "mainmenu_background -> assets/images/mainmenu_background.png");
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to create default manifest", string(error));
        }
    }
}

/// @description Load and update existing manifest to correct wrong paths
function assets_fix_manifest_paths() {
    var manifest_file = "";
    
    // Use correct property path with proper type checking
    if (variable_global_exists("game_options") && !is_undefined(global.game_options)) {
        if (variable_struct_exists(global.game_options, "assets") && 
            variable_struct_exists(global.game_options.assets, "data_path")) {
            manifest_file = working_directory + global.game_options.assets.data_path + "asset_manifest.ini";
        } else {
            manifest_file = working_directory + "assets/data/asset_manifest.ini";
        }
    } else {
        manifest_file = working_directory + "assets/data/asset_manifest.ini";
    }
    
    if (!file_exists(manifest_file)) {
        return; // No manifest to fix
    }
    
    var needs_update = false;
    
    try {
        ini_open(manifest_file);
        
        // Check if mainmenu_background has wrong path
        var bg_file = ini_read_string("Images", "asset_0_file", "");
        if (bg_file == "mainmenu_background.png") {
            // Wrong path, fix it
            ini_write_string("Images", "asset_0_file", "assets/images/mainmenu_background.png");
            needs_update = true;
        }
        
        ini_close();
        
        if (needs_update && variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Fixed manifest paths", 
                        "Updated mainmenu_background path");
        }
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to fix manifest paths", string(error));
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
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.DEBUG, "AssetManager", "Asset previously failed to load", 
                                string("Key: '{0}' (cached failure)", asset_key));
                }
                return -1;
            }
            if (sprite_exists(cached_sprite)) {
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.DEBUG, "AssetManager", "Asset loaded from cache", 
                                string("Key: '{0}' -> Sprite ID: {1}", asset_key, cached_sprite));
                }
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
        logger_write(LogLevel.DEBUG, "AssetManager", "File existence check", 
                    string("Path: '{0}', Exists: {1}", file_path, file_exists(file_path)));
    }
    
    var loaded_sprite = -1;
    
    try {
        // For included files, use the path directly
        loaded_sprite = sprite_add(file_path, 0, false, false, 0, 0);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "sprite_add call result", 
                        string("Path: '{0}' -> Result: {1}", file_path, loaded_sprite));
        }
        
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
                           asset_key, loaded_sprite, 
                           sprite_get_width(loaded_sprite), 
                           sprite_get_height(loaded_sprite)));
    }
    
    return loaded_sprite;
}

function assets_get_sprite(asset_key) {
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite invalid input", 
                        string("Type: {0}", typeof(asset_key)));
        }
        return -1;
    }
    
    var sprite_id = ds_map_find_value(global.loaded_sprites, asset_key);
    if (is_undefined(sprite_id) || !sprite_exists(sprite_id)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "Sprite not cached, attempting load", 
                        string("Key: '{0}'", asset_key));
        }
        return assets_load_sprite(asset_key);
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Returning cached sprite", 
                    string("Key: '{0}' -> ID: {1}", asset_key, sprite_id));
    }
    
    return sprite_id;
}

function assets_get_sprite_safe(asset_key) {
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe invalid input", 
                        string("Returning -1 for invalid input: {0}", typeof(asset_key)));
        }
        return -1;
    }
    
    var sprite_id = assets_get_sprite(asset_key);
    
    // Return a valid sprite or -1
    if (sprite_id != -1 && sprite_exists(sprite_id)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe success", 
                        string("Key: '{0}' -> Valid sprite ID: {1}", asset_key, sprite_id));
        }
        return sprite_id;
    }
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe fallback", 
                    string("Key: '{0}' -> Returning -1 (fallback)", asset_key));
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
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.DEBUG, "AssetManager", "Freed sprite", 
                            string("Key: '{0}', ID: {1}", key, sprite_id));
            }
        }
        key = ds_map_find_next(global.loaded_sprites, key);
    }
    
    // Destroy data structures
    ds_map_destroy(global.loaded_sprites);
    ds_map_destroy(global.loaded_sounds);
    ds_map_destroy(global.asset_manifest);
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager cleanup complete", 
                    string("Freed {0} sprites and destroyed data structures", sprites_freed));
    }
}