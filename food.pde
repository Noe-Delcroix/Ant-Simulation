class Food{
  PVector pos;
  boolean del=false;
  
  final static float r=0.07;
  
  Food(float x,float y){
    this.pos=new PVector(x,y);
  }
  
  void render(){
    fill(0,255,0);
    noStroke();
    PVector p=map.wts(this.pos.x,this.pos.y);
    circle(p.x,p.y,map.res*Food.r*2);
    
    
  }
  
}
