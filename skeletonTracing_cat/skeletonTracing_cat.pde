import java.io.*;
import java.lang.reflect.*;
import java.lang.*;
import java.awt.geom.AffineTransform;
import java.util.*;

import traceskeleton.*;

import processing.video.*;

int scl = 3;

PGraphics pg;
ArrayList<ArrayList<int[]>>  c;
ArrayList<int[]> rects = new ArrayList<int[]>();
boolean[]  im;
int W = 300;
int H = 169;
PImage img;

// videos, the original, and the back pic
Movie mov;
Movie mov2;

// BOOLEANS FOR KEYS ON/OFF, MODES, ...
boolean gui=true;
boolean backPic=false;
boolean originalVid=true;
boolean rectss=false; // rects matrix On Off
boolean skeleton=true;


float [] skelX = new float [200]; // arrays to copy the skel pos
float [] skelY = new float [200];

float [] slowX = new float [200]; // smoother version skel pos
float [] slowY = new float [200];

// particles XY
int nr= 50;
float [] xx = new float [nr]; 
float [] yy = new float [nr];
float [] raio = new float [nr];
float [] velX = new float [nr]; 
float [] velY = new float [nr];
float posNoise=1.0;

int mode=0; // vizz mode

void setup() {
  size(900, 507);
  
  mov = new Movie(this, "cat_BW.mp4");
  mov.loop();

  mov2 = new Movie(this, "cat_original.mp4");
  mov2.loop();

  pg = createGraphics(W, H);
  pg.beginDraw();
  pg.background(0);
  pg.image(mov, 0, 0);
  pg.endDraw();

  im = new boolean[W*H];
  
  // start particles pos
 for(int i=0;i<nr;i++){  
   xx[i]=random(0,width);
   yy[i]=random(0,height);
   raio[i]=random(5,10);
   velX[i]=random(-3.5,-1);
   velY[i]=random(-1.5,1.5);   
 }
}
void draw() {
  background(0);

  // Image that will be checked to trace the Skeleton
  pg.beginDraw();
  pg.noFill();
  pg.strokeWeight(10);
  pg.stroke(255);
  //pg.line(pmouseX/scl, pmouseY/scl, mouseX/scl,mouseY/scl);
  pg.image(mov, 0, 0);
  pg.loadPixels();

  // CHECKS Image Pixels. Checks for wite pixels. And TraceSkeleton on white Areas  
  for (int i = 0; i < im.length; i++) {
    im[i] = (pg.pixels[i]>>16&0xFF)>128;
  }
  TraceSkeleton.thinningZS(im, W, H);
  pg.endDraw();
  pg.updatePixels(); // only need this on videos. Not with still images

  // Rect Areas withting the sketleton
  rects.clear();
  c = TraceSkeleton.traceSkeleton(im, W, H, 0, 0, W, H, 10, 999, rects);

  //// Show Skeletized image under the skeleton
  pushMatrix();
  scale(scl);
  tint(255, 100);
  if (backPic) image(pg, 0, 0);
  popMatrix();
 ////// 
 
  // RECTS 
  if (rectss) {
    noFill(); 
    for (int i = 0; i < rects.size(); i++) {
      stroke(255, 0, 0);
      rect(rects.get(i)[0]*scl, rects.get(i)[1]*scl, rects.get(i)[2]*scl, rects.get(i)[3]*scl);
    }
  } 

  strokeWeight(1);
  noFill();
  int counter=0; // counting the nr of points on each skeleton

  for (int i = 0; i < c.size(); i++) {
    stroke(255, 0, 0);
    beginShape();
    for (int j = 0; j < c.get(i).size(); j++) {

      if (skeleton) {
        //Draw Skeleton
        stroke(255);
        noFill();
        vertex(c.get(i).get(j)[0]*scl, c.get(i).get(j)[1]*scl);   // AQUI ESTÃO OS PONTOS
        rect(c.get(i).get(j)[0]*scl-2, c.get(i).get(j)[1]*scl-2, 4, 4); 

      }
      
      float x= c.get(i).get(j)[0]*scl-2;
      float y= c.get(i).get(j)[1]*scl-2;

      skelX[counter]=x; // arrays to store skel X Y
      skelY[counter]=y;

    slowX[counter]+=(skelX[counter]-slowX[counter])*0.1;
    slowY[counter]+=(skelY[counter]-slowY[counter])*0.1;

      counter++; // counts the number of points
    }
    endShape();
  }


////////////////// MODE 1
  if (mode==1) {
    stroke(255);
    for (int i=0; i<counter; i++) {      
      line (skelX[i], skelY[i], map(skelX[i], 0, width, (width/2)-100, (width/2)+100), 0);
      line (skelX[i], skelY[i], map(skelX[i], 0, width, (width/2)-100, (width/2)+100), height);
    }
  }

////////////////// MODE 2
  if (mode==2) {
    stroke(255);
    for (int i=0; i<counter; i++) {     
      line (skelX[i], skelY[i], skelX[i],height/2);     
    }
  }
  
  ////////////////// MODE 3
  if (mode==3) {
    stroke(255);
    for (int i=0; i<counter; i++) { 
      if(skelY[i]<=height/2)line (skelX[i], skelY[i], skelX[i],0);
      else line (skelX[i], skelY[i], skelX[i],height);
           
    }
  }
  


  ////////////////// MODE 4
  if (mode==4) {    
    for (int i=0; i<counter; i++) { 
     // fill(255);
      stroke(255);
      if(skelY[i]<height/2) line(skelX[i],skelY[i], skelX[i], skelY[i]-100);   
      else line(skelX[i],skelY[i], skelX[i], skelY[i]+100);        
    }    
  }
  
    ////////////////// MODE 5
  if (mode==5) {    
    for (int i=0; i<counter; i++) { 
     // fill(255);
      stroke(255);
      if(slowX[i]<width/2) {
        line(slowX[i],slowY[i], width/2, slowY[i]); 
        line(width/2+(width/2-slowX[i]),slowY[i], width/2, slowY[i]);
        fill(255);
        noStroke();
        ellipse(slowX[i],slowY[i],5,5);
        ellipse(width/2+(width/2-slowX[i]),slowY[i],5,5);
      }
    }    
  }
  
     ////////////////// MODE 6
  if (mode==6) {    
    for (int i=0; i<counter; i++) { 
     // fill(255);
      stroke(255);
      if(slowY[i]<height/2) {
        line(slowX[i],slowY[i], slowX[i], height/2); 
        line(slowX[i],height/2+(height/2-slowY[i]), slowX[i], height/2); 
        fill(255);
        noStroke();
        ellipse(slowX[i],slowY[i],5,5);
        ellipse(slowX[i],height/2+(height/2-slowY[i]),5,5);
      }
    }    
  }

  ////////////////// MODE 7
  if (mode==7) {
    
    //skeleton=false;
    
    posNoise = posNoise + .05;
   
    for(int i=0;i<nr;i++){
      fill(255);
      noStroke();
      ellipse(xx[i],yy[i],raio[i],raio[i]);
      
      //move Particles
      xx[i]=xx[i]+velX[i];
      yy[i]=yy[i]+velY[i]*noise(posNoise);
      
      // Check Boundaries
      if(xx[i]<0-raio[i]) {xx[i]=width+raio[i]; yy[i]=random(0,height);}
      if(xx[i]>width+raio[i]) {xx[i]=0-raio[i]; yy[i]=random(0,height); }
      if(yy[i]<0-raio[i]){ yy[i]=height+raio[i]; xx[i]=random(0,width); }
      if(yy[i]>height+raio[i]){ yy[i]=0-raio[i]; xx[i]=random(0,width); }
      
    }
    
   for (int i=0; i<counter; i++) { 
     

     for (int j=0; j<nr; j++) { 
       stroke(255);
       if(dist(skelX[i], skelY[i],xx[j],yy[j])<80) 
       {line(skelX[i], skelY[i],xx[j],yy[j]);
       //ellipse(skelX[i],skelY[i],5,5);
       }
     }
      
   }
  }



  //////////////////// Original Video
  if (originalVid) {
    tint(255, 255);
    image(mov2, width-width/4, 0, width/4, height/4);
  }

  //////////////////// GUI

  if (gui) {
    noStroke();
    fill(0, 20);
    rect(0, 0, 100, 200);

    fill(255);
    text("FPS :"+int(frameRate), 10, 20);
    fill(255);
    text("NrPoints: "+counter, 10, 40); // number points in the skeleton

    text("KEYS ON/OFF:", 10, 70);
    text("[G] GUI", 10, 90);
    text("[B] BACK.PIC ", 10, 110);
    text("[V] VID ", 10, 130);
    text("[R] RECTS ", 10, 150);
    text("[S] SKELETON ", 10, 170);
  
    text("[0 - 6] MODE", 10, 210);
    text("MODE: "+mode,10,230);
  }
}

////////////////////////////////////////////////////////////

void keyPressed() {

  if (key=='g' || key=='G') gui=!gui;
  if (key=='b' || key=='B') backPic=!backPic;
  if (key=='v' || key=='V') originalVid=!originalVid;
  if (key=='r' || key=='R') rectss=!rectss;
  if (key=='s' || key=='S') skeleton=!skeleton;


  if (key=='0') {mode=0;gui=true;backPic=true;skeleton=true;}
  if (key=='1') mode=1;
  if (key=='2') mode=2;
  if (key=='3') mode=3;
  if (key=='4') mode=4;
  if (key=='5') {mode=5; skeleton=false;}
  if (key=='6') {mode=6;skeleton=false;}
  if (key=='7') {mode=7;skeleton=true;}
}


//
void movieEvent(Movie m) {
  m.read();
}
