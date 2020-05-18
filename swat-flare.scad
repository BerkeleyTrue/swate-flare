$fn=50;

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

// base
module flareBase() {
  minkowski() {
    linear_extrude(2.5) {
      difference() {
        square([11.8, 8.8]);

        translate([-0.1, 2])
          square([3.1, 4.8]);

        translate([8.9, 2])
          square([3.1, 4.8]);
      }
    }

    // camfer
    sphere(0.3);
  }
}

union() {
  translate([-2.5, -0.9, 2.5]) flareMount();
  flareBase();
}
