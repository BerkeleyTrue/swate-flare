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

spineLength = 11.8;
module spine() {
  hull() {
    sphere(0.7);
    translate([spineLength, 0, 0]) sphere(0.7);
  }
}

flareMountHeight = 16;
flareMountWidth = 12.5;
flareMountThickness = 2;

tabExtrusionWidth = 5.5;
tabExtrusionHeight = 10.3;
cutOutThickness = 1.68;
// flare mount
module flareMount() {
  union() {
    chamfer = 0.5;
    minkowski() {
      // main platform
      linear_extrude(flareMountThickness - chamfer) {
        difference() {
          union() {
            square([flareMountHeight - chamfer, flareMountWidth - chamfer]);
            // tab extrusion
            translate([(flareMountHeight - tabExtrusionWidth) / 2, 10])
              square([tabExtrusionWidth, tabExtrusionHeight]);
          }
          // cut outs
          translate([((flareMountHeight - tabExtrusionWidth) / 2) - cutOutThickness, 10])
            square([cutOutThickness, 2.75]);
          translate([(flareMountHeight + tabExtrusionWidth) / 2, 10])
            square([cutOutThickness, 2.75]);
        }
      }
      // camfer
      sphere(chamfer / 2);
    }

    // spines
    translate([(flareMountHeight - spineLength) / 2, 1.75, flareMountThickness - chamfer])
      spine();
    translate([(flareMountHeight - spineLength) / 2, 8.80, flareMountThickness - chamfer])
      spine();

    /* tab claw */
    translate([10.70, 15.5, 2]) rotate([0, -90, 0])
      linear_extrude(5.5) {
        polygon([[0, 0], [0, 2.2], [1, 2.2]]);
      }

    // tab head
    translate([3, 18, 1.90 - chamfer])
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
    translate([3, 19.4, -3.65 - chamfer])
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
module flareBaseShape(chamfer = 0.6) {
  difference() {
    square(flareBaseSize - [chamfer, chamfer]);

    translate([-0.1, 2])
      square([3.1, 4.8]);

    translate([8.9, 2])
      square([3.1, 4.8]);
  }
}
// base
module flareBase() {
  chamfer = 0.6;
  minkowski() {
    linear_extrude(2.5 - chamfer) {
      flareBaseShape(chamfer);
    }

    // camfer
    sphere(chamfer / 2);
  }
}

// flare mount and base
module flare() {
  union() {
    translate([-2.5, -0.9, 2.2])
      flareMount();
    flareBase();
  }
}

boltMountThick = 4; // bolt hole thickeness in the axial direction
bolthole=5.6 / 2; // bolt hole radius
boltsupport=3/2; // bolt hole mount thickness
flareMountY = 2; // how far the flare mount is back from the swat mount holes
bcp = 60; // distance between bolt hole centers

module swatMount() {
  bOffset=6;
  difference() {
    chainedHull() {
      // bolt mount
      cylinder(r=bolthole+boltsupport, h=boltMountThick);

      // box offset
      translate([bOffset, 0, 0])
        ccube([2, bolthole*2+boltsupport*2, boltMountThick]);

      // tooth
      chamber = 2;
      translate([bOffset+chamber+1, 0, -1])
        rotate([0, 30, 0])
        minkowski() {
          ccube([4, bolthole*2+boltsupport*2 - chamber*2, boltMountThick]);
          sphere(chamber);
        }

      tabYOffset = -3;
      // tab clearance
      translate([bOffset+chamber*2+8, tabYOffset, chamber/2])
        rotate([0, 0, 15])
        minkowski() {
          ccube([0.1, 5, 8]);
          sphere(chamber);
        }

      // flare mount face
      translate([(bcp/2)-(flareBaseSize[1]/2) - 0.09, flareMountY, flareBaseSize[0] + 14.8])
        rotate([90, 90, 0])
        rotate([0, 10, 0])
        linear_extrude(4) {
          flareBaseShape(0);
        }

      // tab clearance
      translate([bcp-bOffset-chamber*2-8, tabYOffset, chamber/2])
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

      // bolt mount
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

  translate([(bcp/2)-(flareBaseSize[0]/2)+1.7, flareMountY + 2, flareBaseSize[1] + 6.5])
  rotate([-90, -90, 0])
  rotate([0, 10, 0])
    flare();
}

