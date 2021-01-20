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
  background(255);//150);
  stroke(0);
  noFill();
  noLoop();
}

void drawTile(float x,float y,float radius, float orient)
{
  float angularStep=PI/3;
  float v=radius/5.;
  float q=radius/10.;
  float d=radius/6.;
  beginShape();
  for(int i=0;i<6;++i) {
     float vx=sin(orient+angularStep*i+PI);
     float vy=cos(orient+angularStep*i+PI);
     float cornerx=x+radius*vx;
     float cornery=y+radius*vy;
     vertex(cornerx,cornery);
     vx=sin(orient+angularStep*(i+0.5)+PI);
     vy=cos(orient+angularStep*(i+0.5)+PI);
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
     //float sign=(i==2 || i==5 || i==4)?-1:1;
     float sign=(i==1 || i==2 || i==5)?-1:1;
     float vx=sin(orient+angularStep*i+PI);
     float vy=cos(orient+angularStep*i+PI);
     beginShape();
       vertex(x+(radius+radius/2-v)*vx,y+(radius+radius/2-v)*vy);
       vertex(x+(radius+radius/2)*vx,y+(radius+radius/2)*vy);
       vertex(x+(radius+radius/2)*vx+d*vy*sign,y+(radius+radius/2)*vy-d*vx*sign);
       vertex(x+(radius+radius/2-v)*vx+d*vy*sign,y+(radius+radius/2-v)*vy-d*vx*sign);
     endShape(CLOSE);

     beginShape();
       vertex(x+(radius+radius/2+v)*vx,y+(radius+radius/2+v)*vy);
       vertex(x+(radius+radius/2)*vx,y+(radius+radius/2)*vy);
       vertex(x+(radius+radius/2)*vx-d*vy*sign,y+(radius+radius/2)*vy+d*vx*sign);
       vertex(x+(radius+radius/2+v)*vx-d*vy*sign,y+(radius+radius/2+v)*vy+d*vx*sign);
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
}

void drawHexagon(float x,float y,float radius, float orient)
{
  orient=orient+PI/3;
  float angularStep=PI/3;
  float v=radius/5.;
  float q=radius/10.;
  float d=radius/6.;
  beginShape();
  for(int i=0;i<6;++i) {
     float vx=sin(orient+angularStep*i+PI);
     float vy=cos(orient+angularStep*i+PI);
     float cornerx=x+radius*vx;
     float cornery=y+radius*vy;
     vertex(cornerx,cornery);
     //vx=sin(orient+angularStep*(i+0.5)+PI);
     //vy=cos(orient+angularStep*(i+0.5)+PI);
     //float whichway=(i==0 || i==3 || i==5)?0:1;
     //float px=cornerx+vy*(radius/2-v-q*whichway);    
     //float py=cornery-vx*(radius/2-v-q*whichway);
     //vertex(px,py);
     //px=px-vx*d;
     //py=py-vy*d;
     //vertex(px,py);
     //px=px+vy*(2*v+q);
     //py=py-vx*(2*v+q);
     //vertex(px,py);
     //px=px+vx*d;
     //py=py+vy*d;
     //vertex(px,py);
  }
  endShape(CLOSE);

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
    // line(px,py,px+vx*d,py+vy*d);
     //px-=vx*d;
     //py-=vy*d;
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
  float angle=orient-PI/3;
  float vx=sin(angle+PI);
  float vy=cos(angle+PI);
  float toparrowx=x+arrowlength/2*vx;
  float toparrowy=y+arrowlength/2*vy;
  line(x-arrowlength/2*vx,y-arrowlength/2*vy,
  toparrowx,toparrowy);
  line(toparrowx,toparrowy,toparrowx+headlength*sin(angle+PI/6),toparrowy+headlength*cos(angle+PI/6));
  line(toparrowx,toparrowy,toparrowx+headlength*sin(angle-PI/6),toparrowy+headlength*cos(angle-PI/6));
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

void draw()
{
  if (makePDF) {
    beginRecord(PDF, "SocolarTaylor.pdf"); 
  }
  float radius=50;//30;
  stroke(88);
  //for(int row=-5;row<6;++row) {
  //  for(int col=-4;col<5;++col) {
  //    Point pos=hexIndexToCartesian(col, row, radius);
  //    if (row%2==0) {
  //       drawHexagon(pos.x+width/2,pos.y+height/2,radius*0.97,(col%2)*PI/3);
  //    }
  //  }
 // }
 
 
  int[][] pattern =
  { 
    { 5 , 0 , 5 , 5 , 5 , 5 ,  5, 5, 5},
    { 40 , 9, 10, 9, 40, 9, 40, 9, 40},
    { 9, 50, 10, 20, 9, 50, 40, 20, 30},
    { 9, 10, 30 , 10, 9 , 10,  30, 40,30},
    { 50 , 50 , 50 , 10, 20 , 20,  20,30, 50},
    { 9 , 40 , 30 , 10 , 9, 40, 30, 10, 9},
    { 10 , 20 , 30 , 50 , 10 , 20 , 30, 50,10},
    { 10 , 30 , 10 , 30 , 10 , 30 ,  10, 30, 10},
    { 20 , 20 , 20 , 20 , 20 , 20 ,  20,20, 20}
  };
    //int[][] pattern= {
    //  {0,-1,1,-1,2},{-1,-1,-1,-1,-1},{3,-1,4,-1,5}};
  int NY=pattern.length;
  int NX=pattern[0].length;
  for (int i=0;i<NX;++i) {
    for (int j=0;j<NY;++j) {
      int tile=pattern[j][i];
      int strokecolor=color(50,50,255);

      strokeWeight(1);
      if (tile>8) {
        tile=tile/10;
        strokecolor=color(0,0,0);
        strokeWeight(2);
      }
      stroke(strokecolor);
      if (tile < 0) {continue;}
      switch(tile){
        case 0:
          //fill(0);
          fill(255,0,0,96);
          //fill(128,100,100,96);
          break;
        case 1:
//          stroke(0);
          fill(0,255,0,96);
          //fill(100,128,100,96);
          break;
        case 2:
  //        stroke(0);
          fill(0,0,255,96);
          //fill(100,100,128,96);
          break;
        case 3:
    //      stroke(0);
          fill(0,0,0,96);
          //fill(128,128,100,96);
          break;
        case 4:
      //    stroke(0);
          fill(255,255,0,96);
          //fill(128,100,128,96);
          break;
        case 5:
        //  stroke(0);
          fill(0,255,255,96);
          //fill(128,100,100,96);
          break;
      }
      Point pos=hexIndexToCartesian(i-int(NX/2), j-int(NY/2), radius);
      drawTile(pos.x+width/2,pos.y+height/2,radius,tile*PI/3);
    }
  }
  
     // fill(256,0,0,96);
     // drawTile(-1*sqrt(3)*radius*3+width/2,0+height/2,radius*3,0);
     // fill(0,256,0,96);
     // drawTile(0+width/2,0+height/2,radius*3,0);
  //fill(100,128,100,128);
  //pos=hexIndexToCartesian(-1, 1, radius);
  //drawTile(pos.x+width/2,pos.y+height/2,radius,F);
  
  //drawTile(50,75,100,0);
  //drawTile(300,400,125,PI/12);
  
  if(makePDF) {
     endRecord();
     // no display version
     // Exit the program 
     println("Finished.");
     exit();
  }
}
