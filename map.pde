class Map{
  
  final int[][] SHAPES= new int[][]{
    {},
    {6, 7, 3},
    {5, 6, 2},
    {5, 7, 3, 2},
    {4, 5, 1},
    {4,1,5,6,3,7},
    {1,2,6,4},
    {4,1,2,3,7},
    {0,4,7},
    {0,4,6,3},
    {0,4,5,2,6,7},
    {0,4,5,2,3},
    {0,1,5,7},
    {0,1,5,6,3},
    {0,1,2,6,7},
    {0,1,2,3}
  };
  
  final float SURFACE_LEVEL=0.5;
  final float INTERPOLATION_LEVEL=0.5;
  
  int brushSize=5;
  
  Tile[][] map;
  int res,w,h;
  
  
  
  Map(int res){
    this.res=res;
    this.w=(int)(width/res);
    this.h=(int)(height/res);
   
    this.map=new Tile[this.w+1][this.h+1];
    for (float y=0;y<this.h+1;y++){
      for (float x=0;x<this.w+1;x++){
        //map[(int)x][(int)y]=new Tile(noise(x/10,y/10));
        
        map[(int)x][(int)y]=new Tile(0);
      }
    }
  }
  void clearMap(){
    for (float y=0;y<this.h+1;y++){
      for (float x=0;x<this.w+1;x++){
        this.map[(int)x][(int)y].deletePheromones();
      }
    }
  }
  
  PVector[] getAllPoints(int x,int y){
    return new PVector[]{new PVector(x,y),
                         new PVector(x+1,y),
                         new PVector(x+1,y+1),
                         new PVector(x,y+1),
                         new PVector(x+map(SURFACE_LEVEL,map[x][y].tv,map[x+1][y].tv,0.5-INTERPOLATION_LEVEL,0.5+INTERPOLATION_LEVEL),y),
                         new PVector(x+1,y+map(SURFACE_LEVEL,map[x+1][y].tv,map[x+1][y+1].tv,0.5-INTERPOLATION_LEVEL,0.5+INTERPOLATION_LEVEL)),
                         new PVector(x+map(SURFACE_LEVEL,map[x][y+1].tv,map[x+1][y+1].tv,0.5-INTERPOLATION_LEVEL,0.5+INTERPOLATION_LEVEL),y+1),
                         new PVector(x,y+map(SURFACE_LEVEL,map[x][y].tv,map[x][y+1].tv,0.5-INTERPOLATION_LEVEL,0.5+INTERPOLATION_LEVEL))};
  }
  
  int getBinary(int x,int y){
    int res=0;
    if (this.map[x][y].tv>this.SURFACE_LEVEL) res+=8;
    if (this.map[x+1][y].tv>this.SURFACE_LEVEL) res+=4;
    if (this.map[x+1][y+1].tv>this.SURFACE_LEVEL) res+=2;
    if (this.map[x][y+1].tv>this.SURFACE_LEVEL) res+=1;
    
    return res;
  }
  
  ArrayList<PVector> getShapePoints(int x,int y){
    ArrayList<PVector> res=new ArrayList<PVector>();
    int[] shapeData=SHAPES[getBinary(x,y)];
    PVector[] points=getAllPoints(x,y);
    for (int s : shapeData){
      res.add(points[s]);
    }
    return res;
  }
  
  void render(){
    noStroke();
    fill(91, 50, 0);
    for (int y=0;y<h;y++){
      for (int x=0;x<w;x++){
        beginShape();
        for (PVector p : this.getShapePoints(x,y)){
          PVector pos=this.wts(p.x,p.y);
          vertex(pos.x,pos.y);
        }
        endShape(CLOSE);
        
        
        /*noStroke();
        fill(0,255,255,this.map[x][y].getFrompower(x+0.5,y+0.5)*10);
        rect(x*this.res,y*this.res,this.res,this.res);
        fill(255,0,0,this.map[x][y].getBackpower(x+0.5,y+0.5)*10);
        rect(x*this.res,y*this.res,this.res,this.res);*/
      }
    }
  }
  
  void updatePheromones(){
    for (int y=0;y<h;y++){
      for (int x=0;x<w;x++){
        this.map[x][y].updatePheromones();
      }
    }
  }
  
  void mouseControls(){
  
    noFill();
    stroke(255,100);
    strokeWeight(3);
    circle(mouseX,mouseY,brushSize*res);
    
    if (mousePressed){
      PVector mp=stw(mouseX,mouseY);
      if (mouseButton==CENTER){
        
        for (int i=0;i<5;i++){
          PVector pos=new PVector(mp.x+randomGaussian()*brushSize/5,mp.y+randomGaussian()*brushSize/5);
          if (!pointsCollides(pos.x,pos.y)){
            foods.add(new Food(pos.x,pos.y));
          }
        }
        
      }else{
        float val=0.2;
        if (mouseButton==RIGHT) val*=-1;
        
        for (float y=floor(max(0,mp.y-this.brushSize/2));y<ceil(min(this.h+1,mp.y+this.brushSize/2));y++){
          for (float x=floor(max(0,mp.x-this.brushSize/2));x<ceil(min(this.w+1,mp.x+this.brushSize/2));x++){
             this.map[(int)x][(int)y].tv+=map(dist(x,y,mp.x,mp.y),0,this.brushSize,val,0);
             this.map[(int)x][(int)y].tv=constrain(map[(int)x][(int)y].tv,0,1);
          }
        }
        
        for (Food f : foods){
          if (f.pos.dist(mp)<brushSize/2){
            f.del=true;
          }
        }
      }
    }
  }
  
  void mouseWheel(MouseEvent event){
    brushSize-=event.getCount();
    brushSize=constrain(brushSize,1,min(w,h));
  }
  
  PVector wts(float worldX,float worldY){
    return new PVector(worldX*this.res,worldY*this.res);
  }
  
  PVector stw(float screenX,float screenY){
    return new PVector(screenX/this.res,screenY/this.res);
  }
}
