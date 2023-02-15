include<MCAD/regular_shapes.scad>;

SINGLE_LED_DIAMETER = 6.0;
LIGHT_SOURCE_RADIUS = 4.85 / 2;
SINGLE_LED_RADIUS = SINGLE_LED_DIAMETER/2;
SINGLE_LED_HEIGHT = 8.60;
DISTANCE_BETWEEN_LEDS = 5;
LED_SPACING = SINGLE_LED_DIAMETER + DISTANCE_BETWEEN_LEDS;
WALL_THICKNESS = 8;
LED_ARC_LENGTH = SINGLE_LED_DIAMETER + DISTANCE_BETWEEN_LEDS/2 + WALL_THICKNESS/2;
JOINT_SPACING = 0.5; // some space between them?
JOINT_THICKNESS = 1; // thickness of the arms
JOINT_ARMS = 5; // how many arms do you want?
ARM_WIDTH = 1; // actually: how much is removed from the arms Larger values will remove more
JOINT_SIZE = 8;

module ball(size)
{
	sphere(r=size);
	translate([0,0,-size]) cylinder(r1=8,r2=6,h=3);
	translate([0,0,-size-3]) cylinder(r=8,h=3);
}



module joint(size){
    difference()    {
        sphere(r=size+JOINT_SPACING+JOINT_THICKNESS);
        sphere(r=size+JOINT_SPACING);
        translate([0,0,-size-3]) cube([size+JOINT_SPACING+JOINT_THICKNESS+25,size+JOINT_SPACING+JOINT_THICKNESS+25,14],center=true);
        for(i=[0:JOINT_ARMS])
        {
            rotate([0,0,360/JOINT_ARMS*i]) translate([-ARM_WIDTH/2,0, -size/2-4])
                cube([ARM_WIDTH,size+JOINT_SPACING+JOINT_THICKNESS+20,size+6]);
        }
    }
        //translate([0,0,size-2]) cylinder(r2=8,r1=8,h=5);
}

module buildLED(radius, rotation){
    rotational_axis = [0,90,0];
    
    //echo("build LED");
    //echo(rotation);
    counter_angle = getAngle(radius, SINGLE_LED_RADIUS + DISTANCE_BETWEEN_LEDS/2);
    //echo(counter_angle);
    rotate([0,0,-rotation+89.5-counter_angle])translate([radius-WALL_THICKNESS,0,0])rotate(rotational_axis) {
        union(){
            translate([0,0,-.5])cylinder(h=WALL_THICKNESS/2, r=SINGLE_LED_RADIUS, $fn=30);
            cylinder(h=SINGLE_LED_HEIGHT-LIGHT_SOURCE_RADIUS, r=LIGHT_SOURCE_RADIUS, $fn=30);
            translate([0, 0,SINGLE_LED_HEIGHT-LIGHT_SOURCE_RADIUS]) sphere(d=LIGHT_SOURCE_RADIUS*2, $fn=30);
        }
    } 
}

module generateLEDMatrix(LED_number, radius, floor_allowance){
    rows = sqrt(LED_number);
    z_mod = floor_allowance ? WALL_THICKNESS : 0;

    for(x = [0:rows-1]){
        translate([0,0,x*LED_SPACING+z_mod])union(){
            angle = getAngle(radius, LED_ARC_LENGTH);
            //echo(angle);
            for(y = [0: rows-1]){
                buildLED(radius, y*angle);
            }
        }
    }
}

function getAngle(radius, arc_length)= ((arc_length) / radius) * (180/PI);

module wedge(h,r,a)
{
	th=(a%360)/2;
	difference()
	{
		cylinder(h=h,r=r,center=true);
		if(th<90)
		{
			for(n=[-1,1])rotate(-th*n)translate([(r+0.5)*n,0,0])
				cube(size=[r*2+1,r*2+1,h+1],center=true);
		}
		else
		{
			intersection()
			{
				rotate(-th)translate([(r+0.5),(r+0.5),0])
					cube(size=[r*2+1,r*2+1,h+1],center=true);
				rotate(th)translate([-(r+0.5),(r+0.5),0])
					cube(size=[r*2+1,r*2+1,h+1],center=true);
			}
		}
	}
}

module build_connector(height, ){}

module ball_connector(height){
     difference(){
         sphere(height/8);
         sphere(height/8-0.5);
         translate([0,-height/5,0])cube(height/4, true);
     }
}

module dummy_ball(height){
    sphere(height/8);
}

module generate_connector_grouping(){
    rotate([-15,0,0])union(){
        sphere(JOINT_SIZE);
        rotate([-65,0,0])translate([0,0,-JOINT_SIZE*1.5])joint(JOINT_SIZE/2);
        rotate([-115,0,0])translate([0,0,-JOINT_SIZE*1.5])joint(JOINT_SIZE/2);
        rotate([-90,0,45])translate([0,0,-JOINT_SIZE*1.5])joint(JOINT_SIZE/2);
        rotate([-90,0,-45])translate([0,0,-JOINT_SIZE*1.5])joint(JOINT_SIZE/2);
    }    
}

module cross_cut_squares(height, backing_radius){
    union(){
        for(i = [0 : 90 : 270]){
            rotate_about_pt(0,i,0,[0,0,height/2])translate([0,-height/4,-WALL_THICKNESS])rotate([0,45, 0])scale([1,2,1])cube(height/sqrt(2),true);
        }
    }
}

module rotate_about_pt(x, y, z, pt) {
    translate(pt)
        rotate([x, y, z])
            translate(-pt)
                children();   
}

module build_panel_backing(radius, height, panel_angle){
    backing_radius = sin(panel_angle/2)*radius;
    midline_length = cos(panel_angle/2)*radius;
    elipse_width = (radius - height > 0) ? height/4 : radius/4;
    rotate([0,0,-panel_angle/2])translate([0, radius-(radius-midline_length),0])union(){
        difference(){
            translate([0,0,height/2])oval_tube(height, backing_radius, elipse_width, WALL_THICKNESS, center = true);
            translate([0, (height+5)/2, height/2-1])cube(height+5, center = true);
            cross_cut_squares(height, backing_radius);  
        }
        translate([0,-elipse_width+JOINT_SIZE/4, height/2])generate_connector_grouping();
    }
}

function calculate_panel_height(matrix_size, bottom)=(
    bottom ? sqrt(matrix_size)* LED_SPACING+DISTANCE_BETWEEN_LEDS + WALL_THICKNESS 
    : sqrt(matrix_size)* LED_SPACING+DISTANCE_BETWEEN_LEDS
);

module generate_panel_blank(panel_height,radius, total_angle, bottom){
    union(){
        intersection(){
            translate([0,0,panel_height/2])rotate([0,0,-total_angle/2])wedge(panel_height, radius+2, total_angle);
            difference(){
                cylinder(h=panel_height, r=radius, $fn=100);
                if(bottom){
                    translate([0,0,WALL_THICKNESS])cylinder(h=panel_height, r=radius-WALL_THICKNESS, $fn=100);
                }
                else{
                    translate([0,0,-1])cylinder(h=panel_height+WALL_THICKNESS, r=radius-WALL_THICKNESS, $fn=100);
                }
                if (radius - panel_height > 0){
                    translate([0,0,-1])cylinder(h=panel_height + WALL_THICKNESS*2, r=radius - panel_height, $fn=100);
                }
            }
        }
    }
}

module singlePanel(matrix_size, radius, bottom){
    panel_height = calculate_panel_height(matrix_size, bottom);
    //echo(panel_height);
    //echo(panel_height);
    total_angle = getAngle(radius, LED_ARC_LENGTH) * sqrt(matrix_size)+1;
    //echo(total_angle);
    intersection(){
        translate([0,0,-1])cylinder(panel_height+2, r=radius+WALL_THICKNESS, $fn=100);
        difference(){
            union(){
                generate_panel_blank(panel_height,radius, total_angle, bottom);
                build_panel_backing(radius, panel_height, total_angle); 
            }
            translate([0,0,DISTANCE_BETWEEN_LEDS+SINGLE_LED_RADIUS])generateLEDMatrix(matrix_size, radius, bottom);
        }
    }
}
    
singlePanel(25,100, true);
singlePanel(100,50, true);
//rotate([0,0,44])singlePanel(25,50, true);
//translate([0,0,38])singlePanel(25,50, false);
//translate([0,0,38])rotate([0,0,44])singlePanel(25,50, false);
//translate([30,-100,0])singlePanel(25,100);

//rotate([90,0,0])buildLED(0,0);