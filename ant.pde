class Ant{
  PVector pos;
  PVector vel;
  PVector acc;
  float maxSpeed;
  float maxForce;
  
  float viewDistance;

  Colony colony;

  boolean asFood;

  float timer;
  int pheromoneDelay;
  int currentPheromoneType;
  float AFKSince;

  final static float r=0.1;

  final float noiseOffset=random(999999);

  Ant(PVector pos, PVector vel,Colony colony,float maxSpeed, int pheromoneDelay){

    this.pos=pos;
    this.vel=vel;
    this.acc=new PVector(0,0);
    this.maxSpeed=maxSpeed;
    this.maxForce=0.005;

    this.viewDistance=1;

    this.colony=colony;

    this.asFood=false;

    this.timer=(int)random(0,pheromoneDelay);
    this.pheromoneDelay=pheromoneDelay;
    this.currentPheromoneType=0;
    this.AFKSince=0;
  }

  void seek(PVector target,float power){
    PVector desired=PVector.sub(target,this.pos);
    desired.setMag(this.maxSpeed);
    PVector steer=PVector.sub(desired,this.vel);
    steer.limit(this.maxForce);
    steer.mult(power);
    this.acc.add(steer);
  }

  ArrayList<Food> getCloseFood(){
    ArrayList<Food> res=new ArrayList<Food>();
    for (Food f : foods){
        float d=f.pos.dist(this.pos);
        if (d<this.viewDistance){
          res.add(f);
        }
    }
    return res;
  }

  PVector getBestFoodPos(){
    PVector bestPos=null;
    float bestDist=9999999;
    for (Food f : this.getCloseFood()){
      float d=f.pos.dist(this.pos);
      if (d<bestDist){
        bestDist=d;
        bestPos=f.pos;
      }
    }


    return bestPos;
  }

  void turnAround(float random){
    this.vel.rotate(PI);
    this.vel.rotate(random(random,-random));
  }

  void update(){

    this.vel.add(this.acc.copy().mult(60/frameRate));
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel.copy().mult(60/frameRate));
    this.acc.mult(0);

    if (this.collides()){
      this.turnAround(0);
      while (this.collides()){
        this.pos.add(this.vel.setMag(0.1));
      }
    }




    boolean lookForPheromones=true;
    if (this.asFood){
      if (this.colony.origin.dist(this.pos)<this.colony.radius+this.viewDistance){
        this.seek(this.colony.origin,1);
        lookForPheromones=false;
      }

    }else{
      PVector target=this.getBestFoodPos();
      if (target!=null){
        this.seek(target,1);
        lookForPheromones=false;
      }
    }

    if (!this.asFood){
      for (Food f : foods){
        if (f.pos.dist(this.pos)<Ant.r+Food.r){
          f.del=true;
          this.asFood=true;
          this.currentPheromoneType=1;
          this.turnAround(0);
          this.AFKSince=0;
          break;
        }
      }
    }else{
      if (this.colony.origin.dist(pos)<this.colony.radius*1.1){
        this.asFood=false;
        this.currentPheromoneType=0;
        this.colony.foodStock++;
        this.turnAround(0);
        this.AFKSince=0;
      }
    }
    this.AFKSince+=60/frameRate;

    this.timer+=60/frameRate;
    if (this.timer>=this.pheromoneDelay){
      float power=1-constrain(this.AFKSince/600,0,0.9);
      map.map[(int)this.pos.x][(int)this.pos.y].pheromones.add(new Pheromone(this.pos.x,this.pos.y,this.currentPheromoneType,power));
      this.timer=0;
    }

    float maxVal=0;
    if (lookForPheromones){
      PVector[] samples=this.getSamplePoints();

      int maxIdx=0;
      for (int p=0;p<samples.length;p++){
        float sz;
        if (this.asFood){
          sz=map.map[(int)samples[p].x][(int)samples[p].y].getpower(samples[p].x,samples[p].y,0);
        }else{
          sz=map.map[(int)samples[p].x][(int)samples[p].y].getpower(samples[p].x,samples[p].y,1);
        }

        if (this.colony.origin.dist(samples[p])<this.colony.radius){
          sz*=10;
        }
        if (sz>maxVal){maxVal=sz;maxIdx=p;}
      }
      if (maxVal>0){
        this.seek(samples[maxIdx],1);
      }
    }
    if (maxVal==0){
      this.vel.rotate(map(noise((frameCount+this.noiseOffset)/20),0,1,-PI/15,PI/15));
    }else{
      this.vel.rotate(map(noise((frameCount+this.noiseOffset)/20),0,1,-PI/25,PI/25));
    }
  }

  PVector[] getSamplePoints(){
    PVector[] res=new PVector[3];
    res[0]=this.pos.copy().add(this.vel.copy().setMag(this.viewDistance).rotate(PI/5));
    res[1]=this.pos.copy().add(this.vel.copy().setMag(this.viewDistance).rotate(0));
    res[2]=this.pos.copy().add(this.vel.copy().setMag(this.viewDistance).rotate(-PI/5));

    for (PVector p : res){
      p.x=constrain(p.x,0,map.w);
      p.y=constrain(p.y,0,map.h);
    }
    return res;
  }

  boolean collides(){
    return pointsCollides(this.pos.x,this.pos.y);
  }

  void render(){
    fill(0);

    noStroke();
    PVector p=map.wts(this.pos.x,this.pos.y);
    circle(p.x,p.y,map.res*Ant.r*2);

    /*noFill();
    stroke(255);
    strokeWeight(map.res/100);
    circle(p.x,p.y,map.res*this.viewDistance*2);*/

    if (this.asFood){
      fill(0,255,0);
      noStroke();
      p=this.pos.copy().add(this.vel.copy().setMag(Ant.r));
      p=map.wts(p.x,p.y);
      circle(p.x,p.y,map.res*Food.r*2);
    }

    /*
    stroke(0,255,255);
    strokeWeight(map.res/100);
    p=map.wts(this.pos.x,this.pos.y);
    PVector p2;
    for (Food f : this.getCloseFood()){
      p2=map.wts(f.pos.x,f.pos.y);
      line(p.x,p.y,p2.x,p2.y);
    }
    fill(0,255,255);
    noStroke();
    PVector target=this.getBestFoodPos();
    if (target!=null){
      p2=map.wts(target.x,target.y);
      circle(p2.x,p2.y,map.res/10);
    }*/



    /*fill(255);
    noStroke();
    for (PVector sp : this.getSamplePoints()){
      p=map.wts(sp.x,sp.y);
      circle(p.x,p.y,map.res/10);
    }*/

  }
}

boolean pointsCollides(float x,float y){
  if (x<0 || y<0 || x>=map.w || y>=map.h) return true;

  for (Colony c : colonies){
    if (dist(c.origin.x,c.origin.y,x,y)<c.radius)return true;
  }

  ArrayList<PVector> points=map.getShapePoints((int)x,(int)y);
  if (points.size()==0) return false;

  return polyPoint(points,x,y);
}

boolean polyPoint(ArrayList<PVector> vertices, float px, float py) {
  boolean collision = false;
  int next = 0;
  for (int current=0; current<vertices.size(); current++) {
    next = current+1;
    if (next == vertices.size()) next = 0;
    PVector vc = vertices.get(current);
    PVector vn = vertices.get(next);
    if (((vc.y >= py && vn.y < py) || (vc.y < py && vn.y >= py)) &&
         (px < (vn.x-vc.x)*(py-vc.y) / (vn.y-vc.y)+vc.x)) {
            collision = !collision;
    }
  }
  return collision;
}
