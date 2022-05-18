
class AnimationController {
  Animation[] playerSpritesAnimated;
  PImage[] playerSpritesIdle;
  HashMap<String,Integer> playerAnimations = new HashMap<String,Integer>();
  
  boolean displayIdle = true;
  int spriteDirection = 0;
    AnimationController() {
      
      playerSpritesAnimated = new Animation[4];
      playerSpritesAnimated[0] = new Animation("walkdown", 4);
      playerSpritesAnimated[1] = new Animation("walkleft", 4);
      playerSpritesAnimated[2] = new Animation("walkup", 4);
      playerSpritesAnimated[3] = new Animation("walkright", 4);
      
      playerSpritesIdle = new PImage[4];
      playerSpritesIdle[0] = loadImage("downidle.png");
      playerSpritesIdle[1] = loadImage("leftidle.png");
      playerSpritesIdle[2] = loadImage("upidle.png");
      playerSpritesIdle[3] = loadImage("rightidle.png");
      
      playerAnimations.put("down", 0);
      playerAnimations.put("left", 1);
      playerAnimations.put("up", 2);
      playerAnimations.put("right", 3);
    }
    
    public void changeDirection(String direction) {
      spriteDirection = playerAnimations.get(direction);   
    }
    public void displayIdle(int direction) {
      image(playerSpritesIdle[direction], width/2, height/2); 
    }
    public void displayAnimated(int direction) {
      playerSpritesAnimated[direction].display( width/2, height/2);
    }
}
 
