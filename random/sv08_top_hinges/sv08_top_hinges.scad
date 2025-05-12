include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

/* [Hidden] */
$fn=32;

/* [View Type] */
generate = "outter hinge"; // ["outter hinge", "inner hinge", "assembled down", "assembled up", "gap cover"]

/* [General] */
// width of the walls surrounging the glass
wall_width = 4; // .1
// width of the glass (allows increasing clearance)
glass_width = 3.2; // .1
// length of the support. If this is modified manual adjustments of the outerhinge magnet support arm will be needed
support_length = 20; // .1
// width of the support. The interior hinge will be equal to this (- 2 X tolerance ) while the outer hinge will be 3 x width
support_width = 20; // .1
// gap between the fix and the mobile panel
pannel_gap = 1.2; // .1


// Tolerance for various parts
tolerance = .2;

/* [Hinge parameters] */
// diameter of the hinge knuckle
knuckle_diam = 8; // .1
// Knuckle offset
knuckle_offset = 5; // .1
//Knuckle arm height
arm_height = 2; // .1
// diameter of the socket hole
pin_diameter = "M3";
// Screw head type for the counterbore hole
screw_head_type = "socket"; // ["none", "socket", "button", "flat", "flat sharp", "flat small", "flat large", "pan", "cheese"]
// Depth of the screw head hole
screw_head_depth = 3; // .1
// Type of the nut insert
nut_type = "hex"; // ["hex", "square"]
// Depth of the nut insert
nut_depth = 3; // .1

/* [Magnet parameters] */
// Magnet diameter
magnet_diam = 4.2;
// Magnet height 
magnet_height = 3; // [0:.1:4]

/* [Gap cover parameters] */
// length of the cover for the gaps between hinges
cover_length = 20; // .1
// width of the cover for the gaps between hinges
cover_width = 160; // .1
// length of the cover section under the glass (for a better closure)
cover_low_section_length = 5; // .1

if (generate == "outter hinge") {
  outer_hinge();
} else if  (generate == "inner hinge") {
  inner_hinge();
} else if  (generate == "assembled down") {
  rotate([0, -90, 0]) {
    outer_hinge();
    rotate([0, 180, 0])
    inner_hinge();
  }
} else if  (generate == "assembled up") {
  rotate([0, -90, 0]) {
    center_hinge()
    outer_hinge();
    rotate([0, 100, 0])
    center_hinge()
    rotate([0, 180, 0])
    inner_hinge();
  }
} else if (generate == "gap cover") {
  gap_cover();
}


 
module center_hinge() {
  translate([- (wall_width + knuckle_offset) ,0, 0]) {
    children();
  }
}

module outer_hinge() {
  // top support with hinge
  cuboid([wall_width, support_width, support_length], anchor=TOP + LEFT) {
    difference() {
      // the hinges
      position(TOP+RIGHT+FRONT) orient(anchor=RIGHT)
      knuckle_hinge(length=support_width, segs=3, offset=knuckle_offset, arm_height=arm_height,
      anchor=BOT+LEFT, knuckle_diam = knuckle_diam, pin_diam = pin_diameter,
      screw_head=screw_head_type, tap_depth = screw_head_depth);
      
      // cutout for the nut
      color("blue")
      position(BACK+TOP+RIGHT)
      orient(anchor = FRONT)
      translate([knuckle_offset,0,0])
      nut_trap_inline(length = nut_depth, spec = pin_diameter, shape = nut_type, anchor = BOT, $slop= tolerance);
    };

    // magnetic support arm
    difference() 
    {
        // support section
      hull() {
        color("green")
        position(BOT + RIGHT) 
        cuboid([15.5,6,10], anchor = BOT + LEFT)

        position(BOT + RIGHT)
        rotate([0,-60,0])
        cuboid([18,6, 6], anchor = BOT + LEFT) 

        position(BOT + RIGHT)
        rotate([0,-20,0])
        cuboid([2, 8, 8], anchor = BOT + LEFT);
      }

      // magnet cutout
      color("red")
      position(BOT + RIGHT)
      rotate([0, 10,0])
        translate([21.4 - (4 - magnet_diam/2), 0, 21.7 - magnet_height ])
      cyl(h=magnet_height, d=magnet_diam, anchor= BOT + RIGHT, $fn=16);
    };

  }

  // bottom support with slots for the glass pane (mirrore along the y axis)
  yflip_copy()
  color("blue")
  translate([0, support_width, pannel_gap]) {
    // top part
    cuboid([wall_width, support_width, support_length + pannel_gap], anchor = TOP + LEFT);
    difference() {
      // bottom part with the glass cutout
      cuboid([wall_width + glass_width, support_width, support_length + pannel_gap], anchor = TOP + RIGHT);
      translate([0, 0, - pannel_gap]) 
      cuboid([glass_width, support_width, support_length], anchor = TOP + RIGHT);
    }
  }

}
 
 module inner_hinge() {
  // top support section (with hinge)
  cuboid([wall_width, support_width-tolerance*2, support_length], anchor=TOP + RIGHT) {
    position(TOP+LEFT + CENTER) orient(anchor=LEFT)
    knuckle_hinge(length=support_width, segs=3, offset=knuckle_offset, arm_height=arm_height,
    inner=true, anchor=BOT, knuckle_diam = knuckle_diam, pin_diam = pin_diameter);

    // cube with cutout for magnet
    difference() 
    {
      color("red")
      position(BOT + LEFT) 
      cuboid([ 4, 8, 8], anchor = BOT + RIGHT);
      color("green") 
      position(BOT + LEFT) 
      translate([- (4 - magnet_height), 0, (8 - magnet_diam)/2])
      orient(LEFT)
      cyl(h=magnet_height, d=magnet_diam, anchor= BOT + FRONT, $fn=16);
    }
  }

   // bottom part with glass cutout
   difference() {
    color("red")
    cuboid([wall_width + glass_width, support_width-tolerance*2, support_length], anchor = TOP + LEFT);
    translate([0, 0, - pannel_gap]) 
    cuboid([glass_width, support_width, support_length - pannel_gap], anchor = TOP + LEFT);
  }
}

module gap_cover() {
  // bottom long section
  cuboid([cover_width, cover_length, wall_width], anchor = TOP + BACK) ;
  // bottom short section
  cuboid([cover_width, cover_low_section_length, wall_width], anchor = TOP + FRONT);
  // top part with glass cutout
  difference() {
    color("red")
    cuboid([cover_width, cover_length, wall_width + glass_width], anchor = BOT + BACK);
    translate([0, - pannel_gap, 0]) 
    cuboid([cover_width, cover_length - pannel_gap, glass_width], anchor = BOT + BACK);
  }
}

 