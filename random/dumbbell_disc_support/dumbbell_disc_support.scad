include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Hidden] */
$fa = 1;
$fs = 0.4;


/* [General parameters] */
// object type to generate, Either a base or an extesion rod. The extension rods have internal threads on the bottom
type = "base"; // [base,rod]

// if selected this will generate a cap instead of the threaded rod. This can be used both on a rod to generate a cap or directly on a base if a fixed height support is required
top_cap = false;

/* [Base parameters] */
// diameter of the support base
support_base_diameter = 115; // .1

// height of the base (without the holder rod directly on the base)
support_base_height = 2.5; // .1

/* [Support rod parameter] */
// diameter of the support rod
support_rod_diameter = 27; // .1

// height of the supporting rod of the section (excluding base height and the height of the thread at the top if the section is not a top cap)
support_height = 30; // .1 

/* [Thread parameters] */ 
// diameter of the threaded section
thread_diameter = 15; // .1

//height of the threaded section
thread_height = 20; // .1

// number of thread starts. Higher number makes the sections quicker to add/remove but less resistant to vertical tension.
thread_starts = 10; 

// length between threads
pitch = 5; // .01

// clearance value to be applied to the interior threads. This is applied to the $slop parameter of the threaded_rod() 
clearance = 0.3; // .01


if (type == "base")
    base();
else if (type == "rod")
    rod(true);

module base () {
    h = (support_height > 0) ? support_height : 0.01;
    
    cyl(d = support_base_diameter, h = support_base_height, anchor=BOTTOM)
    color("blue")
    translate([0,0,support_base_height/2])
    rod(false);
}

module rod(interior_thread=true) {
    top_rounding = top_cap ? support_rod_diameter/5 : 0;
    difference() {
        cyl(d = support_rod_diameter, h = support_height, anchor=BOTTOM, rounding2 = top_rounding);
        if (interior_thread) {
        threaded_rod(
            d=thread_diameter, 
            l=thread_height, 
            pitch=pitch,
            internal=true, 
            bevel=true,
            blunt_start=false,
            starts = thread_starts,
            teardrop=true,
            anchor=BOTTOM,
            $slop = clearance,
            $fn=72
        )
        position(TOP)
        cyl(d1 = thread_diameter, d2 = 0, height = (support_height - thread_height) / 2, anchor = BOTTOM);
        }
    }

    if (top_cap == false) {
        color("red")
        translate([0,0,support_height])
        threaded_rod(
            d=thread_diameter, 
            l=thread_height, 
            pitch=pitch,
            internal=false, 
            bevel=false,
            blunt_start=false,
            blunt_start2=true,
            starts = thread_starts,
            teardrop=false,
            anchor=BOTTOM,
            $fn=72
        );
    }
}