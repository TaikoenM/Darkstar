/// @description Clean up console resources with better error handling
if (variable_global_exists("dev_console") && !is_undefined(global.dev_console)) {
    // Check if data structures exist before cleanup
    if (variable_struct_exists(global.dev_console, "history") && 
        !is_undefined(global.dev_console.history) && 
        ds_exists(global.dev_console.history, ds_type_list)) {
        // Don't log during cleanup to avoid recursive calls
        ds_list_destroy(global.dev_console.history);
    }
    
    if (variable_struct_exists(global.dev_console, "command_history") && 
        !is_undefined(global.dev_console.command_history) && 
        ds_exists(global.dev_console.command_history, ds_type_list)) {
        ds_list_destroy(global.dev_console.command_history);
    }
}

if (variable_global_exists("dev_commands") && 
    !is_undefined(global.dev_commands) && 
    ds_exists(global.dev_commands, ds_type_map)) {
    ds_map_destroy(global.dev_commands);
}