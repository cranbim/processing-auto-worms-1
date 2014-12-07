//sketch params
boolean showSegs=true;
boolean showJoins=true;
boolean showFins=true;

//Worm params

int wormMaxLen=20;
int wormSegMaxWidth=20;
int wormSegMaxLen=10;
int wormWavelength=6;
int segWavelength=4;
float wormMove=1;

//Worms
int numWorms=10;
Worm[] worms;

//seg params
int segsDampMax=200;
float maxSegFlex=PI/4;

void setup(){
  size (800,700);
  worms=new Worm[numWorms];
  for (int i=0; i<numWorms; i++){
    worms[i]=new Worm((int)(random(width/2)+width/4), (int)(random(height/2)+height/4), (int)(random(wormMaxLen/2))+wormMaxLen/2, wormSegMaxWidth, wormSegMaxLen);
    //worms[i]=new Worm(400, 200, 20, wormSegMaxWidth, wormSegMaxLen);
    worms[i].buildSegs();
  }
  smooth();
}

void draw(){
  noStroke();
  fill(100);
  rect(0,0,width,height);
  for (int i=0; i<numWorms; i++){
    if(worms[i].inReach()) 
      worms[i].noPursue();
    else
      worms[i].pursue();
    worms[i].drawWorm();
    worms[i].drawSegs();
  }
}



void mousePressed(){
 println(worms[0].segs[0].startA);
 worms[0].segs[0].startA+=(PI/100); 
 println(worms[0].segs[0].startA);
}

void mouseNotMoved(){
  float[] xy={0,0};
  boolean ext;
  if(mouseY>pmouseY) {ext=true;} else {ext=false;}
  for (int i=0; i<worms.length; i++){
    if(ext){
     xy=worms[i].extend(PI/200); 
     worms[i].moveStart(xy[0], xy[1]);
    }else{
      worms[i].contract(PI/200); 
    }
  }
}

void newmouseMoved(){
  float[] xy={0,0};
  if(mouseY>pmouseY){
   xy=worms[0].extend(PI/200); 
   worms[0].moveStart(xy[0], xy[1]);
  }else{
    worms[0].contract(PI/200); 
  }
}

void mouseDragged(){
  float inside;
  for (int i=0; i<worms.length; i++){
    inside=worms[i].isInsideTrunk(20);
    worms[i].alignToMouse();
/*    
    if(inside>0)
      worms[i].alignToMouse();
    else
      worms[i].contract(PI/200);
*/
  }
}


