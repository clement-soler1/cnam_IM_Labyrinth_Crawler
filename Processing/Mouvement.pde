class Mouvement {
  //Déclaration des caractéristiques de base de la balle
  float x;
  float y;
  PImage img;
  
//Constructeur de la balle
Mouvement (float nouvX, float nouvY) {
  x = nouvX;
  y = nouvY;
  }
  
   //Dessin de la balle
  void display() {
    image (img,x,y);
  }
  
  void testCollision() {
    
    //Si la balle touche une mur, elle rebondit
    if (x > width-20 || x < 20) {
      x = x * -1;
    }
    if (y > height-20 || y < 20) {
      y = y * -1;
    } 
  }
  //TO DO 
  void goToLeft() {
    y = x - 20;
  }
  
  //TO DO
  void goToRight() {
    y = x + 20;
  }
  
  //TO DO
  void goToTop() {
    x = y + 20;
  }
  
  //TO DO
  void goToBottom() {
    x = y + 20;
  }
}
