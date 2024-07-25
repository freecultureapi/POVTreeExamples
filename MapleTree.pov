// PoVRay 3.7
// author:  freeculture.api
// date:    July 24 2024
//--------------------------------------------------------------------------
#version 3.7;
global_settings{ assumed_gamma 1.0 }
#default{ finish{ ambient 0.1 diffuse 0.9 }} 
//--------------------------------------------------------------------------
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"
#include "golds.inc"
#include "stones.inc"
#include "woods.inc"
#include "shapes.inc"
#include "shapes2.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"


//-----------------------------------------------------
#include "povtree/trees/maple.inc"
//NOTE: Change this path to match where you place this .inc file
// I have this set in a folder in my pov ray folder like this /POV-Ray/v3.7/include/povtree/trees/maple.inc
// but you could just put the maple.inc file right in you "include" folder and write #include "maple.inc" and that will work too

//-----------------------------------------------------
#declare Tree_01 = object{TREE double_illuminate hollow}  


//-----------------------------------------------------
object{ Tree_01
        scale 4
        rotate< 0, 0, 0>
        translate< 0, 0.00, 0>  
        //no_shadow 
      } 
    
      
      //--------------------------------------------
//----------------------------------------------------


//--------------------------------------------------------------------------
// camera ------------------------------------------------------------------
#declare Camera_0 = camera {/*ultra_wide_angle*/ angle 75      // front view
                            location  <3.0 , 1.0 ,-3.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 2.0 , 0.0>}
#declare Camera_1 = camera {/*ultra_wide_angle*/ angle 90   // diagonal view
                            location  <2.0 , 2.5 ,-3.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
#declare Camera_2 = camera {/*ultra_wide_angle*/ angle 90 // right side view
                            location  <3.0 , 1.0 , 0.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
#declare Camera_3 = camera {
                            location  <3.0 , 1.0 ,-5.0>
                            angle 75
                            right     x*image_width/image_height
                            look_at  <0.0 , 2.0 , 0.0>
                            rotate   <0,-360*(clock+0.010),0>
                            }
camera{Camera_3}
// sun ---------------------------------------------------------------------
light_source{<-1500,2000,-2500> color White}

// sky -------------------------------------------------------------- 
plane{<0,1,0>,1 hollow  
       texture{ pigment{ bozo turbulence 0.92
                         color_map { [0.00 rgb <0.20, 0.20, 1.0>*0.9]
                                     [0.50 rgb <0.20, 0.20, 1.0>*0.9]
                                     [0.70 rgb <1,1,1>]
                                     [0.85 rgb <0.25,0.25,0.25>]
                                     [1.0 rgb <0.5,0.5,0.5>]}
                        scale<1,1,1.5>*2.5  translate< 0,0,0>
                       }
                finish {ambient 1 diffuse 0} }      
       scale 10000}
// fog on the ground -------------------------------------------------
fog { fog_type   2
      distance   50
      color      White  
      fog_offset 0.1
      fog_alt    1.5
      turbulence 1.8
    }

// ground ------------------------------------------------------------
plane { <0,1,0>, 0 
        texture{ pigment{ color rgb<0.35,0.65,0.0>*0.72 }
	         normal { bumps 0.85 scale 0.013 }
                 finish { phong 0.1 }
               } // end of texture
      } // end of plane     
      
      
      
//--------------------------------------------------------------------------
//---------------------------- objects in scene ----------------------------
//--------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------- Grass texture
#declare Tan1 = rgb< 0.86,0.58,0.44>;
#declare Green1=rgb<0.80,0.67,0.20>;
#declare Green2=rgb<0.36,0.63,0.03>;
//#declare Green1=rgb<0.4,0.7,0.2>*0.2;
//#declare Green2=rgb<0.37,0.63,0.07>*0.8;
// --------------------------------------
#declare P_Spotted =pigment {
    spotted
    color_map {
        [0.0  color Tan1*0.1 ]
        [0.2  color Tan1*0.4 ]
        [0.2  color Green1*0.4 ]
        [0.3  color Green1*0.9   ]
        [1.01 color Green1*1.1 ]
    }
} //------------------------
#declare P_Earth = pigment {
    spotted
    color_map {
        [0.0 color Tan1*0.3]
        [0.6 color Tan1*0.3]
        [0.6 color Green1*0.4]
        [1.1 color Green1*0.4]
    }
} //------------------------------ 
#declare P_Green=pigment{Green2*1.1}
//#declare P_Spotted=pigment{Red}
//#declare P_Earth=pigment{Blue}
#declare T_Grass=texture { 
    pigment {
        gradient y
        turbulence 0.2  
        pigment_map {   
            [0.0 P_Earth]
            [0.3 P_Green]
            [0.95 P_Spotted]
            [1.00 P_Earth]
        }
    }
    finish{ specular 0.2 roughness 0.015}
    scale <0.001,1,0.001>    
    
    
    
    
} //---------------------------------------------------------------------------- end Grass texture
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
#include "makegrass.inc"
// -----------------------------------------------------------------------------------------------
// Patch parameters  // ! Final number of triangles = nBlade * nBlade * segBlade * 2 (or 4 if dofold = true)
#declare lPatch=400;             // size of patch
//#declare nBlade=4;              // number of blades per line (there will be nBlade * nBlade blades)
#declare nBlade=50;             // number of blades per line (there will be nBlade * nBlade blades)
#declare ryBlade = 0;           // initial y rotation of blade
#declare segBlade= 15;          // number of blade segments
#declare lBlade = 25;           // length of blade
#declare wBlade = 1;            // width of blade at start
#declare wBladeEnd = 0.3;       // width of blade at the end

#declare doSmooth=0 ; //false;/true; or 0;/1; // true makes smooth triangles
#declare startBend = <0,1,0.3>; // bending of blade at start (<0,1,0>=no bending)
#declare vBend = <0,-0.5,0>;    // force bending the blade (<0,1,1> = 45°)
#declare pwBend = 3;            // bending power (how slowly the curve bends)
#declare rd = 459;              // random seed
#declare stdposBlade = 1;       // standard deviation of blade position 0..1
#declare stdrotBlade = 360;     // standard deviation of rotation
#declare stdBlade = 1.2;        // standard deviation of blade scale;
#declare stdBend = 2;           // standard deviation of blade bending;
#declare dofold = 1 ; //false;/true; or 0;/1; // true creates a central fold in the blade (twice more triangles)
#declare dofile = 0 ; //false;/true; or 0;/1; // true creates a mesh file
#declare fname = "grass_01.inc"     // name of the mesh file to create
// -----------------------------------------------------------------------------------------------
// Prairie parameters
#declare nxPrairie=14;    // number of patches for the first line
#declare addPatches=1;    // number of patches to add at each line
#declare nzPrairie=55;    // number of lines of patches
#declare rd=seed(25307);  // random seed
#declare stdscale=1.5;    // stddev of scale
#declare stdrotate=1;     // stddev of rotation
#declare doTest=0; //false;/true; or 0;/1; // replaces the patch with a sphere
// -----------------------------------------------------------------------------------------------
// Create the patch 
#if (dofile=true) // if the patch is already created, turn off the next line
   MakeGrassPatch(lPatch,nBlade,ryBlade,segBlade,lBlade,wBlade,wBladeEnd,doSmooth,startBend,vBend,pwBend,rd,stdposBlade,stdrotBlade,stdBlade,stdBend,dofold,dofile,fname)
   #declare objectPatch=#include fname
#else        
   #declare objectPatch=object{MakeGrassPatch(lPatch,nBlade,ryBlade,segBlade,lBlade,wBlade,wBladeEnd,doSmooth,startBend,vBend,pwBend,rd,stdposBlade,stdrotBlade,stdBlade,stdBend,dofold,dofile,fname)}
#end        
// -----------------------------------------------------------------------------------------------
// Create the prairie
object{MakePrairie(lPatch,nxPrairie,addPatches,nzPrairie,objectPatch,rd,stdscale,stdrotate,doTest)
// or optional: show Single Patch  
// object{  ObjectPatch
    scale 1/40
    texture{T_Grass }
   /* size ~ 1.00 !!! */
 // scale 1     // -> size ~  1 units high
 scale 0.5 // -> size ~0.5 units high
 translate<0,0,-15>
}  



