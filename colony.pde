class Colony{
  ArrayList<Ant> ants;
 
  PVector origin;
  float radius;
  
  int foodStock;
  
  Colony(float x,float y,float r, int antsNb){
    this.origin=new PVector(x,y);
    this.radius=r;
    
    this.ants=new ArrayList<Ant>();
    for (int i=0;i<antsNb;i++){
      
      PVector pos=new PVector(x,y);
      PVector vel=new PVector(random(-1,1),random(-1,1)).setMag(r);
      this.ants.add(new Ant(pos.add(vel),vel,this,0.06,5));
    }
    
    this.foodStock=0;
  }
  
  void update(){
    for (Ant a : this.ants){
      a.update(); 
    }
  }
  
  void render(){
    for (Ant a : this.ants){
      a.render(); 
    }
    
    fill(91, 50, 0);
    noStroke();
    
    PVector p=map.wts(this.origin.x,this.origin.y);
    circle(p.x,p.y+map.res*0.1,map.res*this.radius*2);
    
    fill(70,35,0);
    noStroke();
    textSize(map.res*this.radius);
    textAlign(CENTER,CENTER);
    text(this.foodStock,p.x,p.y);
    
    
  }
  
  
}
