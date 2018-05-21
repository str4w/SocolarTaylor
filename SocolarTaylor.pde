// Based on the friendly challenge here
// https://twitter.com/josephgentle/status/996194616738172928
// referring to
// https://twitter.com/nattyover/status/996087380959485952
// information on this tiling
// https://en.wikipedia.org/wiki/Socolar%E2%80%93Taylor_tile
// https://arxiv.org/PS_cache/arxiv/pdf/1003/1003.4279v1.pdf

import processing.pdf.*;
boolean makePDF=false;

void setup()
{
  size(1000,1000,P3D);
  background(150);
  stroke(0);
  noFill();
  noLoop();
}

void setFillToRandomPastel() {
   fill(50+int(random(10))*10,50+int(random(10))*10,50+int(random(10))*10);
}

void drawTile(float x,float y,float radius, float orient)
{
  float tempStrokeWeight=g.strokeWeight;
  pushMatrix();
  translate(x,y);
  scale(radius);
  rotate(orient+PI);
  strokeWeight(tempStrokeWeight/radius);
  float angularStep=PI/3;
  float v=1./5.;
  float q=1./10.;
  float d=1./6.;
  beginShape();
  for(int i=0;i<6;++i) {
     float vx=sin(angularStep*i);
     float vy=cos(angularStep*i);
     float cornerx=vx;
     float cornery=vy;
     vertex(cornerx,cornery);
     vx=sin(angularStep*(i+0.5));
     vy=cos(angularStep*(i+0.5));
     float whichway=(i==0 || i==3 || i==5)?0:1;
     float px=cornerx+vy*(1./2.-v-q*whichway);    
     float py=cornery-vx*(1./2.-v-q*whichway);
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
     float sign=(i==2 || i==5 || i==4)?-1:1;
     float vx=sin(angularStep*i);
     float vy=cos(angularStep*i);
     beginShape();
       vertex((1.5-v)*vx,(1.5-v)*vy);
       vertex(1.5*vx,1.5*vy);
       vertex(1.5*vx+d*vy*sign,1.5*vy-d*vx*sign);
       vertex((1.5-v)*vx+d*vy*sign,(1.5-v)*vy-d*vx*sign);
     endShape(CLOSE);

     beginShape();
       vertex((1.5+v)*vx,(1.5+v)*vy);
       vertex(1.5*vx,1.5*vy);
       vertex(1.5*vx-d*vy*sign,1.5*vy+d*vx*sign);
       vertex((1.5+v)*vx-d*vy*sign,(1.5+v)*vy+d*vx*sign);
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
     line(px,py,px+vx*d,py+vy*d);
     px-=vx*d;
     py-=vy*d;
     switch (i) {
       case 0:
       case 1:
       case 3:
       case 4:
       line(px,py,px-vx/3.,py-vy/3.);
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
    

  float arrowlength=1./2.;
  float headlength=1./6.;
  //float vx=sin(orient+PI);
  //float vy=cos(orient+PI);
  float toparrowx=0;//x+arrowlength/2*vx;
  float toparrowy=-arrowlength/2.;//y+arrowlength/2*vy;
  line(0,arrowlength/2,
  toparrowx,toparrowy);
  line(toparrowx,toparrowy,toparrowx+headlength*sin(PI/6),toparrowy+headlength*cos(PI/6));
  line(toparrowx,toparrowy,toparrowx+headlength*sin(-PI/6),toparrowy+headlength*cos(-PI/6));
  // make the arrow chiral, so we can see the reflection
  line(toparrowx+headlength*sin(-PI/6),toparrowy+headlength*cos(-PI/6), toparrowx,toparrowy+headlength*cos(PI/6) );
  popMatrix();
  strokeWeight(tempStrokeWeight);
}
class Point
{
  Point()
  {
    x=0;
    y=0;
  }
  public  float x,y;
};
Point hexIndexToCartesian(int column, int row, float radius)
{
  Point pos=new Point();
  pos.x=(column+(row%2)/2.0)*radius*sqrt(3);
  pos.y=row*radius*1.5;
  return pos;
}
void drawTileAtHexIndex(int hex1,int hex2, float radius, float orientation)
{
  setFillToRandomPastel();
  Point pos=hexIndexToCartesian(hex1, hex2, radius);
  drawTile(pos.x+width/2,pos.y+height/2,radius,orientation);
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
  drawTileAtHexIndex(0,0,radius,0);
  drawTileAtHexIndex(0,1,radius,2*PI/3);
  drawTileAtHexIndex(1,0,radius,4*PI/3);
  
  if(makePDF) {
     endRecord();
     // no display version
     // Exit the program 
     println("Finished.");
     exit();
  }
}
