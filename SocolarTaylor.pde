// Based on the friendly challenge here
// https://twitter.com/josephgentle/status/996194616738172928
// referring to
// https://twitter.com/nattyover/status/996087380959485952
// information on this tiling
// https://en.wikipedia.org/wiki/Socolar%E2%80%93Taylor_tile
// https://arxiv.org/PS_cache/arxiv/pdf/1003/1003.4279v1.pdf

import processing.pdf.*;
import processing.svg.*;
// Drawing modes - they have individual parameters in what follows
static final int DRAW_DEBUG=0;
static final int DRAW_CURVE=1;
static final int DRAW_SHAPE=2;


// High level controls
boolean makePDF=false;  // cant save PDF and SVG at same time
String pdf_file_name="socolar_taylor.pdf";

boolean makeSVG=true;
String svg_file_prefix="socolar_taylor_debug";

boolean makePNG=false;
String png_file_name="sttile.png";

boolean showTileVariants=true;  // If true, just shows the variants of the tile that can be created
                                 // (a debug mode)
                                 
boolean trimOffPage=true;  // don't draw any within radius of window edge

// Control parameters
// Tiling grid and size
float radius=20;
int Ncols=72;
int Nrows=72;

int drawing_mode=DRAW_CURVE;
// debug mode parameters
float debug_radial_factor=0.97; // shrink the hexagon a little in debug so we see a gap
// curve mode parameters
// shape mode parameters
color shape_triangle_stroke_color=color(200);
float shape_triangle_stroke_weight=2;
boolean shape_draw_arrowhead=false;
color shape_hexagon_stroke_color=color(50);
float shape_hexagon_stroke_weight=1;


// Handy constants
static final float angularStep=PI/3;
static final float sin60=sin(PI/3);
static final float cos60=cos(PI/3);

void setup()
{
  if (makePDF && makeSVG) {
    println("Can't save both PDF and SVG at once");
    exit();
  }
  size(1500,1500);
  background(255);//150);
  noFill();
  noLoop();
  smooth();
  PFont font;
  font = loadFont("Dialog-plain-9.vlw");
  textFont(font, 9);
  textAlign(CENTER,CENTER);
  ellipseMode(CENTER);
}

PVector hexIndexToCartesian(int column, int row, float radius)
{
  PVector pos=new PVector();
  float r=radius*sqrt(3);
  pos.x=column*r+row*cos60*r;
  pos.y=row*sin60*r;
  return pos;
}

class Intersection {
  PVector p;
  float alpha;
  float beta;
  boolean valid;
  Intersection() {
    p=new PVector();
    alpha=0;
    beta=0;
    valid=false;
  }
};

Intersection intersection(PVector p1,PVector p2,PVector q1, PVector q2)
{
  //https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
  //println("intersection: "+p1.x+","+p1.y);
  Intersection retval=new Intersection();
  PVector r=PVector.sub(p2,p1);
  PVector s=PVector.sub(q2,q1);
  float denominator=r.cross(s).z;
  if (abs(denominator) < 1.e-6) {return retval;} //-------------------------------------------- invalid
  retval.valid=true;
  PVector qminusp=PVector.sub(q1,p1);
  retval.alpha=qminusp.cross(s).z/denominator;
  //return new PVector(p1.x,p1.y);
  retval.beta=qminusp.cross(r).z/denominator;
  retval.p=PVector.add(p1,PVector.mult(r,retval.alpha));
  return retval;
}

void hatchPoly(PVector[] points,float angle, float spacing) {
  PVector vx=new PVector(sin(angle),cos(angle));
  PVector vy=new PVector(sin(angle+PI/2),cos(angle+PI/2));
  // Project all points into hatching coordinate system
  PVector lowcorner=new PVector(999999.,999999.);
  PVector highcorner=new PVector(-999999.,-999999.);
  for (int i=0;i<points.length;++i) {
    float pvx=PVector.dot(points[i],vx);
    float pvy=PVector.dot(points[i],vy);
    lowcorner.x=min(lowcorner.x,pvx);
    lowcorner.y=min(lowcorner.y,pvy);
    highcorner.x=max(highcorner.x,pvx);
    highcorner.y=max(highcorner.y,pvy);
  }
  float x=lowcorner.x+spacing;
  while (x<highcorner.x) {
    PVector p1=vx.copy();
    p1.mult(x);
    PVector p2=p1.copy();
    PVector off=vy.copy();
    p1.add(PVector.mult(off,lowcorner.y-10));
    p2.add(PVector.mult(off,highcorner.y+10));
    float[] inters={};
    for (int i=0;i<points.length;++i) {
      Intersection inter=intersection(p1,p2,points[i],points[(i+1)%points.length]);
      if (inter.valid && inter.alpha>1.e-6 && inter.alpha<.99999  && inter.beta>=0 && inter.beta<=1) {
        inters=(float[])append(inters,inter.alpha);
      }
    }
    inters=sort(inters);
    PVector v=PVector.sub(p2,p1);
    for(int i=1;i<inters.length;i+=2) {
      PVector l1=PVector.add(p1,PVector.mult(v,inters[i-1]));
      PVector l2=PVector.add(p1,PVector.mult(v,inters[i]));
      line(l1.x,l1.y,l2.x,l2.y);
    }
    x+=spacing;
  }
}



PVector upper_corner=new PVector();
PVector lower_corner=new PVector();
class Tile {
  int grid_col;
  int grid_row;
  int orientation;
  int hilow;
  int mirror;
  PVector pos;
  float radius;
  int lattice;
  int drawmode;
  float v;
  float q;
  float d;
  
  Tile(int col, int row, float rad) {
    grid_col=col; 
    grid_row=row; 
    orientation=-1;
    hilow=-1;
    mirror=-1;
    pos=hexIndexToCartesian(col, row, rad);
    lattice=0;
    drawmode=drawing_mode;
    setradius(rad);
  }
  void setradius(float rad) {
    radius=rad;
    v=radius/5.;
    q=radius/10.;
    d=radius/6.;
  }
  
  boolean draw(int layer) {
    if (trimOffPage &&
        (pos.x<lower_corner.x || pos.y<lower_corner.y || pos.x>upper_corner.x ||pos.y>upper_corner.y)) {return true;} //--> early exit
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-orientation*PI/3);
    boolean isFinished=true;
    switch(drawmode) {
      case DRAW_DEBUG:
      float oldradius=radius;
      setradius(radius*debug_radial_factor);
      isFinished=draw_debug(layer);
      setradius(oldradius);
      break;
      case DRAW_CURVE:
      isFinished=draw_style1(layer);
      break;
      case DRAW_SHAPE:
      isFinished=draw_shape(layer);
      break;
    }
    popMatrix();
    return isFinished;
  }
  
  boolean draw_shape(int layer) {
    colorMode(HSB,100);
    if (mirror>0 ^ hilow>0) {
      fill(int(60+random(10)),30,50);
    } else {
      fill(int(25+random(10)),30,70);
    }
    colorMode(RGB,255);
    stroke(shape_hexagon_stroke_color);
    strokeWeight(shape_hexagon_stroke_weight);
    return drawTile(layer);
  }

  boolean draw_style1(int layer) { 
    //fill((mirror>0)^(hilow>0)?200:100);
    stroke(0);
    strokeWeight(1);
    if (layer==0) drawHexagon();
    if (layer==2 && !((mirror>0)^(hilow>0))) hatchHexagon();

    noFill();
    stroke(0);
    strokeWeight(2);
    // main orientation
    if (layer==1 && orientation>=0) {
      {
        for(int i=2;i<6;i+=3) {
          pushMatrix();
          rotate(angularStep*i+PI);
          translate(0,radius);
          float arcradius=radius/2-v-q/2;
          rotate(-PI/6);
          arc(0,0,2*arcradius,2*arcradius,-2*angularStep ,0);
          popMatrix();
        }
      }
      
      if (hilow>=0) {
        PVector a1=new PVector();
        PVector c1=new PVector();
        PVector a2=new PVector();
        PVector c2=new PVector();
        for(int i=0;i<6;++i) {
          float vx=sin(angularStep*i+PI*hilow);
          float vy=cos(angularStep*i+PI*hilow);
          float cornerx=radius*vx;
          float cornery=radius*vy;
          vx=sin(angularStep*(i+0.5)+PI*hilow);
          vy=cos(angularStep*(i+0.5)+PI*hilow);
          float px=cornerx+vy*(((i==2)?radius/2+v:radius/2-v-q)+q/2);    
          float py=cornery-vx*(((i==2)?radius/2+v:radius/2-v-q)+q/2);
          switch (i) {
            case 4:
            float factor=.5;
            c1.x=cornerx*factor;c1.y=cornery*factor;
            c2.x=cornerx*factor;c2.y=cornery*factor;
            break;
            case 2:
            a1.x=px;a1.y=py;
            //c1.x=px+vy*radius;c1.y=py+vx*radius;
            break;
            case 5:
            a2.x=px;a2.y=py;
            //c2.x=px-vx*radius;c2.y=py-vy*radius;
            break;
          }
        }
        stroke(0);
        strokeWeight(2);
        bezier(a1.x,a1.y,c1.x,c1.y,c2.x,c2.y,a2.x,a2.y);
        noStroke();
      }
    }
    return layer>1;
  }
  
  boolean draw_debug(int layer) {
    switch(lattice) {
      case 0:
      noFill();
      break;
      case 1:
      fill(160);
      break;
      case 2:
      fill(160,255,255);
      break;
      case 3:
      fill(180,255,180);
      break;
      default:
      fill(255,255,160);
      break;
    }
    stroke(50);
    strokeWeight(1);
    if (layer==0) {
      drawHexagon();
    }
    stroke(0);
    strokeWeight(2);
    // main orientation
    if (orientation>=0) {
      if (layer==1) drawSmallTriangle();
      if (hilow>=0) {
         if (layer==2) drawBlackLine();
         if (layer==3) drawCrossLine();
         if (mirror>=0) {
            if (layer==3) drawRBLine();
         }
      }
      
    }
    if (layer==4) {
      fill(0);
      String s="";
      s+=(mirror>=0)?"-":"+";
      s+=(hilow>=0)?str(hilow):"?";
      s+=(orientation>=0)?str(orientation):"?";
      text(s,0,-radius/8);
      s=str(grid_col)+","+str(grid_row);
      text(s,0,radius/8);
      
      noFill();
    }
    return layer>3;
  }

  boolean drawTile(int layer)
  {
    pushMatrix();
    if (hilow>0) {rotate(PI);}
    beginShape();
    for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       vertex(cornerx,cornery);
       vx=sin(angularStep*(i+0.5));
       vy=cos(angularStep*(i+0.5));
       //float whichway=(i==0 || i==3 || i==5)?0:1;
       float whichway=(i==0 || i==2 || i==3)?0:1;
       float px=cornerx+vy*(radius/2-v-q*whichway);    
       float py=cornery-vx*(radius/2-v-q*whichway);
       vertex(px,py);
       px=px-vx*d;
       py=py-vy*d;
       vertex(px,py);
       px=px+vy*(2*v+q);
       py=py-vx*(2*v+q);
       vertex(px,py);
       px=px+vx*d;
       py=py+vy*d;
       vertex(px,py);
    }
    endShape(CLOSE);
  // Large paired rectangles
    for(int i=0;i<6;++i) {
       int mirrorflip=(mirror>0^hilow>0)?1:4;
       //float sign=(i==2 || i==5 || i==4)?-1:1;
       float sign=(i==mirrorflip || i==2 || i==5)?-1:1;
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       beginShape();
         vertex((radius+radius/2-v)*vx,       (radius+radius/2-v)*vy);
         vertex((radius+radius/2)*vx,         (radius+radius/2)*vy);
         vertex((radius+radius/2)*vx+d*vy*sign,(radius+radius/2)*vy-d*vx*sign);
         vertex((radius+radius/2-v)*vx+d*vy*sign,(radius+radius/2-v)*vy-d*vx*sign);
       endShape(CLOSE);
  
       beginShape();
         vertex((radius+radius/2+v)*vx,(radius+radius/2+v)*vy);
         vertex((radius+radius/2)*vx,(radius+radius/2)*vy);
         vertex((radius+radius/2)*vx-d*vy*sign,(radius+radius/2)*vy+d*vx*sign);
         vertex((radius+radius/2+v)*vx-d*vy*sign,(radius+radius/2+v)*vy+d*vx*sign);
       endShape(CLOSE);
    }
    // small interlocking rectangles
    for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       vx=sin(angularStep*(i+0.5));
       vy=cos(angularStep*(i+0.5));
       beginShape();
          //float px=cornerx+vy*((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q);    
          //float py=cornery-vx*((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q);
          float px=cornerx+vy*((i==0 || i==2 || i==3)?radius/2+v:radius/2-v-q);    
          float py=cornery-vx*((i==0 || i==2 || i==3)?radius/2+v:radius/2-v-q);
          vertex(px,py);
          px=px+vx*d;
          py=py+vy*d;
          vertex(px,py);
          px=px+vy*q;
          py=py-vx*q;
          vertex(px,py);
          px=px-vx*d;
          py=py-vy*d;
          vertex(px,py);
       endShape(CLOSE);
    }
  
    stroke(shape_triangle_stroke_color);
    strokeWeight(shape_triangle_stroke_weight);
    // Draw the triangle lines that have to join up
    //
     float pxcase2=0;
     float pycase2=0;
     for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       vx=sin(angularStep*(i+0.5));
       vy=cos(angularStep*(i+0.5));
       //float px=cornerx+vy*(((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q)+q/2);    
       //float py=cornery-vx*(((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q)+q/2);
       float px=cornerx+vy*(((i==0 || i==2 || i==3)?radius/2+v:radius/2-v-q)+q/2);    
       float py=cornery-vx*(((i==0 || i==2 || i==3)?radius/2+v:radius/2-v-q)+q/2);
       line(px,py,px+vx*d,py+vy*d);
       px-=vx*d;
       py-=vy*d;
       switch (i) {
         case 0:
         case 1:
         case 3:
         case 4:
         line(px,py,px-vx*radius/3,py-vy*radius/3);
         break;
         case 2:
         pxcase2=px;
         pycase2=py;
         break;
         case 5:
         line(pxcase2,pycase2,px,py);
         break;
       }
     }
         
    if (shape_draw_arrowhead) {
      float arrowlength=radius/2;
      float headlength=radius/6;
      float vx=sin(0);
      float vy=cos(0);
      float toparrowx=arrowlength/2*vx;
      float toparrowy=arrowlength/2*vy;
      line(-arrowlength/2*vx,-arrowlength/2*vy,
      toparrowx,toparrowy);
      line(toparrowx,toparrowy,toparrowx-headlength*sin(PI/6),toparrowy-headlength*cos(PI/6));
      line(toparrowx,toparrowy,toparrowx-headlength*sin(-PI/6),toparrowy-headlength*cos(-PI/6));
    }
    popMatrix();
    return true;
  }
  
  void drawHexagon()
  {
    beginShape();
    for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       vertex(cornerx,cornery);
    }
    endShape(CLOSE);
  }
  
  void hatchHexagon()
  {
    PVector[] points=new PVector[6];
    for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       points[i]=new PVector(cornerx, cornery);
    }
    hatchPoly(points,angularStep+PI/6,radius/7);
  }
  
  void drawSmallTriangle()
  {
    // Draw the triangle lines that have to join up
    //
     for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i);
       float vy=cos(angularStep*i);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       vx=sin(angularStep*(i+0.5));
       vy=cos(angularStep*(i+0.5));
       float px=cornerx+vy*(((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q)+q/2);    
       float py=cornery-vx*(((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q)+q/2);
       switch (i) {
         case 0:
         case 1:
         case 3:
         case 4:
         line(px,py,px-vx*radius/3,py-vy*radius/3);
         break;
       }
     }
         
  }
  
  void drawBlackLine()
  {
    // Draw the triangle lines that have to join up
    //
     float pxcase2=0;
     float pycase2=0;
     for(int i=0;i<6;++i) {
       float vx=sin(angularStep*i+PI*hilow);
       float vy=cos(angularStep*i+PI*hilow);
       float cornerx=radius*vx;
       float cornery=radius*vy;
       vx=sin(angularStep*(i+0.5)+PI*hilow);
       vy=cos(angularStep*(i+0.5)+PI*hilow);
       float px=cornerx+vy*(((i==2)?radius/2+v:radius/2-v-q)+q/2);    
       float py=cornery-vx*(((i==2)?radius/2+v:radius/2-v-q)+q/2);
       switch (i) {
         case 0:
         case 1:
         case 3:
         case 4:
         //line(px,py,px-vx*radius/3,py-vy*radius/3);
         break;
         case 2:
         pxcase2=px;
         pycase2=py;
         break;
         case 5:
         line(pxcase2,pycase2,px,py);
         break;
       }
     }
  }

  void drawCrossLine()
  {
     {
        stroke(255,0,0);
        float vx=sin(angularStep*2);
        float vy=cos(angularStep*2);
        line(radius*vx,radius*vy,-radius*vx,-radius*vy);
     }
     {
       stroke(0,0,255);
       float vx=sin(angularStep*3);
       float vy=cos(angularStep*3);
       line(radius*vx,radius*vy,-radius*vx,-radius*vy);
     }
  }
  void drawRBLine()
  {
     float vx=sin(angularStep);
     float vy=cos(angularStep);
     float flip=(0.5-hilow)*2;
     {
        stroke(0,255,0);
        line(0,0,-radius*vx*flip,-radius*vy*flip);
     }
     {
       stroke(255,0,255);
       line(0,0,radius*vx*flip,radius*vy*flip);
     }
  }
};

// The following applies the constraints to set of tiles (in a hex grid)
// Very limited error checking is done, warnings are printed if inconsistency found
// returns the number of tiles changed.
// This function is expected to be applied iteratively until the number of tiles changed 
// is zero.
int applyConstraints(Tile[][] tiles) {
  int Nrows=tiles.length;
  int Ncols=tiles[0].length;
  int changed=0;
  for(int r=0;r<Nrows;++r) {
    for(int c=0;c<Ncols;++c) {
      int nr,nc;
      // Try to solve for hilow
      if (tiles[r][c].hilow<0) {
        switch(tiles[r][c].orientation) {
          case 0:
          nr=r-1;nc=c+1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            //println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
            if (tiles[nr][nc].orientation==tiles[r][c].orientation && tiles[nr][nc].hilow>=0) {tiles[r][c].hilow=tiles[nr][nc].hilow; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].hilow=0; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].hilow=1; changed+=1;}
          }
          nr=r+1;nc=c-1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            if (tiles[nr][nc].orientation==tiles[r][c].orientation && tiles[nr][nc].hilow>=0) {tiles[r][c].hilow=tiles[nr][nc].hilow; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].hilow=1; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].hilow=0; changed+=1;}
          }
          break;
          case 1:
          nr=r-1;nc=c;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            //println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
            if (tiles[nr][nc].orientation==tiles[r][c].orientation && tiles[nr][nc].hilow>=0) {tiles[r][c].hilow=tiles[nr][nc].hilow; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].hilow=0; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].hilow=1; changed+=1;}
            //if (tiles[r][c].hilow>=0) {
            //   println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
            //   println("Hilow changed ",r,", ",c," to ",tiles[r][c].hilow);
            // }
          }
          nr=r+1;nc=c;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            if (tiles[nr][nc].orientation==tiles[r][c].orientation && tiles[nr][nc].hilow>=0) {tiles[r][c].hilow=tiles[nr][nc].hilow; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].hilow=1; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].hilow=0; changed+=1;}
            //if (tiles[r][c].hilow>=0) {
            //   println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
            //   println("Hilow changed ",r,", ",c," to ",tiles[r][c].hilow);
            // }
          }
          break;
          case 2:
          nr=r;nc=c+1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            //println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
            if (tiles[nr][nc].orientation==tiles[r][c].orientation && tiles[nr][nc].hilow>=0) {tiles[r][c].hilow=tiles[nr][nc].hilow; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].hilow=1; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].hilow=0; changed+=1;}
          }
          nr=r;nc=c-1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            if (tiles[nr][nc].orientation==tiles[r][c].orientation && tiles[nr][nc].hilow>=0) {tiles[r][c].hilow=tiles[nr][nc].hilow; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].hilow=0; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].hilow=1; changed+=1;}
          }
          break;
        }
        //if (tiles[r][c].hilow>=0) {println("Changed ",r,", ",c," to ",tiles[r][c].hilow);}
       
      }
      // Try to solve for the mirror
      if (tiles[r][c].mirror<0) {
        switch(tiles[r][c].orientation) {
          case 0:
          nr=r-1;nc=c-1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            int original=tiles[r][c].mirror;
            if (tiles[nr][nc].orientation==0 && tiles[nr][nc].mirror>=0 ) {tiles[r][c].mirror=tiles[nr][nc].mirror; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].mirror=0; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].mirror=1; changed+=1;}
            if (original >=0 && tiles[r][c].mirror!=original) {
               println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
               println("Mirror changed ",r,", ",c," to ",tiles[r][c].mirror);
               return -1;
             }
          }
          nr=r+1;nc=c+1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            int original=tiles[r][c].mirror;
            if (tiles[nr][nc].orientation==0 && tiles[nr][nc].mirror>=0 ) {tiles[r][c].mirror=tiles[nr][nc].mirror; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].mirror=1; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].mirror=0; changed+=1;}
            if (original >=0 && tiles[r][c].mirror!=original) {
               println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
               println("Mirror changed ",r,", ",c," to ",tiles[r][c].mirror);
               return -1;
             }
          }
          break;
          case 1:
          nr=r-1;nc=c+2;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            int original=tiles[r][c].mirror;
            if (tiles[nr][nc].orientation==1 && tiles[nr][nc].mirror>=0 ) {tiles[r][c].mirror=tiles[nr][nc].mirror; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].mirror=0; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].mirror=1; changed+=1;}
            if (original >=0 && tiles[r][c].mirror!=original) {
               println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
               println("Mirror changed ",r,", ",c," to ",tiles[r][c].mirror);
               return -1;
             }
          }
          nr=r+1;nc=c-2;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            int original=tiles[r][c].mirror;
            if (tiles[nr][nc].orientation==1 && tiles[nr][nc].mirror>=0 ) {tiles[r][c].mirror=tiles[nr][nc].mirror; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].mirror=1; changed+=1;}
            if (tiles[nr][nc].orientation==2 ) {tiles[r][c].mirror=0; changed+=1;}
            if (original >=0 && tiles[r][c].mirror!=original) {
               println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
               println("Mirror changed ",r,", ",c," to ",tiles[r][c].mirror);
               return -1;
             }
          }
          break;
          case 2:
          nr=r-2;nc=c+1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            int original=tiles[r][c].mirror;
            if (tiles[nr][nc].orientation==2 && tiles[nr][nc].mirror>=0 ) {tiles[r][c].mirror=tiles[nr][nc].mirror; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].mirror=1; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].mirror=0; changed+=1;}
            if (original >=0 && tiles[r][c].mirror!=original) {
               println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
               println("Mirror changed ",r,", ",c," to ",tiles[r][c].mirror);
               return -1;
             }
          }
          nr=r+2;nc=c-1;
          if      (nr>0 && nc>0 && nr<Nrows && nc < Ncols) {
            int original=tiles[r][c].mirror;
            if (tiles[nr][nc].orientation==2 && tiles[nr][nc].mirror>=0 ) {tiles[r][c].mirror=tiles[nr][nc].mirror; changed+=1;}
            if (tiles[nr][nc].orientation==0 ) {tiles[r][c].mirror=0; changed+=1;}
            if (tiles[nr][nc].orientation==1 ) {tiles[r][c].mirror=1; changed+=1;}
            if (original >=0 && tiles[r][c].mirror!=original) {
               println(r,c,nr,nc,tiles[r][c].grid_col,tiles[r][c].grid_row,tiles[nr][nc].grid_col,tiles[nr][nc].grid_row);
               println("Mirror changed ",r,", ",c," to ",tiles[r][c].mirror);
               return -1;
             }
          }
          break;
        }
      }
    }
  }
  return changed;
}

void shift_to_middle(Tile[][] tiles)
{
  int Nrows=tiles.length;
  int Ncols=tiles[0].length;
  int midrows=int(Nrows/2);
  int midcols=int(Ncols/2);
  
  float ctrx=(
    tiles[midrows][midcols].pos.x
    +tiles[midrows+Nrows%2][midcols].pos.x
    +tiles[midrows][midcols+Ncols%2].pos.x
    +tiles[midrows+Nrows%2][midcols+Ncols%2].pos.x
             )/4.;
  float ctry=(
    tiles[midrows][midcols].pos.y
    +tiles[midrows+Nrows%2][midcols].pos.y
    +tiles[midrows][midcols+Ncols%2].pos.y
    +tiles[midrows+Nrows%2][midcols+Ncols%2].pos.y
             )/4.;
  translate(width/2-ctrx,height/2-ctry);
  
  lower_corner.x=radius-width/2+ctrx;
  lower_corner.y=radius-height/2+ctry;
  upper_corner.x=width-radius-width/2+ctrx;
  upper_corner.y=height-radius-height/2+ctry;

}

void draw() {
  if (makePDF) { beginRecord(PDF, pdf_file_name); }
  Tile[][] tiles;
  
  if (showTileVariants) {
    // override these
    radius=40;
    Ncols=3;
    Nrows=4;
    
    tiles=new Tile[Nrows][Ncols];
    for(int r=0;r<Nrows;++r) {
      for(int c=0;c<Ncols;++c) {
        tiles[r][c]=new Tile(c*2,r*2,radius);
        tiles[r][c].orientation=c;
        tiles[r][c].hilow=r%2;
        tiles[r][c].mirror=int(r>1);
      }
    }
   
  } else {
  
    tiles=new Tile[Nrows][Ncols];
    for(int r=0;r<Nrows;++r) {
      for(int c=0;c<Ncols;++c) {
        tiles[r][c]=new Tile(c,r,radius);
      }
    }
    
    // First layout small triangle lattice
    for(int r=0;r<Nrows;++r) {
      for(int c=0;c<Ncols;++c) {
         if (r%2==0) {
           if (c%2==1) { 
             tiles[r][c].orientation = 1;
           } else {
             tiles[r][c].orientation = 0;
           }
           tiles[r][c].lattice=1;
         } else {
           if (c%2==0) { 
             tiles[r][c].orientation = 2;
             tiles[r][c].lattice=1;
           } 
         }
      }
    }
    // Secondary lattices
    { 
      int lattice=2;
      int changedcount=-1;
      int step=2;
      while (changedcount!=0) {
        changedcount=0;
    
        for(int r=0;r<=Nrows/2;++r) {
          for(int c=0;c<=Ncols/2;++c) {
            int rr=r*step+step-1;
            int cc=c*step+1;//r%2;
            if (rr>=Nrows || cc>=Ncols) {continue;} 
            if (r%2==0) {
               if (c%2==r%2) {
                 tiles[rr][cc].orientation = 1;
               } else {
                 tiles[rr][cc].orientation = 0;
               }
               changedcount+=1;
               tiles[rr][cc].lattice=lattice;
            } else {
               if (c%2==r%2) {
                 tiles[rr][cc].orientation = 2;
                 tiles[rr][cc].lattice=lattice;
                 changedcount+=1;
               } 
            }
          }
        }
        lattice+=1;
        step*=2;
      }
    }
  }   
  
  for (boolean flag=true; flag; ) {
    // Apply constraints iteratively
    int changed=1;
    for(; changed>0; changed=applyConstraints(tiles));
    if (changed <0) break; /// error flag
  
    // if after all constraints applied, there are still ambiguous tiles
    // flip the hilow randomly of one, and resolve
    flag=false;
    for(int r=0;r<Nrows && !flag;++r) {
      for(int c=0;c<Ncols && !flag;++c) {
         if (tiles[r][c].hilow == -1) {
           tiles[r][c].hilow=int(random(2));
           //println("Flipping ambiguous tile ",r," ",c," to ",tiles[r][c].hilow);
           flag=true;
         }
      }
    }
  }
 
 int layer=0;
 for (boolean finished=false; !finished;) {
   finished=true;
   if (makeSVG) { beginRecord(SVG, svg_file_prefix+"_"+str(layer)+".svg"); }
   pushMatrix();
   shift_to_middle(tiles);
   for(int r=0;r<Nrows;++r) {
      for(int c=0;c<Ncols;++c) {
        boolean result=tiles[r][c].draw(layer);
        finished=finished && result;
      }
   }
   popMatrix();
   if (makeSVG) { endRecord();}
   layer++;
 }
  
  if (makePNG) { save(png_file_name); }
  if (makePDF) { endRecord();  }
  println("Finished.");
}
