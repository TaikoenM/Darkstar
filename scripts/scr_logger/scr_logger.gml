/// @description Initialize the logging system with configuration settings
/// @description Sets up global logging variables and creates initial log file
/// @description Requires config system to be initialized first
function logger_init() {
    // Check if config system is available and logging is enabled
    if (!variable_global_exists("config") || !global.config.log_enabled) {
        global.log_enabled = false;
        return;
    }
    
    global.log_enabled = true;
    global.log_file = global.config.log_file;
    global.log_level = global.config.log_level;
    global.log_session_start = date_current_datetime();
    
    // Clear previous log file
    if (file_exists(global.log_file)) {
        file_delete(global.log_file);
    }
    
    logger_write(LogLevel.INFO, "Logger", "Logging system initialized", "System startup");
}

/// @description Write a log entry with specified level, source, message and reason
/// @param {real} level Severity level from LogLevel enum
/// @param {string} source Source component or system generating the log
/// @param {string} message Main log message content
/// @param {string} reason Additional context or reason for the log entry
function logger_write(level, source, message, reason = "") {
    // Early exit if logging disabled or level too low
    if (!variable_global_exists("log_enabled") || !global.log_enabled || level < global.log_level) {
        return;
    }
    
    var level_text = "";
    switch(level) {
        case LogLevel.DEBUG:    level_text = "DEBUG"; break;
        case LogLevel.INFO:     level_text = "INFO"; break;
        case LogLevel.WARNING:  level_text = "WARN"; break;
        case LogLevel.ERROR:    level_text = "ERROR"; break;
        case LogLevel.CRITICAL: level_text = "CRIT"; break;
        default:                level_text = "UNKNOWN"; break;
    }
    
    var timestamp = string(date_current_datetime());
    var log_entry = string("{0} [{1}] {2}: {3}", timestamp, level_text, source, message);
    if (reason != "") {
        log_entry += string(" | Reason: {0}", reason);
    }
    
    // Write to file if file system is available
    try {
        var file = file_text_open_append(global.log_file);
        file_text_write_string(file, log_entry);
        file_text_writeln(file);
        file_text_close(file);
    } catch (error) {
        // If file writing fails, at least output to debug console
        show_debug_message("LOG FILE ERROR: " + string(error));
    }
    
    // Always output to console for debugging
    show_debug_message(log_entry);
}