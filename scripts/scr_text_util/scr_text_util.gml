/// @function wrap_text(text, max_width)
/// @description Wrap text to fit within max width
/// @param {string} text Text to wrap
/// @param {real} max_width Maximum width in pixels
/// @return {Array<string>} Array of wrapped lines
function wrap_text(text, max_width) {
    if (string_width(text) <= max_width) {
        return [text]; // No wrapping needed
    }
    
    var words = string_split(text, " ");
    var lines = [];
    var current_line = "";
    
    for (var i = 0; i < array_length(words); i++) {
        var word = words[i];
        var test_line = current_line;
        
        if (current_line != "") {
            test_line += " ";
        }
        test_line += word;
        
        if (string_width(test_line) <= max_width) {
            current_line = test_line;
        } else {
            // Current line is full, start new line
            if (current_line != "") {
                lines[array_length(lines)] = current_line;
            }
            
            // Check if single word is too long
            if (string_width(word) > max_width) {
                // Split the word character by character
                var char_line = "";
                for (var j = 1; j <= string_length(word); j++) {
                    var char = string_char_at(word, j);
                    var test_char_line = char_line + char;
                    
                    if (string_width(test_char_line) <= max_width) {
                        char_line = test_char_line;
                    } else {
                        if (char_line != "") {
                            lines[array_length(lines)] = char_line;
                        }
                        char_line = char;
                    }
                }
                if (char_line != "") {
                    current_line = char_line;
                } else {
                    current_line = "";
                }
            } else {
                current_line = word;
            }
        }
    }
    
    if (current_line != "") {
        lines[array_length(lines)] = current_line;
    }
    
    return lines;
}