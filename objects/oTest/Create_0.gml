function load_all_sprites_from_directory(directory_name) {
    // This ds_map will store the filename and the corresponding sprite index.
    var sprite_map = ds_map_create();

    // The full path to the directory we want to read from.
    // We'll place our images in a subfolder within the working_directory.
    var dir_path = working_directory + directory_name + "/";

    // Check if the directory exists.
    if (!directory_exists(dir_path)) {
        show_debug_message("Directory not found: " + dir_path);
        return sprite_map; // Return an empty map.
    }

    // Find the first .png file in the directory.
    var file_name = file_find_first(dir_path + "*.png", 0);

    // Loop through all the .png files in the directory.
    while (file_name != "") {
        var file_path = dir_path + file_name;

        // Create a sprite from the file. We'll set the origin to the top-left.
        // You may want to adjust these origin values or pass them as arguments.
        var new_sprite = sprite_add(file_path, 1, false, false, 0, 0);

        if (new_sprite > -1) {
            // If the sprite was created successfully, add it to our map.
            ds_map_add(sprite_map, file_name, new_sprite);
			var sprW = sprite_get_width(new_sprite)
            show_debug_message("Loaded sprite: " + file_name +", widht = "+string(sprW));
        } else {
            show_debug_message("Failed to load sprite: " + file_name);
        }

        // Find the next file.
        file_name = file_find_next();
    }

    // Close the file search. This is important to free up memory.
    file_find_close();

    return sprite_map;
}
	
var imgs = load_all_sprites_from_directory(IMAGES_PATH)
show_debug_message("done")