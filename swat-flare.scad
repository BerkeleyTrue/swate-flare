$fn=50;

module chainedHull() {
  // let i be the index of each of our children, but the last one
  union() {
    for(i=[0:$children-2])
      hull() {
        // we then create a hull between child i and i+1
        children(i); // use child() in older versions of Openscad!
        children(i+1); // this shape is i in the next iteration!
      }
  }
}

module ccube(size) {
  translate([-size[0]/2, -size[1]/2, 0])
    cube(size);
}

module spine() {
  hull() {
    sphere(0.7);
    translate([11.8, 0, 0]) sphere(0.7);
  }
}

// flare mount
module flareMount() {
    union() {
      minkowski() {
        // main platform
        linear_extrude(2.25) {
          difference() {
            union() {
              square([16.63, 12.5]);
              translate([5.25, 10]) square([5.5, 10.3]);
            }
            // cut outs
            translate([3.57, 10]) square([1.68, 2.75]);
            translate([10.75, 10]) square([1.68, 2.75]);
          }
        }
        // camfer
        sphere(0.25);
      }

      // spines
      translate([2.25, 1.75, 2.25]) spine();
      translate([2.25, 8.80, 2.25]) spine();

      /* tab claw */
      translate([10.70, 15.5, 2]) rotate([0, -90, 0])
        linear_extrude(5.5) {
          polygon([[0, 0], [0, 2.2], [1, 2.2]]);
        }

      // tab head
      translate([3, 18, 1.80])
        rotate([-80, 0, 0])
        minkowski() {
          linear_extrude(2.25) {
            intersection() {
              square([10, 7.75]);
              translate([5, 5])
                circle(5.5);
            }
          }
          // camfer
          sphere(0.30);
        }

      // tab thumb stop
      translate([3, 19.4, -3.65])
        rotate([-90, 0, 0])
        minkowski() {
          linear_extrude(3.5) {
            intersection() {
              square([10, 2.25]);
            }
          }
          // camfer
          sphere(0.30);
        }
    }
}

flareBaseSize = [11.8, 8.8];
module flareBaseShape() {
  difference() {
    square(flareBaseSize);

    translate([-0.1, 2])
      square([3.1, 4.8]);

    translate([8.9, 2])
      square([3.1, 4.8]);
  }
}
// base
module flareBase() {
  minkowski() {
    linear_extrude(2.5) {
      flareBaseShape();
    }

    // camfer
    sphere(0.3);
  }
}

// flare mount and base
module flare() {
  union() {
    translate([-2.5, -0.9, 2.5]) flareMount();
    flareBase();
  }
}

boltMountThick = 4;
bolthole=5/2;
boltsupport=2/2;
flareMountY = 11;
bcp = 60;

module swatMount() {
  bOffset=4;
  difference() {
    chainedHull() {
      // bolt hole
      cylinder(r=bolthole+boltsupport, h=boltMountThick);

      // box offset
      translate([bOffset, 0, 0])
        ccube([2, bolthole*2+boltsupport*2, boltMountThick]);

      // tooth
      chamber = 1;
      translate([bOffset+chamber+1, 0, -1])
        rotate([0, 30, 0])
        minkowski() {
          ccube([4, bolthole*2+boltsupport*2 - chamber*2, boltMountThick]);
          sphere(chamber);
        }

      // tab clearance
      translate([bOffset+chamber*2+8, 0, chamber/2])
        rotate([0, 0, 15])
        minkowski() {
          ccube([0.1, 5, 8]);
          sphere(chamber);
        }

      // flare mount face
      translate([(bcp/2)-(flareBaseSize[1]/2), flareMountY - 2, flareBaseSize[0] + 5])
        rotate([90, 90, 0])
        rotate([0, 10, 0])
        linear_extrude(4) {
          flareBaseShape();
        }

      // tab clearance
      translate([bcp-bOffset-chamber*2-8, 0, chamber/2])
        rotate([0, 0, -15])
        minkowski() {
          ccube([0.1, 5, 8]);
          sphere(chamber);
        }

      // tooth
      translate([bcp-bOffset-chamber-1, 0, -1])
        rotate([0, -30, 0])
        minkowski() {
          ccube([4, bolthole*2+boltsupport*2 - chamber*2, boltMountThick]);
          sphere(chamber);
        }

      // box offset
      translate([bcp-bOffset, 0, 0])
        ccube([2, bolthole*2+boltsupport*2,, boltMountThick]);

      // bolt hole
      translate([bcp, 0, 0])
        cylinder(r=bolthole+boltsupport, h=boltMountThick);
    }

    // bolt holes
    translate([0, 0, -1])
      cylinder(r=bolthole, h=boltMountThick+2);
    translate([bcp, 0, -1])
      cylinder(r=bolthole, h=boltMountThick+2);
  }
}


union() {
  swatMount();

  translate([(bcp/2)-(flareBaseSize[0]/2)+1.4, flareMountY, flareBaseSize[1] -3.9])
  rotate([-90, -90, 0])
  rotate([0, 10, 0])
    flare();
}

