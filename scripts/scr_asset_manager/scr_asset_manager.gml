/// @description Enhanced asset management system with detailed logging and proper paths
function assets_init() {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_init called", "Asset manager initialization started");
    
    global.loaded_sprites = ds_map_create();
    global.loaded_sounds = ds_map_create();
    global.asset_manifest = ds_map_create();
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Data structures created", 
                string("Sprites map: {0}, Sounds map: {1}, Manifest map: {2}", 
                       global.loaded_sprites, global.loaded_sounds, global.asset_manifest));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager initialized", "System startup");
        logger_write(LogLevel.INFO, "AssetManager", "Created data structures", 
                    string("Sprites: {0}, Sounds: {1}, Manifest: {2}", 
                           ds_exists(global.loaded_sprites, ds_type_map),
                           ds_exists(global.loaded_sounds, ds_type_map),
                           ds_exists(global.asset_manifest, ds_type_map)));
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Calling assets_load_manifest", "Loading asset manifest");
    assets_load_manifest();
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_init completed", "Asset manager ready");
}

function assets_load_manifest() {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_load_manifest called", "Manifest loading started");
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Starting manifest load process", "Loading asset definitions");
    }
    
    var manifest_file = working_directory + DATA_PATH + "asset_manifest.json";
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Manifest file path calculated", 
                string("Path: '{0}'", manifest_file));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Manifest file path determined", manifest_file);
        logger_write(LogLevel.INFO, "AssetManager", "Checking manifest file existence", 
                    string("File exists: {0}", file_exists(manifest_file)));
    }
    
    if (!file_exists(manifest_file)) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Manifest file not found", "Creating default manifest");
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.WARNING, "AssetManager", "Asset manifest not found, creating default", manifest_file);
        }
        assets_create_default_manifest();
        // After creating the file, try loading again
        manifest_file = working_directory + DATA_PATH + "asset_manifest.json";
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Loading manifest file", string("Path: '{0}'", manifest_file));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Loading asset manifest", manifest_file);
    }
    
    try {
        // Load JSON manifest
        logger_write(LogLevel.DEBUG, "AssetManager", "Calling json_load_file", string("File: '{0}'", manifest_file));
        var manifest = json_load_file(manifest_file);
        
        logger_write(LogLevel.DEBUG, "AssetManager", "JSON load result", 
                    string("Result type: {0}, Is undefined: {1}", typeof(manifest), is_undefined(manifest)));
        
        if (is_undefined(manifest)) {
            logger_write(LogLevel.WARNING, "AssetManager", "Manifest loading failed", "JSON result is undefined");
            // If still undefined, create default and return
            assets_create_default_manifest();
            return;
        }
        
        logger_write(LogLevel.DEBUG, "AssetManager", "Manifest loaded successfully", 
                    string("Type: {0}, Is struct: {1}", typeof(manifest), is_struct(manifest)));
        
        // Process images
        if (variable_struct_exists(manifest, "images")) {
            var images = manifest.images;
            var image_keys = variable_struct_get_names(images);
            
            logger_write(LogLevel.DEBUG, "AssetManager", "Processing images section", 
                        string("Image keys count: {0}", array_length(image_keys)));
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.INFO, "AssetManager", "Found image assets in manifest", 
                            string("Count: {0}", array_length(image_keys)));
            }
            
            for (var i = 0; i < array_length(image_keys); i++) {
                var asset_key = image_keys[i];
                var asset_data = images[$ asset_key];
                
                logger_write(LogLevel.DEBUG, "AssetManager", "Processing asset", 
                            string("Key: '{0}', Data type: {1}", asset_key, typeof(asset_data)));
                
                if (variable_struct_exists(asset_data, "file")) {
                    var file_path = asset_data.file;
                    ds_map_add(global.asset_manifest, asset_key, file_path);
                    
                    logger_write(LogLevel.DEBUG, "AssetManager", "Asset added to manifest", 
                                string("Key: '{0}' -> File: '{1}'", asset_key, file_path));
                    
                    if (variable_global_exists("log_enabled") && global.log_enabled) {
                        logger_write(LogLevel.DEBUG, "AssetManager", "Loaded asset definition", 
                                    string("Key: '{0}' -> File: '{1}'", asset_key, file_path));
                    }
                } else {
                    logger_write(LogLevel.WARNING, "AssetManager", "Asset missing file field", 
                                string("Key: '{0}'", asset_key));
                }
            }
        } else {
            logger_write(LogLevel.WARNING, "AssetManager", "No images section in manifest", "Missing images key");
        }
        
        // Process sounds (for future use)
        if (variable_struct_exists(manifest, "sounds")) {
            logger_write(LogLevel.DEBUG, "AssetManager", "Sounds section found", "Skipping for now");
            // TODO: Process sound assets
        }
        
        logger_write(LogLevel.DEBUG, "AssetManager", "Manifest processing completed", 
                    string("Total manifest entries: {0}", ds_map_size(global.asset_manifest)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Manifest load complete", 
                        string("Loaded {0} asset definitions successfully", ds_map_size(global.asset_manifest)));
        }
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "AssetManager", "Manifest loading exception", string("Error: {0}", error));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Error loading manifest", string(error));
        }
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_load_manifest completed", "Manifest loading finished");
}

function assets_create_default_manifest() {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_create_default_manifest called", "Creating default manifest");
    
    var manifest_file = working_directory + DATA_PATH + "asset_manifest.json";
    
    // Ensure data directory exists
    var data_dir = working_directory + DATA_PATH;
    logger_write(LogLevel.DEBUG, "AssetManager", "Checking data directory", 
                string("Path: '{0}', Exists: {1}", data_dir, directory_exists(data_dir)));
    
    if (!directory_exists(data_dir)) {
        try {
            logger_write(LogLevel.DEBUG, "AssetManager", "Creating data directory", string("Path: '{0}'", data_dir));
            directory_create(data_dir);
            logger_write(LogLevel.DEBUG, "AssetManager", "Data directory created", "Success");
        } catch (error) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to create data directory", string("Error: {0}", error));
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
        
        logger_write(LogLevel.DEBUG, "AssetManager", "Default manifest structure created", 
                    string("Version: {0}, Images count: 1", manifest.version));
        
        // Save to file
        logger_write(LogLevel.DEBUG, "AssetManager", "Saving default manifest", string("File: '{0}'", manifest_file));
        json_save_file(manifest_file, manifest);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "AssetManager", "Created default asset manifest", 
                        string("File: {0}", manifest_file));
        }
        
        logger_write(LogLevel.DEBUG, "AssetManager", "Default manifest saved successfully", "File written");
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "AssetManager", "Default manifest creation failed", string("Error: {0}", error));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to create default manifest", string(error));
        }
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_create_default_manifest completed", "Default manifest creation finished");
}

function assets_load_sprite(asset_key) {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_load_sprite called", 
                string("Asset key: '{0}'", asset_key));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Loading sprite requested", 
                    string("Asset key: '{0}'", asset_key));
    }
    
    // Validate input
    if (is_undefined(asset_key) || asset_key == "" || !is_string(asset_key)) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Invalid asset key", 
                    string("Type: {0}, Value: '{1}'", typeof(asset_key), string(asset_key)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Invalid asset key provided", 
                        string("Type: {0}, Value: '{1}'", typeof(asset_key), string(asset_key)));
        }
        return -1;
    }
    
    // Check if already loaded
    if (ds_map_exists(global.loaded_sprites, asset_key)) {
        var cached_sprite = ds_map_find_value(global.loaded_sprites, asset_key);
        
        logger_write(LogLevel.DEBUG, "AssetManager", "Found cached sprite", 
                    string("Key: '{0}', Cached value: {1}", asset_key, cached_sprite));
        
        if (!is_undefined(cached_sprite)) {
            // Check for special error values
            if (cached_sprite == -1) {
                logger_write(LogLevel.DEBUG, "AssetManager", "Cached failure found", 
                            string("Key: '{0}' previously failed to load", asset_key));
                
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.DEBUG, "AssetManager", "Asset previously failed to load", 
                                string("Key: '{0}' (cached failure)", asset_key));
                }
                return -1;
            }
            if (sprite_exists(cached_sprite)) {
                logger_write(LogLevel.DEBUG, "AssetManager", "Valid cached sprite found", 
                            string("Key: '{0}', Sprite ID: {1}", asset_key, cached_sprite));
                
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.DEBUG, "AssetManager", "Asset loaded from cache", 
                                string("Key: '{0}' -> Sprite ID: {1}", asset_key, cached_sprite));
                }
                return cached_sprite;
            } else {
                logger_write(LogLevel.WARNING, "AssetManager", "Cached sprite invalid", 
                            string("Key: '{0}', Invalid sprite ID: {1}", asset_key, cached_sprite));
                
                if (variable_global_exists("log_enabled") && global.log_enabled) {
                    logger_write(LogLevel.WARNING, "AssetManager", "Cached sprite no longer exists", 
                                string("Key: '{0}', Invalid sprite ID: {1}", asset_key, cached_sprite));
                }
            }
        }
        // Remove invalid cache entry
        logger_write(LogLevel.DEBUG, "AssetManager", "Removing invalid cache entry", 
                    string("Key: '{0}'", asset_key));
        ds_map_delete(global.loaded_sprites, asset_key);
    }
    
    // Get file path from manifest
    logger_write(LogLevel.DEBUG, "AssetManager", "Looking up asset in manifest", 
                string("Key: '{0}', Manifest size: {1}", asset_key, ds_map_size(global.asset_manifest)));
    
    var file_path = ds_map_find_value(global.asset_manifest, asset_key);
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Manifest lookup result", 
                string("Key: '{0}', Path: '{1}', Type: {2}", asset_key, file_path, typeof(file_path)));
    
    if (is_undefined(file_path) || !is_string(file_path)) {
        logger_write(LogLevel.ERROR, "AssetManager", "Asset not found in manifest", 
                    string("Key: '{0}', Manifest entries: {1}", asset_key, ds_map_size(global.asset_manifest)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Asset key not found in manifest", 
                        string("Key: '{0}' not in manifest with {1} entries", asset_key, ds_map_size(global.asset_manifest)));
        }
        // Cache the failure to prevent spam
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "File path found", 
                string("Key: '{0}' -> Path: '{1}'", asset_key, file_path));
    
    // Check file existence
    var file_exists_result = file_exists(file_path);
    logger_write(LogLevel.DEBUG, "AssetManager", "File existence check", 
                string("Path: '{0}', Exists: {1}", file_path, file_exists_result));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Attempting to load sprite", 
                    string("Key: '{0}' -> Path: '{1}'", asset_key, file_path));
        logger_write(LogLevel.DEBUG, "AssetManager", "File existence check", 
                    string("Path: '{0}', Exists: {1}", file_path, file_exists_result));
    }
    
    var loaded_sprite = -1;
    
    try {
        logger_write(LogLevel.DEBUG, "AssetManager", "Calling sprite_add", 
                    string("Path: '{0}'", file_path));
        
        // For included files, use the path directly
        loaded_sprite = sprite_add(file_path, 0, false, false, 0, 0);
        
        logger_write(LogLevel.DEBUG, "AssetManager", "sprite_add completed", 
                    string("Path: '{0}', Result: {1}", file_path, loaded_sprite));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "sprite_add call result", 
                        string("Path: '{0}' -> Result: {1}", file_path, loaded_sprite));
        }
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "AssetManager", "sprite_add exception", 
                    string("Path: '{0}', Error: {1}", file_path, error));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "sprite_add threw exception", 
                        string("Path: '{0}', Error: {1}", file_path, error));
        }
    }
    
    if (loaded_sprite == -1) {
        logger_write(LogLevel.ERROR, "AssetManager", "Sprite loading failed", 
                    string("Path: '{0}' returned -1", file_path));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Failed to load sprite", 
                        string("Path: '{0}' returned -1", file_path));
        }
        // Cache the failure to prevent spam
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    // Verify the loaded sprite
    var sprite_valid = sprite_exists(loaded_sprite);
    logger_write(LogLevel.DEBUG, "AssetManager", "Sprite validation", 
                string("Sprite ID: {0}, Valid: {1}", loaded_sprite, sprite_valid));
    
    if (!sprite_valid) {
        logger_write(LogLevel.ERROR, "AssetManager", "Sprite validation failed", 
                    string("sprite_exists({0}) returned false", loaded_sprite));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "AssetManager", "Loaded sprite failed validation", 
                        string("sprite_exists({0}) returned false", loaded_sprite));
        }
        ds_map_add(global.loaded_sprites, asset_key, -1);
        return -1;
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Sprite loaded successfully", 
                string("ID: {0}, Size: {1}x{2}", loaded_sprite, sprite_get_width(loaded_sprite), sprite_get_height(loaded_sprite)));
    
    // Cache the loaded sprite
    ds_map_add(global.loaded_sprites, asset_key, loaded_sprite);
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Sprite cached", 
                string("Key: '{0}' -> ID: {1}", asset_key, loaded_sprite));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Successfully loaded and cached sprite", 
                    string("Key: '{0}' -> Sprite ID: {1}, Size: {2}x{3}", 
                           asset_key, loaded_sprite, sprite_width, sprite_height));
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_load_sprite completed", 
                string("Key: '{0}', Result: {1}", asset_key, loaded_sprite));
    
    return loaded_sprite;
}

function assets_get_sprite(asset_key) {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite called", 
                string("Asset key: '{0}'", asset_key));
    
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Invalid input for assets_get_sprite", 
                    string("Type: {0}", typeof(asset_key)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite invalid input", 
                        string("Type: {0}", typeof(asset_key)));
        }
        return -1;
    }
    
    var sprite_id = ds_map_find_value(global.loaded_sprites, asset_key);
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Cache lookup result", 
                string("Key: '{0}', Cached value: {1}, Type: {2}", asset_key, sprite_id, typeof(sprite_id)));
    
    if (is_undefined(sprite_id) || !sprite_exists(sprite_id)) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Not cached or invalid, attempting load", 
                    string("Key: '{0}', Cached: {1}, Valid: {2}", asset_key, sprite_id, 
                           is_undefined(sprite_id) ? "undefined" : sprite_exists(sprite_id)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "Sprite not cached, attempting load", 
                        string("Key: '{0}'", asset_key));
        }
        return assets_load_sprite(asset_key);
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Returning cached sprite", 
                string("Key: '{0}' -> ID: {1}", asset_key, sprite_id));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Returning cached sprite", 
                    string("Key: '{0}' -> ID: {1}", asset_key, sprite_id));
    }
    
    return sprite_id;
}

function assets_get_sprite_safe(asset_key) {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe called", 
                string("Asset key: '{0}'", asset_key));
    
    if (is_undefined(asset_key) || !is_string(asset_key)) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Invalid input for assets_get_sprite_safe", 
                    string("Type: {0}", typeof(asset_key)));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe invalid input", 
                        string("Returning -1 for invalid input: {0}", typeof(asset_key)));
        }
        return -1;
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Calling assets_get_sprite", 
                string("Key: '{0}'", asset_key));
    
    var sprite_id = assets_get_sprite(asset_key);
    
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite result", 
                string("Key: '{0}', Result: {1}", asset_key, sprite_id));
    
    // Return a valid sprite or -1
    if (sprite_id != -1 && sprite_exists(sprite_id)) {
        logger_write(LogLevel.DEBUG, "AssetManager", "Valid sprite returned", 
                    string("Key: '{0}' -> ID: {1}", asset_key, sprite_id));
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe success", 
                        string("Key: '{0}' -> Valid sprite ID: {1}", asset_key, sprite_id));
        }
        return sprite_id;
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Invalid sprite, returning fallback", 
                string("Key: '{0}', Sprite ID: {1}, Valid: {2}", asset_key, sprite_id, sprite_exists(sprite_id)));
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.DEBUG, "AssetManager", "assets_get_sprite_safe fallback", 
                    string("Key: '{0}' -> Returning -1 (fallback)", asset_key));
    }
    
    return -1;
}

function assets_cleanup() {
    logger_write(LogLevel.DEBUG, "AssetManager", "assets_cleanup called", "Asset cleanup started");
    
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
        
        logger_write(LogLevel.DEBUG, "AssetManager", "Processing sprite for cleanup", 
                    string("Key: '{0}', Sprite ID: {1}", key, sprite_id));
        
        if (!is_undefined(sprite_id) && sprite_id != -1 && sprite_exists(sprite_id)) {
            logger_write(LogLevel.DEBUG, "AssetManager", "Freeing sprite", 
                        string("Key: '{0}', ID: {1}", key, sprite_id));
            sprite_delete(sprite_id);
            sprites_freed++;
            
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.DEBUG, "AssetManager", "Freed sprite", 
                            string("Key: '{0}', ID: {1}", key, sprite_id));
            }
        }
        key = ds_map_find_next(global.loaded_sprites, key);
    }
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Destroying data structures", 
                string("Freed {0} sprites", sprites_freed));
    
    // Destroy data structures
    ds_map_destroy(global.loaded_sprites);
    ds_map_destroy(global.loaded_sounds);
    ds_map_destroy(global.asset_manifest);
    
    logger_write(LogLevel.DEBUG, "AssetManager", "Data structures destroyed", "Cleanup completed");
    
    if (variable_global_exists("log_enabled") && global.log_enabled) {
        logger_write(LogLevel.INFO, "AssetManager", "Asset manager cleanup complete", 
                    string("Freed {0} sprites and destroyed data structures", sprites_freed));
    }
}