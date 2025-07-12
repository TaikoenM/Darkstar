/// @function json_load_file(filename)
/// @description Load and parse a JSON file
/// @param {string} filename Path to the JSON file
/// @return {struct|undefined} Parsed JSON data or undefined on error
function json_load_file(filename) {
    // Check if file exists
    if (!file_exists(filename)) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "JSONUtils", 
                        string("JSON file not found: {0}", filename), "File loading failed");
        }
        return undefined;
    }
    
    try {
        // Read file content
        var file = file_text_open_read(filename);
        var json_string = "";
        
        while (!file_text_eof(file)) {
            json_string += file_text_read_string(file);
            file_text_readln(file);
        }
        
        file_text_close(file);
        
        // Parse JSON
        var data = json_parse(json_string);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "JSONUtils", 
                        string("Successfully loaded JSON: {0}", filename), "File loaded");
        }
        
        return data;
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "JSONUtils", 
                        string("Error loading JSON file: {0}", filename), 
                        string("Error: {0}", error));
        }
        return undefined;
    }
}

/// @function json_save_file(filename, data)
/// @description Save data structure to JSON file
/// @param {string} filename Path to save the JSON file
/// @param {struct} data Data to save
/// @return {bool} True if successful, false otherwise
function json_save_file(filename, data) {
    try {
        // Convert to JSON string
        var json_string = json_stringify(data);
        
        // Write to file
        var file = file_text_open_write(filename);
        file_text_write_string(file, json_string);
        file_text_close(file);
        
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.INFO, "JSONUtils", 
                        string("Successfully saved JSON: {0}", filename), "File saved");
        }
        
        return true;
        
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "JSONUtils", 
                        string("Error saving JSON file: {0}", filename), 
                        string("Error: {0}", error));
        }
        return false;
    }
}

/// @function json_validate_structure(data, required_fields)
/// @description Validate that a JSON structure contains required fields
/// @param {struct} data The data structure to validate
/// @param {array} required_fields Array of required field names
/// @return {bool} True if all required fields exist
function json_validate_structure(data, required_fields) {
    if (is_undefined(data) || !is_struct(data)) {
        return false;
    }
    
    for (var i = 0; i < array_length(required_fields); i++) {
        if (!variable_struct_exists(data, required_fields[i])) {
            if (variable_global_exists("log_enabled") && global.log_enabled) {
                logger_write(LogLevel.WARNING, "JSONUtils", 
                            string("Missing required field: {0}", required_fields[i]), "Structure validation");
            }
            return false;
        }
    }
    
    return true;
}

/// @function json_merge_structures(base, overlay)
/// @description Merge two structures, with overlay values taking precedence
/// @param {struct} base Base structure
/// @param {struct} overlay Structure to overlay on base
/// @return {struct} Merged structure
function json_merge_structures(base, overlay) {
    if (is_undefined(base)) base = {};
    if (is_undefined(overlay)) return base;
    
    var result = {};
    
    // Copy base structure
    var base_names = variable_struct_get_names(base);
    for (var i = 0; i < array_length(base_names); i++) {
        var key = base_names[i];
        result[$ key] = base[$ key];
    }
    
    // Overlay new values
    var overlay_names = variable_struct_get_names(overlay);
    for (var i = 0; i < array_length(overlay_names); i++) {
        var key = overlay_names[i];
        result[$ key] = overlay[$ key];
    }
    
    return result;
}

/// @function json_deep_copy(data)
/// @description Create a deep copy of a struct by serializing and deserializing
/// @param {struct} data Structure to copy
/// @return {struct} Deep copy of the structure
function json_deep_copy(data) {
    try {
        var json_string = json_stringify(data);
        return json_parse(json_string);
    } catch (error) {
        if (variable_global_exists("log_enabled") && global.log_enabled) {
            logger_write(LogLevel.ERROR, "JSONUtils", "Failed to deep copy structure", string(error));
        }
        return undefined;
    }
}

/// @function json_get_nested_value(data, path, default_value)
/// @description Get a nested value from a structure using dot notation
/// @param {struct} data Structure to search
/// @param {string} path Dot-separated path (e.g., "player.stats.health")
/// @param {any} default_value Value to return if path not found
/// @return {any} Found value or default_value
function json_get_nested_value(data, path, default_value = undefined) {
    if (is_undefined(data) || !is_struct(data)) {
        return default_value;
    }
    
    var parts = string_split(path, ".");
    var current = data;
    
    for (var i = 0; i < array_length(parts); i++) {
        var key = parts[i];
        if (!is_struct(current) || !variable_struct_exists(current, key)) {
            return default_value;
        }
        current = current[$ key];
    }
    
    return current;
}

/// @function json_set_nested_value(data, path, value)
/// @description Set a nested value in a structure using dot notation
/// @param {struct} data Structure to modify
/// @param {string} path Dot-separated path (e.g., "player.stats.health")
/// @param {any} value Value to set
/// @return {bool} True if successful, false otherwise
function json_set_nested_value(data, path, value) {
    if (is_undefined(data) || !is_struct(data)) {
        return false;
    }
    
    var parts = string_split(path, ".");
    var current = data;
    
    // Navigate to the parent of the target property
    for (var i = 0; i < array_length(parts) - 1; i++) {
        var key = parts[i];
        if (!variable_struct_exists(current, key)) {
            current[$ key] = {};
        }
        current = current[$ key];
        if (!is_struct(current)) {
            return false;  // Path blocked by non-struct value
        }
    }
    
    // Set the final value
    var final_key = parts[array_length(parts) - 1];
    current[$ final_key] = value;
    return true;
}