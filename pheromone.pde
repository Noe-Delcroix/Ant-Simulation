class Pheromone{
  PVector pos;
  
  float power;
  float decaySpeed;
  boolean del=false;
  
  int type;
  final color[] colors=new color[]{color(0,255,255),color(255,0,0)};
  final float[] decaySpeeds=new float[]{0.003,0.003};
  final float[] diffusionpowers=new float[]{0.01,0.01};
  
  Ant creator;
  
  Pheromone(float x,float y, int type, float power){
    this.pos=new PVector(x,y);
    this.type=type;
    
    this.power=power;

  }
  
  void update(){
    this.power-=this.decaySpeeds[this.type];
    if (this.power<=0){
      this.del=true;
    }
    float d=this.diffusionpowers[this.type];
    this.pos.add(new PVector(random(-d,d),random(-d,d)).mult(60/frameRate));
  }
  
  void render(){
    color c=this.colors[this.type];
    
    fill(red(c),green(c),blue(c),map(this.power,0,1,0,255));
    noStroke();
    PVector p=map.wts(this.pos.x,this.pos.y);
    circle(p.x,p.y,map.res/10);
  }
}
