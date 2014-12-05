//sketch params
boolean showSegs=true;
boolean showJoins=false;
boolean showFins=false;

//Worm params

int wormMaxLen=20;
int wormSegMaxWidth=20;
int wormSegMaxLen=10;
int wormWavelength=6;
int segWavelength=4;

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


class Segment{
  //vars
  int x,y,w,l;
   color c;
   float startA, flexA;
   float maxFlexA;//=PI/8;
   int gap=5;
   boolean anchor;

  //constructor
  Segment(int w_,int l_, int c_, boolean anchor_){
    w=w_;
    l=l_;
    c=color(c_,150,150);
    anchor=anchor_;
    if (anchor) maxFlexA=2*PI;
    else maxFlexA=maxSegFlex;
  }
  
  // High level functions
  
  void drawSeg(){
     pushMatrix();
     rectMode(CORNER);
     translate(x,y);
     rotate(startA);
     if (showFins){
       stroke(200);
       line(0,0,0,-50);
     }
     rotate(flexA);
     fill(c,100);
     noStroke();
     rect(-w/2,0,w,l);
     //translate(0,l);
     //fill(0,0,255);
     //ellipse(0,0,5,5);
     popMatrix();
  }
  
  void rotateBy(float a){
     this.startA+=a; 
  }
  
  void rotateTo(float a){
     this.startA=a; 
  }
  
  float rotateSeg(float a){
    float excess=0.0;
    this.flexA+=a;
    if(!this.anchor){
      if(this.flexA>this.maxFlexA){
        excess=this.flexA-this.maxFlexA;
        this.flexA=maxFlexA;
      }
      if(this.flexA<-this.maxFlexA){
        excess=this.flexA+this.maxFlexA;
        this.flexA=-maxFlexA;
      } 
    }
    return excess;
  }
  
  void straightenSeg(int damp){
    if (abs(this.flexA)>PI/30)
    this.flexA-=this.flexA*0.8/damp;
  }
  
  // Low level functions
    void setStart(int nx, int ny, float na){
    this.x=nx;
    this.y=ny;
    this.startA=na;
  }
  
  float[] getStart(){
    float[] xya= {this.x,this.y,this.startA+this.flexA};
    return xya;
  }
  
  float getStartAngle(){
    return this.startA;
  }
  
  float[] getEnd(){
    float[] xya={0,0,0};
    xya[0]=x+(cos(startA+flexA+PI/2)*(l+gap));
    xya[1]=y+(sin(startA+flexA+PI/2)*(l+gap));
    xya[2]=startA+flexA;
    return xya;
  }
  
  float[][] getLeftSide(){
    float[][] leftSide={{0,0},{0,0}};
    leftSide[0][0]=x-(cos(startA+flexA)*(w/2));
    leftSide[0][1]=y-(sin(startA+flexA)*(w/2));
    leftSide[1][0]=leftSide[0][0]+(cos(startA+flexA+PI/2)*(l));
    leftSide[1][1]=leftSide[0][1]+(sin(startA+flexA+PI/2)*(l));    
    //stroke(255,0,0);
    //line (leftSide[0][0],leftSide[0][1],leftSide[1][0],leftSide[1][1]);
    return leftSide;
  }
  
  float[][] getRightSide(){
    float[][] rightSide={{0,0},{0,0}};
    rightSide[0][0]=x+(cos(startA+flexA)*(w/2));
    rightSide[0][1]=y+(sin(startA+flexA)*(w/2));
    rightSide[1][0]=rightSide[0][0]+(cos(startA+flexA+PI/2)*(l));
    rightSide[1][1]=rightSide[0][1]+(sin(startA+flexA+PI/2)*(l));    
    //stroke(0,0,255);
    //line (rightSide[0][0],rightSide[0][1],rightSide[1][0],rightSide[1][1]);
    return rightSide;
  }
  
  float angleDiff(float ang){
    float diff=ang-(startA+flexA);
    if(diff>PI) diff=diff-2*PI;
    if(diff<-PI) diff=diff+2*PI;
    return diff;
  }
  
  float getFlexA(){
    return this.flexA; 
  }
  
} //end of Segment class

/************************************/

//Utility functions

float getAngle(int sx, int sy, int ex, int ey){
  return atan2(ey-sy,ex-sx); 
}

class Worm{
 //declare vars
  Segment[] segs;
  float[] startW;//={0,0,0};
  int startX, startY;
  int numSegs;
  int segW;
  int segH;
  int segsDampInc;
  float[][][] segCoordsL; //segs, side (L,R), corner(top, bottom), x/y
  float[][][] segCoordsR; //segs, side (L,R), corner(top, bottom), x/y
  int wormPursuit=0;
  boolean wormReach=false;
  int loco=0;
  int locoDir=1;
  int locoMax=30;

 Worm(int x_, int y_, int n_, int w_, int h_){
    startX=x_;
    startY=y_;
    numSegs=n_;
    segW=w_; segH=h_;
    segsDampInc=segsDampMax/numSegs;
    float[] s={(float)startX, (float)startY, 0.0};
    startW=s;
 }
 //Highlevel methods
 //track
 //follow
 //eat
 //grow
 //die
 //feed
 
 //Worm behaviour
 
 boolean inReach(){
   if(isInsideTrunk(20)<0){
      wormPursuit=0;
      wormReach=true;
   }else{
     wormPursuit++;
     wormReach=false; 
   }   
   return wormReach;
 }
 
 void pursue(){
   if(wormPursuit<60){ alignToMouse();}
   else if(wormPursuit<60) { /*straighten(5);*/;}
   else locomote(); 
 }
 
 void noPursue(){
   alignToMouse(); 
 }
 
 void locomote(){
   float[] xy={0,0};
   loco+=locoDir;
   if(loco>locoMax||loco<0)locoDir=-locoDir;
   if(locoDir>0){
     xy=extend(PI/200); 
     moveStart(xy[0], xy[1]); 
   }else{
     contract(PI/200); 
   }
   alignToMouse();
 }
 
 //Movement functions
 
 /*   propegate takes an initial angle and rotates teh head degment, 
 any amount left opver from that angle change when max flex is taken 
 into account, is passed back and then teh next segment is rotated.
 It therefore propegates angles shift down the worm.
 */
 void propegate(float a){
   float b;
   for (int i=segs.length-1; i>=0; i--){
     b=segs[i].rotateSeg(a);
     a=b;
   } 
  }
 
 /* alignToMouse works out the angle from the mouse position to the end segment
 then work out the difference from teh current segment angle. rotate the segment by this angle
 divieded by a damper, which increses the further from teh head the segment is.
 */
  void alignToMouse(){
    float[] last={0,0,0};
    float a;
    float b;
    last=segs[segs.length-1].getStart();
    a=getAngle((int)last[0], (int)last[1],mouseX, mouseY); 
    for (int i=segs.length-1; i>=0; i--){
     b=segs[i].angleDiff(a);
     segs[i].rotateSeg((b-PI/2)/((segs.length-i)*segsDampInc+segsDampInc));
    } 
    alignStartToMouse(20);
   }
  
  void contract(float a){ 
    int segCycle=0;  
    int segInc=1;
    float midSeg=segs.length/2; 
    float dampCurve;
    float aChange=0.0;
    float aPre=getAbsAngle(segs.length-1);
    //segs[1].rotateS(-a*segWaveLength/8); 
    for(int i=2; i<segs.length; i++){
      dampCurve=1-(abs(i-midSeg)*0.75/midSeg);
      aChange+=a*segInc*dampCurve;
      segs[i].rotateSeg(a*segInc*dampCurve); 
      segCycle+=segInc;
      if (segCycle>segWavelength/2||segCycle<0) segInc=-segInc;
    }
    float aPost=getAbsAngle(segs.length-1);
    segs[0].rotateSeg(+aPre-aPost);
  }
  
  float[] extend(float a){ 
    float[] xyDiff={0,0};
    float[] xyaEndNew={0,0,0};
    float[] xyaEndOrig=segs[segs.length-1].getEnd();
    float midSeg=segs.length/2; 
    float dampCurve;
    float aPre=getAbsAngle(segs.length-1);
    int segCycle=0;  
    int segInc=1;
    float aChange=0.0;
    //segs[1].rotateS(a*segWaveLength/8); 
    for(int i=2; i<segs.length; i++){
      dampCurve=1-(abs(i-midSeg)*0.75/midSeg);
      aChange+=a*segInc*dampCurve;
      if (abs(segs[i].getFlexA())>PI/30)
        segs[i].rotateSeg(-a*segInc*dampCurve); 
      segCycle+=segInc;
      if (segCycle>segWavelength/2||segCycle<0) segInc=-segInc;
    }
    float aPost=getAbsAngle(segs.length-1);
    segs[0].rotateSeg(+aPre-aPost);   
    drawSegs();
    xyaEndNew=segs[segs.length-1].getEnd();
    xyDiff[0]=(xyaEndOrig[0]-xyaEndNew[0])*.75;
    xyDiff[1]=(xyaEndOrig[1]-xyaEndNew[1])*.75;
    return xyDiff;
  }
  
  /*
   Pushback, calculate angle from worm tail to mouse. calcumate angle of each segment from tail.
   If diff is +ve rotate back a little, esle rotate forward a little,
   This effectively collapses the worm back a litlel bit.
  */ 
  void pushBack(float diff){
    float[] xya=segs[0].getStart();
    float mouseA=getAngle((int)xya[0], (int)xya[1], (int)mouseX, (int)mouseY);
    for (int i=segs.length-1; i>=0; i--){
       if(mouseA>=getAbsAngle(i))
         segs[i].rotateSeg(-PI/10000*i);
       else
         segs[i].rotateSeg(PI/10000*i);
    }
  }
 
 /*
   Straighten - reduce flex angles a little bit until all are minFlex
 */
 void straighten(int damp){
   for (int i=0; i<segs.length-1; i++){
     segs[i].straightenSeg(damp);
   } 
  }

 //Create and draw functions
 void buildSegs(){
  float[] start=startW;
  int c=100;
  segs=new Segment[numSegs];
  segCoordsL=new float[numSegs][2][2];
  segCoordsR=new float[numSegs][2][2];
  float midSeg=segs.length/2; 
  float segSlim;
  segs[0]=new Segment(segW/10,segH/4,100,true); 
  segs[0].setStart((int)start[0], (int)start[1], start[2]);
  start=segs[0].getEnd();
  for (int i=1; i<segs.length; i++){
    segSlim=1-(abs(i-midSeg)*0.5/midSeg);
    segs[i]=new Segment((int)(segW*segSlim),segH-(segH/4*3/numSegs*i),i==segs.length-2?255:100,false); 
    segs[i].setStart((int)start[0], (int)start[1], start[2]);
    start=segs[i].getEnd();
  }
 }
 
 void drawSegs(){
   //float[] start=segs[0].getTrueStart();
   float[] start=startW;
   start[2]=segs[0].getStartAngle();
   for (int i=0; i<segs.length; i++){
    segs[i].setStart((int)start[0], (int)start[1], start[2]);
    if(showSegs){
      segs[i].drawSeg();
    }
    start=segs[i].getEnd();
    segCoordsL[i]=segs[i].getLeftSide();
    segCoordsR[i]=segs[i].getRightSide();
   }
  }
 
 void drawWorm(){
    float[] xya;
    beginShape();
    stroke(100,200,255);
    fill(100,200,255,10);
    if(!showSegs) fill(100,200,255,100); else noFill();
    curveVertex(segCoordsL[0][1][0],segCoordsL[0][1][1]);
    if (showJoins) ellipse(segCoordsL[0][1][0],segCoordsL[0][1][1],5,5);
    for (int i=0; i<segs.length; i++){
      curveVertex(segCoordsL[i][1][0],segCoordsL[i][1][1]);
      if (showJoins) ellipse(segCoordsL[i][1][0],segCoordsL[i][1][1],5,5);
    }
    //curveVertex(segCoordsL[segs.length-1][1][0],segCoordsL[segs.length-1][1][1]);
    xya=segs[segs.length-1].getEnd();
    curveVertex(xya[0], xya[1]);
    //curveVertex(segCoordsR[segs.length-1][1][0],segCoordsR[segs.length-1][1][1]);
    if (showJoins) ellipse(segCoordsR[0][1][0],segCoordsR[0][1][1],5,5);
    for (int i=segs.length-1; i>=0; i--){
      curveVertex(segCoordsR[i][1][0],segCoordsR[i][1][1]);
      if (showJoins) ellipse(segCoordsR[i][1][0],segCoordsR[i][1][1],5,5);
    }
    curveVertex(segCoordsL[0][1][0],segCoordsL[0][1][1]);
    curveVertex(segCoordsL[0][1][0],segCoordsL[0][1][1]);
    endShape();   
  }
 
 //Basic and functional methods
   void moveStart(float dX, float dY){
    startW[0]+=dX;
    startW[1]+=dY;
  }
  
  void alignStartToMouse(int damp){
    //float aHead=getAbsAngle(segs.length-1);
    float[] xya=segs[0].getStart();
    float aMouse=getAngle((int)xya[0], (int)xya[1], mouseX, mouseY);
    //segs[0].rotateBy((aMouse-xya[2])/damp);
    segs[0].rotateBy((aMouse-xya[2]-PI/2)/damp);
    //println(aMouse+" "+xya[2]+" "+round(aMouse-xya[2]));
    drawSegs();
  }
  
  float isInsideTrunk(int gap){
    float[] xya=segs[0].getStart();
    float[] xya2=segs[segs.length-1].getEnd();
    float hypTrunk=sqrt(pow(xya2[0]-xya[0],2)+pow(xya2[1]-xya[1],2));
    float hypMouse=sqrt(pow(mouseX-xya[0],2)+pow(mouseY-xya[1],2));
    return ((hypMouse+gap)-hypTrunk)/hypTrunk;
  }
  
  float getAbsAngle(int segNum){
    float[] xya=segs[0].getStart();
    float[] end=segs[segNum].getEnd();
    float AA=getAngle((int)xya[0], (int)xya[1],(int)end[0], (int)end[1]);
    return AA;
  }
 
} //end of Worm class

//***********************************************************



