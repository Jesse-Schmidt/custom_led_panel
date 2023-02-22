include<MCAD/regular_shapes.scad>;

SINGLE_LED_DIAMETER = 6.0;
LIGHT_SOURCE_RADIUS = 4.85 / 2;
SINGLE_LED_RADIUS = SINGLE_LED_DIAMETER/2;
SINGLE_LED_HEIGHT = 8.60;
DISTANCE_BETWEEN_LEDS = 5;
LED_SPACING = SINGLE_LED_DIAMETER + DISTANCE_BETWEEN_LEDS;
WALL_THICKNESS = 8;

function getAngle(radius, arc_length)= ((arc_length) / radius) * (180/PI);

module buildLED(x_value, y_value){
    rotational_axis = [0,0,0];
    
    translate([x_value, y_value, 0])union(){
            translate([0,0,-.5])cylinder(h=WALL_THICKNESS/2, r=SINGLE_LED_RADIUS, $fn=30);
            cylinder(h=SINGLE_LED_HEIGHT-LIGHT_SOURCE_RADIUS, r=LIGHT_SOURCE_RADIUS, $fn=30);
            translate([0, 0,SINGLE_LED_HEIGHT-LIGHT_SOURCE_RADIUS]) sphere(d=LIGHT_SOURCE_RADIUS*2, $fn=30);
    }
}

module generate_square_matrix(LED_number, outline){
    rows = floor(sqrt(LED_number));
    led_spacing = (DISTANCE_BETWEEN_LEDS + SINGLE_LED_DIAMETER / 2);
    for(x = [0:rows-1]){
        union(){
            //echo(angle);
            for(y = [0: rows-1]){
                if (outline == false){
                    buildLED(x * led_spacing, y * led_spacing);
                }else{
                    if (x == 0 || y == 0 || x == rows-1 || y == rows -1){
                        buildLED(x * led_spacing, y * led_spacing);
                    }
                }
            }
        }
    }
}

module generate_triangle_matrix(LED_number, outline){
    rows = floor(sqrt(LED_number));
    for(x = [0:rows-1]){
        union(){
            //echo(angle);
            for(y = [0: rows-1]){
                if (outline == false){
                    buildLED(x * led_spacing, y * led_spacing);
                }else{
                    if (x == 0 || y == 0 || x == rows-1 || y == rows -1){
                        buildLED(x * led_spacing, y * led_spacing);
                    }
                }
            }
        }
    }
}

module generateLEDMatrix(LED_number, outline, shape){
    if (shape == "square"){
        generate_square_matrix(LED_number, outline);
    }
    if (shape == "triangle"){
        generate_triangle_matrix(LED_number, outline);
    }
}

generateLEDMatrix(25, true, "triangle");
