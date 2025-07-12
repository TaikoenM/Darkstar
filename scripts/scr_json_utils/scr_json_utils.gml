/// @function json_load_file(filename)
/// @description Load and parse a JSON file
/// @param {string} filename Path to the JSON file
/// @return {struct|undefined} Parsed JSON data or undefined on error
function json_load_file(filename) {
    // Check if file exists
    if (!file_exists(filename)) {
        logger_write(LogLevel.ERROR, "JSONUtils", 
                    string("JSON file not found: {0}", filename), "File loading failed");
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
        
        logger_write(LogLevel.INFO, "JSONUtils", 
                    string("Successfully loaded JSON: {0}", filename), "File loaded");
        
        return data;
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "JSONUtils", 
                    string("Error loading JSON file: {0}", filename), 
                    string("Error: {0}", error));
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
        
        logger_write(LogLevel.INFO, "JSONUtils", 
                    string("Successfully saved JSON: {0}", filename), "File saved");
        
        return true;
        
    } catch (error) {
        logger_write(LogLevel.ERROR, "JSONUtils", 
                    string("Error saving JSON file: {0}", filename), 
                    string("Error: {0}", error));
        return false;
    }
}