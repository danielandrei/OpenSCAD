// The character to genearate
character = "A";
/* [Preview] */
// This moves the magnet holes to the top of the letter so positioning can be easier. Disable before final generation.
preview = false;
/* [General] */
// Solid space on the letter bottom before the magnet holes start. Usually the height of a layer is enough.
bottom_height = 0.3; // .1
// Clearance used for the magnet holes (both the diameter and the height)
clearance = 0.3; // .1

/* [Magnets] */
// Diameter of the magnet 
magnet_diameter = 4; //.1
// Height of the magnet
magnet_height = 2; // .1

/* [Text] */
// Font to use. See the font list window for possible values
font = "Arial Black";
// Size of the text
text_size = 45; // .1
// Thickness of the letter
letter_height = 4; // .1
// trim a contour at the top so it's distinguishable from the bottom part with the magnet
top_contour = true;
contour_height = 0.6;
contour_width = 1.2;

/* [Magnet positions] */

magnet1_enabled = false;
magnet1_pos = [0, 0]; // [-1000:.1:1000]

magnet2_enabled = false;
magnet2_pos = [0, 0]; // [-1000:.1:1000]

magnet3_enabled = false;
magnet3_pos = [0, 0]; // [-1000:.1:1000]

magnet4_enabled = false;
magnet4_pos = [0, 0]; // [-1000:.1:1000]

magnet5_enabled = false;
magnet5_pos = [0, 0]; // [-1000:.1:1000]

magnet6_enabled = false;
magnet6_pos = [0, 0]; // [-1000:.1:1000]

magnet7_enabled = false;
magnet7_pos = [0, 0]; // [-1000:.1:1000]

magnet8_enabled = false;
magnet8_pos = [0, 0]; // [-1000:.1:1000]

magnet9_enabled = false;
magnet9_pos = [0, 0]; // [-1000:.1:1000]

magnet10_enabled = false;
magnet10_pos = [0, 0]; // [-1000:.1:1000]

 /* [Hidden] */
$fn=72;

magnet_position = preview ? letter_height - magnet_height / 2 : bottom_height;
comm_x = 0; 
comm_c_y = text_size / 3 + magnet_diameter / 2;


magnets = [
    [magnet1_enabled, magnet1_pos],
    [magnet2_enabled, magnet2_pos],
    [magnet3_enabled, magnet3_pos],
    [magnet4_enabled, magnet4_pos],
    [magnet5_enabled, magnet5_pos],
    [magnet6_enabled, magnet6_pos],
    [magnet7_enabled, magnet7_pos],
    [magnet8_enabled, magnet8_pos],
    [magnet9_enabled, magnet9_pos],
    [magnet10_enabled, magnet10_pos],
    ];

magnet_centers = [for (m = magnets) if (m[0]) m[1] ];

letter(character, magnet_centers);


module letter(character, magnet_centers=[]) {
    difference() {
        linear_extrude(height = letter_height)
        text(text=character, size=text_size, font=font, halign="center", valign = "center");
        for (mc = magnet_centers) magnet_hole(mc.x, mc.y);

        if (top_contour) {
            color("blue")
            translate([0, 0, letter_height - contour_height])
            linear_extrude(contour_height)
            difference() {
                text(text=character, size=text_size, font=font, halign="center", valign = "center");
                offset(r = -contour_width)
                text(text=character, size=text_size, font=font, halign="center", valign = "center");
            }
        }
    }
}

module magnet_hole(x, y) {
    color("red")
    translate([x, y, magnet_position])
    linear_extrude(height = magnet_height + clearance)
    circle(d = magnet_diameter + clearance);
}



