// Based on the friendly challenge here
// https://twitter.com/josephgentle/status/996194616738172928
// referring to
// https://twitter.com/nattyover/status/996087380959485952
// information on this tiling
// https://en.wikipedia.org/wiki/Socolar%E2%80%93Taylor_tile
// https://arxiv.org/PS_cache/arxiv/pdf/1003/1003.4279v1.pdf

import processing.pdf.*;
boolean makePDF=false;
//boolean analyseNeighbors=true;
//boolean doLoop=true;
boolean analyseNeighbors=false;
boolean doLoop=false;

// the shape parameters for the S-T tile
float v=1./5.;
float q=1./10.;
float d=1./6.;


class float2
{
  float2()
  {
    x=0;
    y=0;
  }
  float2(float in_x, float in_y)
  {
    x=in_x;
    y=in_y;
  }
  public  float x,y;
};

class int2
{
  int2()
  {
    x=0;
    y=0;
  }
  int2(int in_x, int in_y)
  {
    x=in_x;
    y=in_y;
  }
  public  int x,y;
};

PFont theFont;
int theCase=0;
byte[] validCases;


void setFillToRandomPastel() {
   fill(50+int(random(10))*10,50+int(random(10))*10,50+int(random(10))*10);
}

void drawTile(float2 pos,float radius, float orient, float reflect)
{
  float tempStrokeWeight=g.strokeWeight;
  pushMatrix();
  translate(pos.x,pos.y);
  scale(radius);
  rotate(orient+PI);
  strokeWeight(tempStrokeWeight/radius);
  float angularStep=PI/3;
  beginShape();
  for(int i=0;i<6;++i) {
     float vx=sin(angularStep*i);
     float vy=cos(angularStep*i);
     float cornerx=vx;
     float cornery=vy;
     vertex(cornerx*reflect,cornery);
     vx=sin(angularStep*(i+0.5));
     vy=cos(angularStep*(i+0.5));
     float whichway=(i==0 || i==3 || i==5)?0:1;
     float px=cornerx+vy*(1./2.-v-q*whichway);    
     float py=cornery-vx*(1./2.-v-q*whichway);
     vertex(px*reflect,py);
     px=px-vx*d;
     py=py-vy*d;
     vertex(px*reflect,py);
     px=px+vy*(2*v+q);
     py=py-vx*(2*v+q);
     vertex(px*reflect,py);
     px=px+vx*d;
     py=py+vy*d;
     vertex(px*reflect,py);
  }
  endShape(CLOSE);
// Large paired rectangles
  for(int i=0;i<6;++i) {
     float sign=(i==2 || i==5 || i==4)?-1:1;
     float vx=sin(angularStep*i);
     float vy=cos(angularStep*i);
     beginShape();
       vertex((1.5-v)*vx*reflect,(1.5-v)*vy);
       vertex(1.5*vx*reflect,1.5*vy);
       vertex((1.5*vx+d*vy*sign)*reflect,1.5*vy-d*vx*sign);
       vertex(((1.5-v)*vx+d*vy*sign)*reflect,(1.5-v)*vy-d*vx*sign);
     endShape(CLOSE);

     beginShape();
       vertex((1.5+v)*vx*reflect,(1.5+v)*vy);
       vertex(1.5*vx*reflect,1.5*vy);
       vertex((1.5*vx-d*vy*sign)*reflect,1.5*vy+d*vx*sign);
       vertex(((1.5+v)*vx-d*vy*sign)*reflect,(1.5+v)*vy+d*vx*sign);
     endShape(CLOSE);
  }
  // small interlocking rectangles
  for(int i=0;i<6;++i) {
     float vx=sin(angularStep*i);
     float vy=cos(angularStep*i);
     float cornerx=vx;
     float cornery=vy;
     vx=sin(angularStep*(i+0.5));
     vy=cos(angularStep*(i+0.5));
     beginShape();
        float px=cornerx+vy*((i==0 || i==3 || i==5)?0.5+v:0.5-v-q);    
        float py=cornery-vx*((i==0 || i==3 || i==5)?0.5+v:0.5-v-q);
        vertex(px*reflect,py);
        px=px+vx*d;
        py=py+vy*d;
        vertex(px*reflect,py);
        px=px+vy*q;
        py=py-vx*q;
        vertex(px*reflect,py);
        px=px-vx*d;
        py=py-vy*d;
        vertex(px*reflect,py);
     endShape(CLOSE);
  }

  // Draw the triangle lines that have to join up
  //
   float pxcase2=0;
   float pycase2=0;
   for(int i=0;i<6;++i) {
     float vx=sin(angularStep*i);
     float vy=cos(angularStep*i);
     float cornerx=vx;
     float cornery=vy;
     vx=sin(angularStep*(i+0.5));
     vy=cos(angularStep*(i+0.5));
     float px=cornerx+vy*(((i==0 || i==3 || i==5)?0.5+v:0.5-v-q)+q/2.);    
     float py=cornery-vx*(((i==0 || i==3 || i==5)?0.5+v:0.5-v-q)+q/2.);
     line(px*reflect,py,(px+vx*d)*reflect,py+vy*d);
     px-=vx*d;
     py-=vy*d;
     switch (i) {
       case 0:
       case 1:
       case 3:
       case 4:
       line(px*reflect,py,(px-vx/3.)*reflect,py-vy/3.);
       break;
       case 2:
       pxcase2=px;
       pycase2=py;
       break;
       case 5:
       line(pxcase2*reflect,pycase2,px*reflect,py);
       break;
     }
   }
    

  float arrowlength=1./2.;
  float headlength=1./6.;
  //float vx=sin(orient+PI);
  //float vy=cos(orient+PI);
  float toparrowx=0;//x+arrowlength/2*vx;
  float toparrowy=-arrowlength/2.;//y+arrowlength/2*vy;
  line(0,arrowlength/2,
  toparrowx,toparrowy);
  line(toparrowx*reflect,toparrowy,(toparrowx+headlength*sin(PI/6))*reflect,toparrowy+headlength*cos(PI/6));
  line(toparrowx*reflect,toparrowy,(toparrowx+headlength*sin(-PI/6))*reflect,toparrowy+headlength*cos(-PI/6));
  // make the arrow chiral, so we can see the reflection
  line((toparrowx+headlength*sin(-PI/6))*reflect,toparrowy+headlength*cos(-PI/6), toparrowx*reflect,toparrowy+headlength*cos(PI/6) );
  popMatrix();
  strokeWeight(tempStrokeWeight);
}
float2 hexIndexToCartesian(int2 index, float radius)
{
  float2 pos=new float2();
  pos.x=(index.x+(abs(index.y)%2)/2.0)*radius*sqrt(3);
  pos.y=index.y*radius*1.5;
  return pos;
}

int[] pixelInventory()
{
  loadPixels();
  int counts[]=new int[256];
  for(int i=0;i<256;++i)
  {
    counts[i]=0;
  }
  for(int i=0;i<width*height;++i)
  {
     ++counts[pixels[i]&0xFF];
  }
  return counts;
}
int2 GetNeighbourIndex(int2 baseIndex,int side)
{
  int2 neighbor=new int2();
  switch (side)
  {
    case 0:
    neighbor.x=baseIndex.x;
    neighbor.y=baseIndex.y-1;
    break;
    case 1:
    neighbor.x=baseIndex.x-1;
    neighbor.y=baseIndex.y;
    break;
    case 2:
    neighbor.x=baseIndex.x-1+abs(baseIndex.y)%2;
    neighbor.y=baseIndex.y+1;
    break;
    case 3:
    neighbor.x=baseIndex.x+abs(baseIndex.y)%2;
    neighbor.y=baseIndex.y+1;
    break;
    case 4:
    neighbor.x=baseIndex.x+1;
    neighbor.y=baseIndex.y;
    break;
    case 5:
    neighbor.x=baseIndex.x+1;
    neighbor.y=baseIndex.y-1;
    break;
  }
  return neighbor;
}

void drawTileAtHexIndex(int2 hexIndex, float radius, int orientation)//float orientation,float reflect)
{
  float orient=float(orientation%6)*PI/3.0;
  float reflect=orientation<6?1:-1;
  float2 pos=hexIndexToCartesian(hexIndex, radius);
  drawTile(new float2(pos.x+width/2,pos.y+height/2),radius,orient,reflect);
}



void mouseClicked()
{
  theCase=(theCase+1);//%144;
}

class TileArray
{
  TileArray()
  {
     minIndex = new int2(0,0);
     maxIndex = new int2(0,0);
     sz=new int2(0,0);
     isSetup=false;
  }
  void setup(float r, int2 lowerbounds,int2 upperbounds)
  {
    radius=r;
    // The extent of a tile is (1.5+v)*radius
    //  pos.x=(index.x+(index.y%2)/2.0)*radius*sqrt(3);
    //  pos.y=index.y*radius*1.5;
    minIndex.x=max(ceil(-(width/2.0)/r/sqrt(3)-(1.5+v)/sqrt(3)-0.5),lowerbounds.x);
    minIndex.y=max(ceil(-(height/2.0)/r/1.5-(1.5+v)/1.5),lowerbounds.y);
    maxIndex.x=min(ceil((width/2.0)/r/sqrt(3)+(1.5+v)/sqrt(3)),upperbounds.x);
    maxIndex.y=min(ceil((height/2.0)/r/1.5+(1.5+v)/1.5),upperbounds.y);
    sz.x=maxIndex.x-minIndex.x;
    sz.y=maxIndex.y-minIndex.y;
    grid=new int[sz.x][sz.y];
    invalid=new int[sz.x][sz.y];
    for(int x=0;x<sz.x;++x)
    {
      for(int y=0;y<sz.y;++y)
      {
        grid[x][y]=int(random(12));
        invalid[x][y]=6;
      }
    }
    invalidCount=sz.x*sz.y;
    totalCount=sz.x*sz.y;
    print("grid extents ");
    print(minIndex.x);
    print(", ");
    print(minIndex.y);
    print("  ->  ");
    print(maxIndex.x);
    print(", ");
    print(maxIndex.y);
    println("");
    
    isSetup=true;
  }
  boolean isSolved()
  {
    boolean retval=true;
    for(int x=0;x<sz.x;++x)
    {
      for(int y=0;y<sz.y;++y)
      {
        if(invalid[x][y]>0)
        {
          return false;
        }
      }
    }
    return retval;
  }
  
  void check()
  {
    invalidCount=0;
    for(int x=0;x<sz.x;++x)
    {
      for(int y=0;y<sz.y;++y)
      {
        int rotshift=grid[x][y]%6;
        int reflect=grid[x][y]<6?0:1;
        int2 realIndex=new int2(x+minIndex.x,y+minIndex.y);
        println("Processing "+str(realIndex.x)+", "+str(realIndex.y)+" type "+str(grid[x][y])+" ("+str(reflect)+"/"+str(rotshift)+")");
        invalid[x][y]=0;
        for(int side=0;side<6;++side)
        {
           int2 ni=GetNeighbourIndex(realIndex,(side+rotshift)%6);
           int2 nii=new int2(ni.x-minIndex.x,ni.y-minIndex.y);
           println("---neighbor "+str(side)+" at "+str(ni.x)+", "+str(ni.y)+" -> "+str(nii.x)+", "+str(nii.y));
           if (nii.x>=0 && nii.x<sz.x && nii.y>=0 && nii.y<sz.y)
           {
             int ntype=grid[nii.x][nii.y];
             int nreflect=ntype<6?0:1;
             int norient=(ntype+rotshift)%6;
             int thisCase=72*reflect+12*side+6*nreflect+norient;
             println("--- became: "+str(ntype)+ "("+str(nreflect)+"/"+str(norient)+")");
             if (validCases[thisCase]==0) {++invalid[x][y];}
           }
        }
        if (invalid[x][y]>0) { ++invalidCount; }
      }
    }
  }
  
  
  void draw()
  {
    for(int x=0;x<sz.x;++x)
    {
      for(int y=0;y<sz.y;++y)
      {
        int z=grid[x][y]+1;
        stroke(0);
        if (invalid[x][y]==0) {
           fill(0,(z&8)/8*255+(z&4)/4*255,(z&2)*64+(z&1)*127);
        } else {
           fill(int(invalid[x][y]*127.0/6.0+128),128,128);
        }
        //if(x+minIndex.x==0 && y+minIndex.y==0) {
        //  fill(0,0,255);
        //}
        drawTileAtHexIndex(new int2(x+minIndex.x,y+minIndex.y),radius,z-1);
        //drawTileAtHexIndex(new int2(x,y),radius,z);
      }
    }
    noFill();
    //rect(width/4,height/4,width/2,height/2);
  }
  public boolean isSetup;
  public int invalidCount;
  public int totalCount;
  float radius;
  int2 minIndex;
  int2 maxIndex;
  int2 sz;
  int[][] grid;
  int[][] invalid;
};
TileArray theTileArray;
void setup()
{
  size(1000,1000,P3D);
  background(128);
  stroke(0);
  noFill();
  if (!doLoop) { noLoop();}
  noSmooth();
  theFont = loadFont("DejaVuSans-10.vlw");
  textFont(theFont);
  frameRate(24);
  theTileArray=new TileArray();
  if (analyseNeighbors) {
    validCases=new byte[144];
  } else {
    validCases=loadBytes("validcases.dat");
    // read from file
  }
}



void draw()
{
  if (makePDF) {
    beginRecord(PDF, "SocolarTaylor.pdf"); 
  }
  float radius=50;
  stroke(88);
 // for(int row=-3;row<4;++row) {
 //   for(int col=-2;col<3;++col) {
 //     Point pos=hexIndexToCartesian(col, row, radius);
 //     drawTile(pos.x+width/2,pos.y+height/2,radius*0.97,0);
 //   }
 // }
  stroke(0);
  //setFillToRandomPastel();
/*
// All the different tiles, none turn out to be the same
  noStroke();
  fill(25);
  
  radius=50;
  drawTileAtHexIndex(new int2(-4,-5),radius,0);
  drawTileAtHexIndex(new int2(-1,-5),radius,0);
  drawTileAtHexIndex(new int2( 2,-5),radius,0);
  drawTileAtHexIndex(new int2(-4,-2),radius,0);
  drawTileAtHexIndex(new int2(-1,-2),radius,0);
  drawTileAtHexIndex(new int2( 2,-2),radius,0);

  drawTileAtHexIndex(new int2(-4,1),radius,0);
  drawTileAtHexIndex(new int2(-1,1),radius,0);
  drawTileAtHexIndex(new int2( 2,1),radius,0);
  drawTileAtHexIndex(new int2(-4,4),radius,0);
  drawTileAtHexIndex(new int2(-1,4),radius,0);
  drawTileAtHexIndex(new int2( 2,4),radius,0);
  fill(255);
  drawTileAtHexIndex(new int2(-4,-5),radius,0);
  drawTileAtHexIndex(new int2(-1,-5),radius,1);
  drawTileAtHexIndex(new int2( 2,-5),radius,2);
  drawTileAtHexIndex(new int2(-4,-2),radius,3);
  drawTileAtHexIndex(new int2(-1,-2),radius,4);
  drawTileAtHexIndex(new int2( 2,-2),radius,5);

  drawTileAtHexIndex(new int2(-4,1),radius,6);
  drawTileAtHexIndex(new int2(-1,1),radius,7);
  drawTileAtHexIndex(new int2( 2,1),radius,8);
  drawTileAtHexIndex(new int2(-4,4),radius,9);
  drawTileAtHexIndex(new int2(-1,4),radius,10);
  drawTileAtHexIndex(new int2( 2,4),radius,11);
*/

  // figure out the legal combinations
  noStroke();
  //stroke(0);
  radius=100;
  int2 baseIndex=new int2(-1,-1);
  //int theCase=(frameCount/24)%144;
  int reflect=theCase/72;
  int side=(theCase/12)%6;
  int orient=theCase%12;
  if (analyseNeighbors && theCase<144) {
    background(128);
    fill(0);
    if (reflect==0) {
       drawTileAtHexIndex(baseIndex,radius,0);
    } else {
       drawTileAtHexIndex(baseIndex,radius,6);
    }
    int[] counts1=pixelInventory();
    fill(255);
    int2 ni=GetNeighbourIndex(baseIndex,side);
    drawTileAtHexIndex(ni,radius,orient);
    int[] counts2=pixelInventory();
    String startString=reflect==0?" Normal":" Reflected";
    textAlign(CENTER);
    text("Case: "+str(theCase)+startString+", with case "+str(orient)+" on side "+str(side),width/2,40);
    String result="";
    if(counts1[0]-counts2[0] < 10) {result=" PASS"; validCases[theCase]=1;}
    else if(counts1[0]>counts2[0]) {result=" FAIL"; validCases[theCase]=0;}
    else if(counts1[0]<counts2[0]) {result=" WTF?"; validCases[theCase]=0;}
    text("Black pixels before: "+str(counts1[0])+" after: "+str(counts2[0])+result,width/2,60);
    theCase=theCase+1;
  }
  else
  {
    if (theCase==144) {
      saveBytes("validcases.dat",validCases);
    }
    background(128);
    if (!theTileArray.isSetup) {theTileArray.setup(100,new int2(-1,-1),new int2(1,1));}
    theTileArray.check();
    theTileArray.draw();
    if(!theTileArray.isSolved())
    {
      fill(255);
      stroke(255);
      text("Number of invalid tiles: "+str(theTileArray.invalidCount) + " / " +str(theTileArray.totalCount),width/2,60);

    }
    
  }
  
  //  drawTileAtHexIndex(0,0,radius,0,-1);
  //println("After First Tile");
  //pixelInventory();
  //setFillToRandomPastel();
  //fill(50);
  //drawTileAtHexIndex(0,1,radius,2*PI/3,1);
  //println("After Second Tile");
  //pixelInventory();
  //setFillToRandomPastel();
  //fill(75);
  //drawTileAtHexIndex(1,0,radius,3*PI/3,1);
  //println("After Third Tile");
  //pixelInventory();
  
  if(makePDF) {
     endRecord();
     // no display version
     // Exit the program 
     println("Finished.");
     exit();
  }
}
