include <BOSL2/std.scad>;

/* [Hidden] */
$fa = 1;
$fs = 0.4;

/* [Insert parameters] */
//insert parameters
// diameter of the insert
hex_diameter = 13.0; //[0:0.1:100]

//length of the support inside the honeycomb
wall_insert_length = 9.0; //[0:0.1:10]

/*/ [Screwdriver parameters] */
// diameter of the support
support_diameter = 13.0; //[0:0.1:100]

//Screwdriver measurements. Format: min_shaft_diameter1,max_shaft_diameter1,base_diameter1,base_height1,max_handle_diameter1|min_shaft_diameter2,max_shaft_diameter2,base_diameter2,base_height2,max_handle_diameter2|min_shaft_diameter3,max_shaft_diameter3,base_diameter3,base_height3,max_handle_diameter3 .... No spaces allowed
screwdriver_measurements = "9,11.5,18,2,38|6.5,9,16.5,1.5,35|6.5,9,16.5,1.5,35"; 


screwdrivers = [for(i = split("|", screwdriver_measurements)) [for (j = split(",", i)) float(j)]];
insert_length = wall_insert_length + 1; //extra length accounts for the raised stopper section

hex_insert(hex_diameter, insert_length);
hex_support(insert_length, support_diameter, screwdrivers);


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


//create a simple cutout
module simple_cutout(min_diameter = 5, max_diameter = 10, height = 10) {
    
    linear_extrude(height = height, center = true) {
        
        //interior circle
        circle(d = min_diameter);
        
        if (max_diameter > min_diameter) {
            //rectangle to fit wider part for straight screwdrivers
            rect([min_diameter,max_diameter], rounding = min_diameter/4);
        }
    }

}

module screwdriver_cutout(min_diameter = 5, max_diameter = 10, height = 10, base_diameter = 10, base_height = 1.5) {
    //cutout for the screwdriver
    simple_cutout(height = height, max_diameter = max_diameter, min_diameter = min_diameter);
    translate([0, 0, height / 2 - base_height / 2])
    //cutout for the base of the screwdriver to rest in
    simple_cutout(height = base_height, max_diameter = base_diameter, min_diameter = base_diameter);
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

module hex_support(wall_insert_length, support_diameter, screwdrivers) {
    
    handle_sizes = [for (dim = screwdrivers) dim[4]];
    summed_sizes = sums(handle_sizes); 
    support_length = summed_sizes[len(summed_sizes) - 1];

    difference() {
        //the basic hexagon support
        rotate([90,0,0])
        translate([0, 0, -wall_insert_length/2 - support_length/2]) 
        hexagon_inscribed(support_diameter/2, support_length, true);
        
        translate([0, wall_insert_length/2, 0] ) {
            // create a cutout for each screwdriver
            for (i = [0:1:len(screwdrivers) - 1]) {
                let( dim = screwdrivers[i])
                translate([0, summed_sizes[i] - handle_sizes[i]/2, 0])
                screwdriver_cutout(dim[0], dim[1], support_diameter, dim[2], dim[3]);
            }
        }
    }
}

// support functions
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
