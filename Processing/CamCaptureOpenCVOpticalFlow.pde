import processing.video.*;
import gab.opencv.*;
import java.awt.*;
import java.util.HashMap;
import java.util.Map;
import processing.sound.*;
import ddf.minim.*;

Capture cam_;
OpenCV opencv_;

PImage row_bottom;
PImage row_top;
PImage row_left;
PImage row_right;
PImage map;

Integer speed = 4;
Integer x_map = -130;
Integer y_map = -640;
Integer destination_x_map = -130;
Integer destination_y_map = -640;
Boolean is_moving = false;
Integer direction_actuelle = 2;
Junction point_actuelle;
Integer point_victoire = 43;

Map<Integer, Junction> junctions;

float timeMS_ = millis();
float timeS_ = timeMS_ * 0.001;
float timeSOld_ = timeMS_;

Timer timer;

int videoWidth_ = 320;
int videoHeight_ = 180;
// int scale_ = 6;
int scale_ = 3;

PImage[] frames_ = new PImage[2];
int currentFrameIndex_ = 0;
boolean first_ = true;
PImage fullFrame_ = new PImage(videoWidth_*scale_,videoHeight_*scale_);

Flow flow_ = null;
HotSpot[] hotSpots_ = new HotSpot[4];

//================================
float detectAbsoluteMagMin_ = 2.0;
float detectAverageMagMax_ = 1.2;
float psAverageMax_ = 0.2;
//=================================

int selectedHotSpotIndex_ = -1;
float selectDelaySo_ = 0.5;
float selectDelayS_ = selectDelaySo_;

//============

//  Player animations variables
Animation[] playerSpritesAnimated;
PImage[] playerSpritesIdle;
HashMap<String,Integer> playerAnimations = new HashMap<String,Integer>();
AnimationController animation;
int previousTime;
int runAnimationDuration = 1500;

Minim minim;
AudioPlayer player;
AudioPlayer beep;

void setup() {
  loadMap();
  //fullScreen();
  size(960,540);
  minim = new Minim(this);
  player = minim.loadFile("background.mp3");
  player.setGain(0.5);
  player.play();
  
  beep = minim.loadFile("beep.mp3");

  row_bottom = loadImage("arrow_bottom.png");
  row_top = loadImage("arrow_top.png");
  row_left = loadImage("arrow_left.png");
  row_right = loadImage("arrow_right.png");
  map = loadImage("map.png");
  
  //new Timer instance
  timer = new Timer();
  point_actuelle = junctions.get(0);
  
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an
    // element from the array returned by list():
    cam_ = new Capture(this, videoWidth_, videoHeight_, "Integrated Webcam");

    opencv_ = new OpenCV(this, videoWidth_, videoHeight_);

    flow_ = opencv_.flow;

    flow_.setPyramidScale(0.5); // default : 0.5
    flow_.setLevels(1); // default : 4
    flow_.setWindowSize(8); // default : 8
    flow_.setIterations(1); // default : 2
    flow_.setPolyN(3); // default : 7
    flow_.setPolySigma(1.5); // default : 1.5

    int m = 10;
    int w = 50;
    int h = 30;

    int x = m;
    int y = m;
    x = videoWidth_ / 2 - w / 2;
    hotSpots_[0] = new HotSpot(x,y,w,h);

    x = m;
    y = videoHeight_ /2 - h /2 ;
    hotSpots_[1] = new HotSpot(x,y,w,h);

    x = videoWidth_ - m - w;
    hotSpots_[2] = new HotSpot(x,y,w,h);

    x = videoWidth_ / 2 - w / 2;
    y = videoHeight_ - m - h;
    hotSpots_[3] = new HotSpot(x,y,w,h);


    cam_.start();
  }
    animation = new AnimationController();
    previousTime = millis();
}


//=====================
void detectHotSpots() {

  for ( int k = 0 ; k < 4 ; k++ ) {

    HotSpot hs = hotSpots_[k];

    int nb = 0;

    float absolute_mag = 0.0;
    PVector p_average = new PVector(0.,0.);
    float ps_average = 0.0;

    int step = 2;

    //=======================================
    for( int j = 0 ; j < hs.h ; j += step ) {
      for( int i = 0 ; i < hs.w ; i += step ) {
        PVector p = flow_.getFlowAt(hs.x+i,hs.y+j);
        absolute_mag += p.mag();
        p_average.add(p);
        nb++;
      }
    }
    absolute_mag /= nb;
    p_average.div(nb);
    float average_mag = p_average.mag();

    //=======================================
    for( int j = 0 ; j < hs.h ; j += step ) {
      for( int i = 0 ; i < hs.w ; i += step ) {
        PVector p = flow_.getFlowAt(hs.x+i,hs.y+j);
        ps_average += p.dot(p_average);
        nb++;
      }
    }
    ps_average /= nb;

    noFill();
    stroke(0,0,255);
    strokeWeight(2.);
    float x1 = hs.x + hs.w / 2.;
    float y1 = hs.y + hs.h / 2.;
    float x2 = x1 + p_average.x;
    float y2 = y1 + p_average.y;
    line(x1,y1,x2,y2);

    boolean absolute_mag_ok = absolute_mag > detectAbsoluteMagMin_;
    boolean average_mag_ok = average_mag < detectAverageMagMax_;
    boolean ps_average_ok = ps_average < psAverageMax_;

    if ( selectDelayS_ < 0.) {

      if ( absolute_mag_ok ) {

        if ( average_mag_ok )  {

          if ( ps_average_ok )  {

            selectedHotSpotIndex_ = selectedHotSpotIndex_ == k ? -1 : k;
            selectDelayS_ = selectDelaySo_;
            beep.rewind();
            beep.play();
          }
        }
      }
    }
  }
}

//===================
void drawHotSpots() {
  noFill();
  strokeWeight(1.);
  for ( int k = 0 ; k < 4 ; k++ ) {
    stroke(255,0,0);
    if ( ( selectedHotSpotIndex_ >= 0 ) && ( k == selectedHotSpotIndex_ ) ) {
      stroke(0,255,0);
    }
    rect(hotSpots_[k].x,hotSpots_[k].y,hotSpots_[k].w,hotSpots_[k].h);
  }
}

//===========
void draw() {
  
  synchronized(this) {

    timeMS_ = millis();
    timeS_ = timeMS_ * 0.001;

    selectDelayS_ -= timeS_ - timeSOld_;

    background(0,0,0);

    if ( frames_[currentFrameIndex_] != null ) {

      //frames_[currentFrameIndex_].resize(640*scale,360*scale); // slow...

      frames_[currentFrameIndex_].loadPixels();
      fullFrame_.loadPixels();
      for (int j = 0; j < fullFrame_.height ; j+=2) {
        for ( int i = 0 ; i < fullFrame_.width ; i++ ) {
          int index_src = ( j / scale_ ) * frames_[currentFrameIndex_].width + ( i / scale_ );
          int index_dst = j * fullFrame_.width + i;
          fullFrame_.pixels[index_dst] = frames_[currentFrameIndex_].pixels[index_src];
        }
      }
      fullFrame_.updatePixels();

      tint(255, 255, 255, 255);
      image(fullFrame_, 0, 0);
      // Left
      image(row_left,0,200, 150, 150);
      // Right
      image(row_right,800,200, 150, 150);
      // Top
      image(row_top,400,0, 150, 150);
      // Bottom
      image(row_bottom,400,400, 150, 150);

      stroke(255,0,0);
      strokeWeight(1.);

      scale(scale_);

      //opencv_.drawOpticalFlow();
      image(map,x_map,y_map);
      loadPlayer();
      if (destination_x_map > x_map) {
        goToRight();
      } else if (destination_x_map < x_map) {
        goToLeft();
      } else if (destination_y_map < y_map) {
        goToBottom();
      } else if (destination_y_map > y_map) {
        goToTop();
      } else if (is_moving) {
        is_moving = false;
        point_actuelle = point_actuelle.getDestination(direction_actuelle, junctions);
        if (point_actuelle.id == point_victoire) {
          // Victoire ICI
        }
      }
      
      drawHotSpots();

      detectHotSpots();

      drawTimer();

      first_ = false;
    }
  }

  timeSOld_ = timeS_;
}

//============================
void captureEvent(Capture c) {

  synchronized(this) {

    c.read();
    //opencv.useColor(RGB);
    opencv_.useGray();
    opencv_.loadImage(cam_);
    opencv_.flip(OpenCV.HORIZONTAL);
    //opencv_.flip(OpenCV.VERTICAL);
    opencv_.calculateOpticalFlow();

    frames_[currentFrameIndex_] = opencv_.getSnapshot();

  }

}

//=================
void keyPressed() {
  if ( (keyCode == ESC) || ( keyCode == 'q' ) || ( keyCode == 'Q' )) {
    cam_.stop();
    exit();
  }
  if (keyCode == UP) {
    Junction dest = point_actuelle.getDestination(0, junctions);
    if (dest != null) {
      direction_actuelle = 0;
      destination_x_map = dest.x;
      destination_y_map = dest.y;
      is_moving = true;
    }
  }
  if (keyCode == RIGHT) {
    Junction dest = point_actuelle.getDestination(1, junctions);
    if (dest != null) {
      direction_actuelle = 1;
      destination_x_map = dest.x;
      destination_y_map = dest.y;
      is_moving = true;
    }
  }
  if (keyCode == DOWN) {
    Junction dest = point_actuelle.getDestination(2, junctions);
    if (dest != null) {
      direction_actuelle = 2;
      destination_x_map = dest.x;
      destination_y_map = dest.y;
      is_moving = true;
    }
  }
  if (keyCode == LEFT) {
    Junction dest = point_actuelle.getDestination(3, junctions);
    if (dest != null) {
      direction_actuelle = 3;
      destination_x_map = dest.x;
      destination_y_map = dest.y;
      is_moving = true;
    }
  }
  
  
  if ( ( keyCode == 'n' ) || ( keyCode == 'N' )) {
    timer.start();
  }

}

//TO DO Remove millis logic and check if player arrived at intersection instead (breakpoint instead of duration)
void loadPlayer() {
  if(animation.displayIdle) {
    animation.displayIdle(animation.spriteDirection, x_map, y_map);
  } else {
    if (millis() - previousTime <= runAnimationDuration) {
       animation.displayAnimated(animation.spriteDirection, x_map, y_map);
    } else {
       animation.displayIdle = !animation.displayIdle;
      }
  }
}

void loadMap() {
  junctions = new HashMap<Integer, Junction>();
  JSONArray json = loadJSONArray("map.json");
  
  for (Integer i = 0; i < json.size(); i++)
  {
    JSONObject junc = json.getJSONObject(i);
    Integer x = junc.isNull("x") ? null : junc.getInt("x");
    Integer y = junc.isNull("y") ? null : junc.getInt("y");    
    Integer id = junc.isNull("id") ? null : junc.getInt("id");
    JSONArray directionJson = junc.getJSONArray("direction");
    Integer[] direction = {
      directionJson.isNull(0) ? null : directionJson.getInt(0),
      directionJson.isNull(1) ? null : directionJson.getInt(1),
      directionJson.isNull(2) ? null : directionJson.getInt(2),
      directionJson.isNull(3) ? null : directionJson.getInt(3),
    };
    Junction junction = new Junction(direction, x, y, id);
    junctions.put(i, junction);
  }  
}


//TO DO
void goToLeft() {
  /*animation.changeDirection("left");
  animation.displayIdle = !animation.displayIdle;
  previousTime = millis();*/
  if (x_map - speed < destination_x_map) {
    x_map = destination_x_map; 
  } else {
    x_map = x_map - speed;
  }
}

//TO DO
void goToRight() {  
  /*animation.changeDirection("right");
  animation.displayIdle = !animation.displayIdle;
  previousTime = millis();*/

  if (x_map + speed > destination_x_map) {
    x_map = destination_x_map; 
  } else {
    x_map = x_map + speed;
  }
  x_map = x_map + speed;
}

//TO DO
void goToTop() {
  /*animation.changeDirection("up");
  animation.displayIdle = !animation.displayIdle;
  previousTime = millis();  */
  if (y_map + speed > destination_y_map) {
    y_map = destination_y_map; 
  } else {
    y_map = y_map + speed;
  }
}

//TO DO
void goToBottom() {
  /*animation.changeDirection("down");
  animation.displayIdle = !animation.displayIdle;
  previousTime = millis();  */
  if (y_map - speed < destination_y_map) {    
    y_map = destination_y_map; 
  } else {
    y_map = y_map - speed;
  }
}

void drawTimer() {
  text(timer.getStringTime(), 10, 10);
}

void stop() {
   beep.close();
   minim.stop();
   super.stop();
}
