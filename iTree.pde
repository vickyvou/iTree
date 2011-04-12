//Recognition 
import TUIO.*;
TuioProcessing tuioClient;


//Variables Globales
int generation_tree = 5;
float tree_sideIni = 130;
float theta = PI/24;

// SEEDS
int seed = 0;
float numberOfSeeds = 3;

// Paleta de colores de tamaño variable
float [][] coloresInt;

//change the fiducials here
int fiducialMov = 35;
int fiducialGen = 24;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ VOID SETUP () ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
void setup() {
  
  size(800, 800);
  smooth();
  background(0);
  noStroke();
  fill(255);
  initialize_Colors();
  begin_tree(tree_sideIni);
  
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
 
}
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ END VOID SETUP () ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



TuioPoint entrance_point = null;
TuioPoint exit_point = null;
float a = 0;


//******************************************************** VOID DRAW() **********************************************************************
void draw() {
  
  // Control with keyboard
  if ((keyPressed == true) && (key == 'a') && (generation_tree<18)) generation_tree++;
  if ((keyPressed == true) && (key == 'b') && (generation_tree>1)) generation_tree--;
  
  // Control with fiducials
  // FIRST we get a vector(list) with all the objects currently at the webcam
       if ((entrance_point!=null) && (exit_point!=null)) {
         float diff = entrance_point.getY() - exit_point.getY();
         if ((diff>0) && (generation_tree<12))generation_tree++;
         if ((diff<0) && (generation_tree>1))generation_tree--;
         entrance_point = exit_point = null;
         println("Nueva movimiento de generacion "+generation_tree+" con esta diferencia "+diff);
       }
       
  

  initialize_Colors();
  background(0);
  frameRate(30);
  // Let's pick an angle 0 to 90 degrees based on the mouse position
  //float a = (mouseX / (float) width) * 90f;
  // Convert it to radians
  //theta = radians(a);

  // Using the fiducial
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     if (tobj.getSymbolID()==fiducialMov)
     {
       // If there is more than 1 generation we move the tree 
       if (generation_tree!=1)
         a = tobj.getPosition().getX() * 45f;
       // But if we are in the first generation (seed) we chose between all the possible values
       else
       {
         seed = (int) (tobj.getPosition().getX() * numberOfSeeds);
         println(seed);
       }
     }
  }
  
  /*if ((keyPressed == true) && (key == 'x') ){
       println("yes");
    
       if(seed<3){
         seed=seed+1;
         println(seed);
       }
       
     }*/
  
  theta = radians(a);
  //theta=45;
  begin_tree(tree_sideIni);

 }
 // *************************************************** END OF VOID DRAW() ********************************************************************
 
 
//------------------------------------------------------------DEN TO PEIRAZW------------------------------------------------------------
void initialize_Colors() {

  float[] diferencia = new float[3];
  coloresInt = new float[generation_tree][3];
  // Starting color: BROWN.
  coloresInt[0][0]=95.0;
  coloresInt[0][1]=40.0;
  coloresInt[0][2]=23.0;
  // Final Color: Dark Green.
  coloresInt[generation_tree-1][0]=0.0;
  coloresInt[generation_tree-1][1]=100.0;
  coloresInt[generation_tree-1][2]=20.0;

  // Calculate the change increase step
  for (int i=0;i<3;i++) 
  {
    diferencia[i] = (coloresInt[generation_tree-1][i] - coloresInt[0][i])/(generation_tree-1);
  }
  // All colours are initialised
  for (int i=1;i<generation_tree-1;i++)
  {
     for (int j=0;j<3;j++)
     { 
       coloresInt[i][j] = diferencia[j] + coloresInt[i-1][j];
     }
   
  }
}
//---------------------------------------------TELOS TOU DEN TO PEIRAZW-----------------------------------------------------------------








void begin_tree(float tree_side) {
  
  int x,y,control;
  x=width/2;
  y=height/2+100;
  control = 0;
  translate(x,y);
  //println(x+","+y+"tree side="+tree_side);
  chooseTree(tree_side, control);
  drawTree(tree_side, control);
  
}


//========================================CHOOSE TREE=====================================================================================
void chooseTree(float tree_side, int control) {
  
  float new_tree_side;
  new_tree_side = tree_side/2;
  println("new_tree_side:"+new_tree_side);
  fill(floor(coloresInt[control][0]),
       floor(coloresInt[control][1]),
       floor(coloresInt[control][2]));

  switch(seed) {
    case 0: 
      quad (-new_tree_side,-new_tree_side, -new_tree_side,+new_tree_side, +new_tree_side,+new_tree_side, +new_tree_side,-new_tree_side);
      triangle(-new_tree_side,-new_tree_side,+new_tree_side,-new_tree_side,0,-tree_side);
      break;
    case 1:
      triangle(-new_tree_side,-new_tree_side,+new_tree_side,-new_tree_side,0,-tree_side);
      triangle(-new_tree_side,-new_tree_side,+new_tree_side,-new_tree_side,0,0);
      break;
    case 2:
      ellipse (0,0, int(tree_side/2),int(tree_side));
      break;
  }
}
//==========================================END CHOOSE TREE===============================================================================



///////////////////////////////////////////  DRAW TREE /////////////////////////////////////////////////////////////////////////////////
void drawTree(float tree_side, int control) {
  
  if(control<generation_tree-1) {

    float tree_sideSig = sqrt(pow(tree_side,2)/2);
    println("tree:"+tree_sideSig);
    control++;
    
    // We continue by the left side //
    // The actual position is saved
    pushMatrix();
    switch(seed) {
      case 0: 
        translate(-tree_side/2,-tree_side);
        break;
      case 1:
        //translate(-tree_side/2+tree_sideSig/2,-tree_side+tree_sideSig/2);
        translate(-tree_sideSig/2,-tree_sideSig);
        break;
      case 2:
        translate(-(tree_side)/2,-(tree_side/2));
        break;

    }

    rotate(-theta);
    chooseTree(tree_sideSig, control);
    drawTree(tree_sideSig,control);
    popMatrix();
    
    // And by the right side
    pushMatrix();
    
    switch(seed) {
    case 0: 
      translate(tree_side/2,-tree_side);
      break;
    case 1:
      //translate(tree_side/2-tree_sideSig/2,-tree_side+tree_sideSig/2);
      translate(tree_sideSig/2,-tree_sideSig);
      break;
    case 2:
      translate((tree_side)/2,-(tree_side/2));
      break;

    }
    

    rotate(theta);
    chooseTree(tree_sideSig, control);
    drawTree(tree_sideSig,control);
    // Finally we go to the position we were
    popMatrix();
  } 
}
//////////////////////////////////////////////////////////// END OF DRAW TREE  ///////////////////////////////////////////////////////



//---------------------------------------------DEN ME NOIAZEI TI KANOUN AFTA------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  //println("add object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  if (tobj.getSymbolID()==fiducialGen) {
    entrance_point = tobj.getPosition();
    println ("add object at position "+entrance_point.getX());
  }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  //println("remove object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  if (tobj.getSymbolID()==fiducialGen) {
    exit_point = tobj.getPosition();
    println ("remove object at position "+entrance_point.getX());
  }
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  //println("update object "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
  //        +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
          +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}
