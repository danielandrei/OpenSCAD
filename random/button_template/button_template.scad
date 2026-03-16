// ============================================
// Button Fabric Marking Template
// ============================================
// Place on fabric, hold the center post to keep
// it steady, and trace around the outer edge
// (including notches) with a pen/marker, then cut.
// The notches guide where to snip inward so the
// fabric folds neatly around the button shell.
// ============================================

/* [Button] */

// Button diameter in mm
button_diameter = 23;      // [10:0.5:60]

// Folding margin per side in mm
fold_margin = 9.5;         // [5:0.5:20]

/* [Notches] */

// Number of cut-guide notches (0 = none)
num_notches = 16;          // [0:1:32]

// Notch depth in mm
notch_depth = 4;           // [2:0.5:10]

// Notch width in mm
notch_width = 1.0;         // [0.5:0.1:2]

// Pencil mark circle diameter at inner end of notch
notch_mark_diameter = 2.0; // [1:0.25:4]

/* [Rim] */

// Rim height in mm (0 = no rim)
rim_height = 3;            // [0:0.5:5]

// Rim width in mm
rim_width = 1.2;           // [0.8:0.1:2]

/* [Inner Guide Ring] */

// Inner guide ring height in mm (0 = no ring)
guide_ring_height = 1.0;   // [0:0.25:2]

// Inner guide ring width in mm
guide_ring_width = 0.8;    // [0.4:0.1:1.5]

/* [Center Post] */

// Center post height in mm (0 = no post)
center_post_height = 15;   // [0:1:30]

// Center post radius in mm
center_post_radius = 4;    // [2:0.5:8]

/* [Text Label] */

// Text size in mm
text_size = 5;             // [3:0.5:10]

// Text depth (engraving depth)
text_depth = 0.6;          // [0.3:0.1:1]

/* [Grip] */

// Add sawtooth grip pattern to the base underside
material_grip = true;      // [true, false]

// Ring spacing in mm
sawtooth_spacing = 2.5;    // [1.5:0.5:5]

// Tooth height in mm
sawtooth_height = 0.8;     // [0.3:0.1:1.5]

// Tooth angular span in degrees
tooth_angle = 8;           // [3:1:20]

// Gap between teeth in degrees
tooth_gap = 4;             // [2:1:10]

/* [Base] */

// Base thickness in mm
base_thickness = 1.5;      // [1:0.25:3]

// Circle smoothness
$fn = 128;

// === CALCULATED VALUES ===
button_radius = button_diameter / 2;
total_radius = button_radius + fold_margin;
number_text = str(button_diameter);
tooth_step = tooth_angle + tooth_gap;
num_teeth_per_ring = floor(360 / tooth_step);
notch_mark_radius = notch_mark_diameter / 2;
grip_z = material_grip ? sawtooth_height : 0;

// === MODULES ===

module base_disk() {
    cylinder(h = base_thickness, r = total_radius);
}

module rim_ring() {
    if (rim_height > 0) {
        translate([0, 0, base_thickness])
            difference() {
                cylinder(h = rim_height, r = total_radius);
                translate([0, 0, -0.1])
                    cylinder(h = rim_height + 0.2, r = total_radius - rim_width);
            }
    }
}

module single_notch() {
    // Slot
    translate([total_radius - notch_depth, -notch_width/2, -grip_z - 0.1])
        cube([notch_depth + 1, notch_width, base_thickness + rim_height + grip_z + 0.2]);
    // Pencil mark circle at inner end
    translate([total_radius - notch_depth, 0, -grip_z - 0.1])
        cylinder(h = base_thickness + rim_height + grip_z + 0.2, r = notch_mark_radius);
}

module all_notches() {
    if (num_notches > 0) {
        for (i = [0 : num_notches - 1]) {
            rotate([0, 0, i * 360 / num_notches])
                single_notch();
        }
    }
}

module inner_guide_ring() {
    if (guide_ring_height > 0) {
        translate([0, 0, base_thickness])
            difference() {
                cylinder(h = guide_ring_height, r = button_radius + guide_ring_width/2);
                translate([0, 0, -0.1])
                    cylinder(h = guide_ring_height + 0.2, r = button_radius - guide_ring_width/2);
            }
    }
}

module center_post() {
    if (center_post_height > 0) {
        cylinder(h = base_thickness + center_post_height, r = center_post_radius);
    }
}

module number_label() {
    gap = 1.5;
    label_y = center_post_radius + gap + text_size / 2;
    translate([0, label_y, -grip_z - 0.1])
        linear_extrude(height = base_thickness + guide_ring_height + grip_z + 0.2)
            text(number_text, size = text_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}

module mm_label() {
    gap = 1.5;
    label_y = -(center_post_radius + gap + text_size / 2);
    translate([0, label_y, -grip_z - 0.1])
        linear_extrude(height = base_thickness + guide_ring_height + grip_z + 0.2)
            text("mm", size = text_size, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
}

module single_tooth(r_inner, r_outer, direction) {
    module radial_slice(h) {
        rotate_extrude(angle = 0.5, $fn = max(64, $fn))
            translate([r_inner, 0, 0])
                square([r_outer - r_inner, h]);
    }

    if (direction == 1) {
        hull() {
            rotate([0, 0, 0])
                translate([0, 0, -0.01])
                    radial_slice(0.01);
            rotate([0, 0, tooth_angle])
                translate([0, 0, -sawtooth_height])
                    radial_slice(sawtooth_height);
        }
    } else {
        hull() {
            rotate([0, 0, 0])
                translate([0, 0, -sawtooth_height])
                    radial_slice(sawtooth_height);
            rotate([0, 0, tooth_angle])
                translate([0, 0, -0.01])
                    radial_slice(0.01);
        }
    }
}

module sawtooth_ring(r_inner, r_outer, direction) {
    for (i = [0 : num_teeth_per_ring - 1]) {
        rotate([0, 0, i * tooth_step])
            single_tooth(r_inner, r_outer, direction);
    }
}

module grip_pattern() {
    start_r = center_post_height > 0 ? center_post_radius : 1;
    end_r = total_radius;
    num_rings = max(1, floor((end_r - start_r) / sawtooth_spacing));
    actual_spacing = (end_r - start_r) / num_rings;

    for (i = [0 : num_rings - 1]) {
        r_inner = start_r + i * actual_spacing;
        r_outer = start_r + (i + 1) * actual_spacing;
        dir = (i % 2 == 0) ? 1 : -1;
        rotate([0, 0, (i % 2) * tooth_step / 2])
            sawtooth_ring(r_inner, r_outer, dir);
    }
}

// === ASSEMBLE ===
difference() {
    union() {
        base_disk();
        rim_ring();
        inner_guide_ring();
        center_post();
        if (material_grip) grip_pattern();
    }
    all_notches();
    number_label();
    mm_label();
}
