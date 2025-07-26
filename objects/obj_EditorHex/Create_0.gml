hex_q = 0;
hex_r = 0;

// Use a sprite that is designed with a 200px height.
// sWater01 is a placeholder for your actual water sprite asset name.
sprite_index = spr_hex;

// This scales the sprite so its height is exactly EDITOR_HEX_HEIGHT.
var base_sprite_height = sprite_get_height(sprite_index);
if (base_sprite_height > 0) {
    var scale = EDITOR_HEX_HEIGHT / base_sprite_height;
    image_xscale = scale;
    image_yscale = scale;
}