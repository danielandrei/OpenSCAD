include <BOSL2/std.scad>;

/* [Hidden] */
$fa = 1;
$fs = 0.4;

/* [Insert parameters] */
//insert parameters
// diameter of the insert
hex_diameter = 13.05; //[0:0.01:100]

//length of the support inside the honeycomb
wall_insert_length = 9.0; //[0:0.01:10]

/*/ [Support parameters] */
// diameter of the support
support_diameter = 13.05; //[0:0.01:100]

// key type the support is for
key_type = "Allen"; // [Allen,Torx]

// Comma separated list of float key dimensions. For allen keys the distance between two opposing faces, for torx the max diameter of the key.
key_measurements = "4,3,2.5,2,1.5"; 

// tolerance for the key hole
tolerance = 1; // [0:0.01:2]

// width of the separator between keys
separator_width = 2; // [0:0.01:5]

// flip the cutout orientation on the support
flip_support = false;

keys = [for (j = split(",", key_measurements)) float(j)];

insert_length = wall_insert_length + 1; //extra length accounts for the raised stopper section

hex_insert(hex_diameter, insert_length);
hex_support(insert_length, support_diameter, key_type, keys, tolerance, separator_width, flip_support);

// modules

module hexagon(side, height, center) {
  length = sqrt(3) * side;
  translate_value = center ? [0, 0, 0] :
                             [side, length / 2, height / 2];
  translate(translate_value)
    for (r = [-60, 0, 60])
      rotate([0, 0, r])
        cube([side, length, height], center=true);        
}


module hexagon_inscribed(radius, height, center) {
  hexagon(2 * radius / sqrt(3), height, center);
}

module support_cutout(height, width, flip = fale) {
  x_translate = flip ? -height/2 : height/2;
  translate([x_translate, 0, height/4])
  cuboid(size = [height, width, height/2]);
}

module key_cutout(key_type, diameter = 5, height = 10, flip) {
    //cutout for the key
    if (key_type == "Allen") {
      rotate([0, 0, 30]) 
      hexagon_inscribed(radius = diameter/2, height = height, center = true);
      support_cutout(height = height, width = 2 * diameter / sqrt(3), flip);
    }
    else {
      cyl(h = height, d = diameter, center = true);
      support_cutout(height = height, width = diameter, flip);
    }
}

module hex_insert(diameter = 13, wall_insert_length = 9.5) {

    rotate([90,0,0]) {
        // wall insert part
        hexagon_inscribed(diameter/2, wall_insert_length, true);

        //raised wall stop section 
        translate([0, 1, 0.499-wall_insert_length/2])
        hexagon_inscribed(diameter/2, 1, true);
        
    }

}

module hex_support(wall_insert_length, support_diameter, key_type, keys, tolerance, separator_width, flip) {
    
    key_support_gap = tolerance + separator_width;

    handle_sizes = [for (dim = keys) map_handle_size(key_type = key_type, dim = dim, key_support_gap = key_support_gap)] ;
    summed_sizes = sums(handle_sizes); 

    support_length = summed_sizes[len(summed_sizes) - 1] + separator_width / 2;

    difference() {
        //the basic hexagon support
        rotate([90,0,0])
        translate([0, 0, -wall_insert_length/2 - support_length/2]) 
        hexagon_inscribed(support_diameter/2, support_length, true);
        
        translate([0, wall_insert_length/2, 0] ) {
            // create a cutout for each screwdriver
            for (i = [0:1:len(keys) - 1]) {
                translate([0, summed_sizes[i] - handle_sizes[i]/2, 0])
                key_cutout(key_type, keys[i]+tolerance, support_diameter, flip);
            }
        }
    }
}

// support functions
function map_handle_size(key_type, dim, key_support_gap) = 
   key_type == "Allen" ? 2 * dim / sqrt(3) + key_support_gap : dim + key_support_gap;

function sums(v, i=0, s=0, r=[]) = i < len(v) ? sums(v, i+1, s+v[i], concat(r, [s +v[i]])) : r;

function substr(s, st, en, p="") = 
    (st >= en || st >= len(s))? p :
    substr(s, st+1, en, str(p, s[st]));

function split(h, s, p=[]) =
    let(x = search(h, s))
    x == [] ? concat(p, s) :
    let(
        i=x[0],
        l=substr(s, 0, i),
        r=substr(s, i+1, len(s))
    )
    split(h, r, concat(p, l));

function float(s) =  let(
    _f = function(s, i, x, vM, dM, ddM, m)
      i >= len(s) ? round(x*dM)/dM :
      let(
        d = ord(s[i])
      )
      (d == 32 && m == 0) || (d == 43 && (m == 0 || m == 2)) ?
        _f(s, i+1, x, vM, dM, ddM, m) :
      d == 45 && (m == 0 || m == 2) ?
        _f(s, i+1, x, vM, -dM, ddM, floor(m/2)+1) :
      d >= 48 && d <= 57 ?
        _f(s, i+1, x*vM + (d-48)/dM, vM, dM*ddM, ddM, floor(m/2)+1) :
      d == 46 && m<=1 ? _f(s, i+1, x, 1, 10*dM, 10, max(m, 1)) :
      (d == 69 || d == 101) && m==1 ? let(
          expon = _f(s, i+1, 0, 10, 1, 1, 2)
        )
        (is_undef(expon) ? undef : expon >= 0 ?
          (round(x*dM)*(10^expon/dM)) :
          (round(x*dM)/dM)/10^(-expon)) :
      undef
  )
  _f(s, 0, 0, 10, 1, 1, 0);
