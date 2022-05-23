import java.util.HashMap;
import java.util.Map;

class Junction { 
  Integer[] direction; //Index 0 Haut - 1 Droite - 2 Bas - 3 Gauche | Contient la junction
  Integer id;
  Integer x;
  Integer y;
  
  Junction(Integer[] direction, Integer x, Integer y, Integer id) {   
    this.direction = direction;
    this.x = x == null ? null :-x + 160 + 160;
    this.y = y == null ? null :-y + 90 + 100;
    this.id = id;
  }
  
  public Junction getDestination(Integer direction, Map<Integer, Junction> junctions) {
    return junctions.get(this.direction[direction]);
  }
  
  public Boolean displayDirection(){
    Integer nbDirection = 0;
    for(Integer i = 0; i < 4; i++) {
      if (this.direction[i] != null) {
        nbDirection++;
      }
    }
    return nbDirection > 1;
  }
}
