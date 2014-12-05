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

