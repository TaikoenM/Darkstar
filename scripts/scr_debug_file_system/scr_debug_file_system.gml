/// @description Debug file system to understand how GameMaker handles included files
/// @description Call this to log information about file paths and included files
function debug_file_system() {
    show_debug_message("=== FILE SYSTEM DEBUG ===");
    show_debug_message("working_directory: " + working_directory);
    show_debug_message("program_directory: " + program_directory);
    show_debug_message("temp_directory: " + temp_directory);
    
    // Test various file path combinations
    var test_paths = [
        "mainmenu_background.png",
        "mainmenu_background.png",
        "assets/images/mainmenu_background.png",
        working_directory + "mainmenu_background.png",
        working_directory + "mainmenu_background.png",
        working_directory + "assets/images/mainmenu_background.png",
        program_directory + "mainmenu_background.png",
        program_directory + "mainmenu_background.png",
        program_directory + "assets/images/mainmenu_background.png"
    ];
    
    show_debug_message("\n--- Testing file existence ---");
    for (var i = 0; i < array_length(test_paths); i++) {
        var path = test_paths[i];
        var exists = file_exists(path);
        show_debug_message(string("{0}: {1}", exists ? "EXISTS" : "NOT FOUND", path));
    }
    
    show_debug_message("\n--- Testing sprite_add ---");
    // Try loading the sprite with different paths
    for (var i = 0; i < array_length(test_paths); i++) {
        var path = test_paths[i];
        try {
            var spr = sprite_add(path, 1, false, false, 0, 0);  // Load 1 frame, not 0
            if (spr != -1) {
                show_debug_message(string("SUCCESS: sprite_add(\"{0}\") = {1}, Size: {2}x{3}", 
                                         path, spr, sprite_get_width(spr), sprite_get_height(spr)));
                sprite_delete(spr); // Clean up
                break; // Found working path
            } else {
                show_debug_message(string("FAILED: sprite_add(\"{0}\") returned -1", path));
            }
        } catch (error) {
            show_debug_message(string("ERROR: sprite_add(\"{0}\") threw: {1}", path, error));
        }
    }
    
    show_debug_message("\n=== END FILE SYSTEM DEBUG ===");
}