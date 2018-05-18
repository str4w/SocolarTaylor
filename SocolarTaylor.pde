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
  pushMatrix();
  translate(x,y);
  scale(radius);
  rotate(orient+PI);
  float angularStep=PI/3;
  float v=1./5.;
  float q=1.10.;
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
       vertex((1+1./2-v)*vx,(1+1./2-v)*vy);
       vertex((1+1./2)*vx,(1+1./2)*vy);
       vertex((1+1./2)*vx+d*vy*sign,(1+1./2)*vy-d*vx*sign);
       vertex((1+1./2-v)*vx+d*vy*sign,(1+1./2-v)*vy-d*vx*sign);
     endShape(CLOSE);

     beginShape();
       vertex((1+1./2+v)*vx,(1+1./2+v)*vy);
       vertex((1+1./2)*vx,(1+1./2)*vy);
       vertex((1+1./2)*vx-d*vy*sign,y+(1+1./2)*vy+d*vx*sign);
       vertex((1+1./2)+v)*vx-d*vy*sign,y+(1+1./2+v)*vy+d*vx*sign);
     endShape(CLOSE);
  }
  // small interlocking rectangles
  for(int i=0;i<6;++i) {
     float vx=sin(orient+angularStep*i+PI);
     float vy=cos(orient+angularStep*i+PI);
     float cornerx=x+radius*vx;
     float cornery=y+radius*vy;
     vx=sin(orient+angularStep*(i+0.5)+PI);
     vy=cos(orient+angularStep*(i+0.5)+PI);
     beginShape();
        float px=cornerx+vy*((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q);    
        float py=cornery-vx*((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q);
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
     float vx=sin(orient+angularStep*i+PI);
     float vy=cos(orient+angularStep*i+PI);
     float cornerx=x+radius*vx;
     float cornery=y+radius*vy;
     vx=sin(orient+angularStep*(i+0.5)+PI);
     vy=cos(orient+angularStep*(i+0.5)+PI);
     float px=cornerx+vy*(((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q)+q/2);    
     float py=cornery-vx*(((i==0 || i==3 || i==5)?radius/2+v:radius/2-v-q)+q/2);
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
       

  float arrowlength=radius/2;
  float headlength=radius/6;
  float vx=sin(orient+PI);
  float vy=cos(orient+PI);
  float toparrowx=x+arrowlength/2*vx;
  float toparrowy=y+arrowlength/2*vy;
  line(x-arrowlength/2*vx,y-arrowlength/2*vy,
  toparrowx,toparrowy);
  line(toparrowx,toparrowy,toparrowx+headlength*sin(orient+PI/6),toparrowy+headlength*cos(orient+PI/6));
  line(toparrowx,toparrowy,toparrowx+headlength*sin(orient-PI/6),toparrowy+headlength*cos(orient-PI/6));
  // make the arrow chiral, so we can see the reflection
  line(toparrowx+headlength*sin(orient-PI/6),toparrowy+headlength*cos(orient-PI/6), toparrowx+headlength*sin(orient)*cos(PI/6),toparrowy+headlength*cos(orient)*cos(PI/6) );
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
  drawTile(pos.x+width/2,pos.y+height/2,radius,PI/3*2);
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
  drawTileAtHexIndex(0,1,radius,PI/3/2);
  drawTileAtHexIndex(1,0,radius,PI/3/2);
  
  if(makePDF) {
     endRecord();
     // no display version
     // Exit the program 
     println("Finished.");
     exit();
  }
}
