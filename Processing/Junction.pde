import java.util.HashMap;
import java.util.Map;

class Junction { 
  Integer[] direction; //Index 0 Haut - 1 Droite - 2 Bas - 3 Gauche | Contient la junction
  Integer x;
  Integer y;
  
  Junction(Integer[] direction, Integer x, Integer y) {   
    this.direction = direction;
    this.x = x;
    this.y = y;
  }
  
  
  /**
  qsdlmifhlqsdf
  **/
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
