class Tile{
  //terrain power
  float tv;
  
  ArrayList<Pheromone> pheromones;
  
  Tile(float tv){
    this.tv=tv;
    
    this.deletePheromones();
  }
  
  void deletePheromones(){
    this.pheromones=new ArrayList<Pheromone>();
  }
  
  void updatePheromones(){
    for (int p=this.pheromones.size()-1;p>=0;p--){
      this.pheromones.get(p).update();
      if (mousePressed && mouseButton==RIGHT)this.pheromones.get(p).render();
      if (this.pheromones.get(p).del){
        this.pheromones.remove(p);
      }
    }
  }
  
  float getpower(float x,float y,int targetType){
    float res=0;
    for (Pheromone p : this.pheromones){
      if (p.type==targetType && p.pos.dist(new PVector(x,y))<0.5){
        res+=p.power;
        
      }
      
    }
    return res;
  }
}
